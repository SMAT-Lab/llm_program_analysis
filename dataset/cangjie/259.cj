package redis_sdk.client
internal import std.collection.HashMap
internal import std.convert.Parsable
internal import std.sync.AtomicBool
internal import std.sync.AtomicReference
internal import std.sync.ReentrantMutex
internal import std.sync.sleep
internal import hyperion.transport.ClientTcpEndpoint
internal import redis_sdk.client.api.CommandArgs
internal import redis_sdk.client.api.ParameterizedRedisCommand
internal import redis_sdk.client.api.SentinelKeyWord
internal import redis_sdk.client.api.SubscriberListener
public open class SentinelManager {
    static let logger: Logger = LoggerFactory.getLogger("redis-sdk")
    private static let initManagerLock = ReentrantMutex()
    private static let idGenerator = AtomicInt64(0)
    private let id: Int64
    private static let sentinelManagers = HashMap<SentinelRedisClientConfig, SentinelManager>()
    private let sentinelConfig: SentinelRedisClientConfig
    private let threadPool: ThreadPool
    private let currentMaster: AtomicReference<HostAndPort>
    private let sentinelSubscribers = HashMap<HostAndPort, RedisSubscriber>()
    private let sentinelListeners = ArrayList<SentinelListener>()
    private let initialized = AtomicBool(false)
    private let closed = AtomicBool(false)
    private let masterProviders = ArrayList<SentinelMasterProvider>()
    private let sentinelManagerMutex = ReentrantMutex()
    private var closeTaskRef: ?CloseSentinelManagerTask = None
    private let refCount = AtomicUInt64(0)
    static func getSentinelManager(sentinelConfig: SentinelRedisClientConfig): SentinelManager {
        synchronized(initManagerLock) {
            if (let Some(sentinelManager) <- sentinelManagers.get(sentinelConfig)) {
                if (sentinelManager.retain()) {
                    return sentinelManager
                } else {
                    sentinelManagers.remove(sentinelConfig)
                }
            }
            let sentinelManager = SentinelManager(sentinelConfig)
            sentinelManager.initialize()
            sentinelManagers.put(sentinelConfig, sentinelManager)
            // 新创建SentinelManager的也需要调用retain，确保引用计数正确
            sentinelManager.retain()
            return sentinelManager
        }
    }
    public init(sentinelConfig: SentinelRedisClientConfig) {
        try {
            this.id = idGenerator.fetchAdd(1)
            this.sentinelConfig = sentinelConfig
            this.threadPool = RedisClientBuilder.buildThreadPool(sentinelConfig)
            let master = getMaster(sentinelConfig, threadPool, sentinelSubscribers)
            currentMaster = AtomicReference<HostAndPort>(master)
        } catch (ex: RedisException) {
            destorySentinels(sentinelSubscribers, sentinelListeners)
            throw ex
        }
    }
    public func getSentinelConfig() {
        return this.sentinelConfig
    }
    public func getThreadPool() {
        return this.threadPool
    }
    public func getMasterName() {
        return sentinelConfig.masterName
    }
    public func getCurrentMaster(): HostAndPort {
        return currentMaster.load()
    }
    protected func checkOpen(): Unit {
        if (closed.load()) {
            throw RedisException("SentinelManager ${sentinelConfig.masterName} is already closed")
        }
    }
    public func addMasterProvider(masterProvider: SentinelMasterProvider) {
        checkOpen()
        synchronized(sentinelManagerMutex) {
            if (!masterProviders.contains(masterProvider)) {
                this.masterProviders.append(masterProvider)
            }
        }
        if (logger.isDebugEnabled()) {
            logger.debug("SentinelManager::addMasterProvider, add ${masterProvider} to ${getSentinelManagerStatus()}")
        }
    }
    public func removeMasterProvider(masterProvider: SentinelMasterProvider) {
        func checkEquals(item: SentinelMasterProvider) {
            if (refEq(masterProvider, item) || masterProvider == item) {
                if (refCount.load() > 0) {
                    refCount.fetchSub(1)
                }
                return true
            }
            return false
        }
        synchronized(sentinelManagerMutex) {
            masterProviders.removeIf(checkEquals)
            if (logger.isDebugEnabled()) {
                logger.debug(
                    "SentinelManager::removeMasterProvider, remove ${masterProvider} from ${getSentinelManagerStatus()}"
                )
            }
            if (refCount.load() == 0 && masterProviders.isEmpty()) {
                if (closeTaskRef.isNone()) {
                    let closeTask = CloseSentinelManagerTask(this)
                    closeTaskRef = closeTask
                    if (logger.isDebugEnabled()) {
                        logger.debug(
                            "SentinelManager::removeMasterProvider, create CloseSentinelManagerTask for ${getSentinelManagerStatus()}"
                        )
                    }
                    spawn {
                        Thread.currentThread.name = "SentinelManager-Destory"
                        closeTask.run()
                    }
                }
            }
        }
    }
    private func retain(): Bool {
        synchronized(sentinelManagerMutex) {
            if (!closed.load()) {
                refCount.fetchAdd(1)
                return true
            }
        }
        return false
    }
    public open func initialize() {
        if (initialized.compareAndSwap(false, true)) {
            if (logger.isDebugEnabled()) {
                logger.debug(
                    "SentinelManager::initialize, initialize SentinelManager{id: ${id}, masterName: ${sentinelConfig.masterName}}"
                )
            }
            initListeners()
        }
    }
    private func initListeners() {
        for (sentinel in sentinelConfig.getSentinelHostAndPorts()) {
            let subscriber = getOrBuildSubscriber(sentinel, sentinelSubscribers, sentinelConfig, threadPool)
            let masterName = sentinelConfig.masterName
            let listener = SentinelListener(this, sentinel, subscriber)
            sentinelListeners.append(listener)
            spawn {
                Thread.currentThread.name = "Sentinel-${sentinel}-of-${masterName}"
                listener.run()
            }
        }
        // RedisSubscriber的状态，后续由SentinelListener维护
        sentinelSubscribers.clear()
    }
    public open func switchMaster(newMaster: HostAndPort) {
        checkOpen()
        let oldMaster = currentMaster.load()
        var needSwitch = false
        if (newMaster != oldMaster) {
            if (currentMaster.compareAndSwap(oldMaster, newMaster)) {
                needSwitch = true
                logger.info("Switch to new master at ${newMaster}")
            }
        }
        if (needSwitch) {
            let switchMasterProviders = ArrayList<SentinelMasterProvider>()
            synchronized(sentinelManagerMutex) {
                switchMasterProviders.appendAll(masterProviders)
            }
            for (masterProvider in switchMasterProviders) {
                masterProvider.switchMaster(newMaster)
            }
        }
    }
    public func buildMasterEndPoint(isSubscribedMode: Bool): ClientTcpEndpoint {
        let config = ClientEndpointConfig()
        let hostAndPort = currentMaster.load()
        config.host = hostAndPort.host
        config.port = hostAndPort.port
        sentinelConfig.configTcpEndpointOptions(config)
        let tcpEndpoint = ClientTcpEndpoint(config, threadPool)
        if (!isSubscribedMode) {
            // 添加Redis命令相关的编解码器
            RedisClientBuilder.configEndpoint(tcpEndpoint)
        } else {
            RedisSubscriberBuilder.configEndpoint(tcpEndpoint, RedisSubscriberHandler.getInstance())
        }
        return tcpEndpoint
    }
    private func getSentinelManagerStatus(): String {
        return "SentinelManager{id: ${id}, masterName: ${sentinelConfig.masterName}, reference count: ${refCount.load()}}"
    }
    public open func isClosed(): Bool {
        return closed.load()
    }
    public open func close(): Unit {
        var realClose = false
        synchronized(sentinelManagerMutex) {
            closeTaskRef = None
            if (refCount.load() == 0 && masterProviders.isEmpty()) {
                // 确保不被SentinelMasterProvider引用时，才关闭
                if (closed.compareAndSwap(false, true)) {
                    realClose = true
                    if (logger.isDebugEnabled()) {
                        logger.debug("SentinelManager::close, close ${getSentinelManagerStatus()}")
                    }
                    destorySentinels(sentinelSubscribers, sentinelListeners)
                }
            } else {
                if (logger.isDebugEnabled()) {
                    logger.debug(
                        "SentinelManager::close, abandon CloseSentinelManagerTask, because the ${getSentinelManagerStatus()} is reused"
                    )
                }
            }
        }
        if (realClose) {
            synchronized(initManagerLock) {
                // 从缓存中移除
                sentinelManagers.remove(sentinelConfig)
            }
        }
    }
    private static func getMaster(
        sentinelConfig: SentinelRedisClientConfig,
        threadPool: ThreadPool,
        sentinelSubscribers: HashMap<HostAndPort, RedisSubscriber>
    ): HostAndPort {
        let hostAndPorts = sentinelConfig.getSentinelHostAndPorts()
        let masterName = sentinelConfig.masterName
        var sentinelAvailable = false
        for (hostAndPort in hostAndPorts) {
            try {
                let subscriber = SentinelRedisClientBuilder.buildSentinelSubscriber(
                    hostAndPort,
                    sentinelConfig,
                    threadPool
                )
                let command = RedisCommandBuilder.sentinelGetMasterAddrByName(masterName)
                let getMasterResponse = subscriber.executeCommand<(String, String)>(command)
                sentinelAvailable = true
                sentinelSubscribers.put(hostAndPort, subscriber)
                if (let Some((address, port)) <- getMasterResponse) {
                    let master = HostAndPort(address, UInt16.parse(port))
                    return master
                }
            } catch (ex: Exception) {
                logger.error("Could not get master address from ${hostAndPort}", ex)
            }
        }
        if (sentinelAvailable) {
            throw RedisException("Can connect to sentinel, but ${masterName} seems to be not monitored");
        } else {
            throw RedisException("All sentinels down, cannot determine where ${masterName} is running")
        }
    }
    private static func destorySentinels(
        sentinelSubscribers: HashMap<HostAndPort, RedisSubscriber>,
        sentinelListeners: ArrayList<SentinelListener>
    ) {
        for (listenter in sentinelListeners) {
            listenter.stop()
        }
        sentinelListeners.clear()
        for (subscriber in sentinelSubscribers.values()) {
            subscriber.close()
        }
        sentinelSubscribers.clear()
    }
    private static func getOrBuildSubscriber(
        sentinel: HostAndPort,
        subscribers: HashMap<HostAndPort, RedisSubscriber>,
        sentinelConfig: SentinelRedisClientConfig,
        threadPool: ThreadPool
    ): RedisSubscriber {
        if (let Some(subscriber) <- subscribers.get(sentinel)) {
            return subscriber
        } else {
            return SentinelRedisClientBuilder.buildSentinelSubscriber(sentinel, sentinelConfig, threadPool)
        }
    }
}
class CloseSentinelManagerTask <: Runnable {
    private let sentinelManager: SentinelManager
    public init(sentinelManager: SentinelManager) {
        this.sentinelManager = sentinelManager
    }
    public func run(): Unit {
        try {
            let sleepDuration = sentinelManager.getSentinelConfig().closeSentinelManagerDelayDuration
            if (sleepDuration > Duration.Zero) {
                // 延迟一段时间再关闭, 在该期间内SentinelManager再次被引用则取消关闭
                sleep(sleepDuration)
            }
            sentinelManager.close()
        } catch (ex: Exception) {
            SentinelManager.logger.warn(
                "Failure to close SentinelManager ${sentinelManager.getMasterName()}",
                ex
            )
        }
    }
}
public class SentinelListener {
    private let sentinel: HostAndPort
    private let sentinelManager: SentinelManager
    private let redisSubscriberRef: AtomicOptionReference<RedisSubscriber>
    private let switchMasterListener: SwitchMasterListener
    private let sentinelConfig: SentinelRedisClientConfig
    private let running = AtomicBool(true)
    public init(sentinelManager: SentinelManager, sentinel: HostAndPort, redisSubscriber: RedisSubscriber) {
        this.sentinelManager = sentinelManager
        this.sentinel = sentinel
        this.redisSubscriberRef = AtomicOptionReference<RedisSubscriber>(redisSubscriber)
        this.sentinelConfig = sentinelManager.getSentinelConfig()
        let masterName = sentinelConfig.masterName
        this.switchMasterListener = SwitchMasterListener(masterName, sentinel, sentinelManager)
        redisSubscriber.setSubscriberListener(switchMasterListener)
    }
    public func run() {
        while (running.load()) {
            if (let Some(redisSubscriber) <- redisSubscriberRef.load()) {
                try {
                    // 订阅Master变化
                    redisSubscriber.blockSubscribe("+switch-master")
                } catch (ex: Exception) {
                    SentinelManager.logger.warn("Could not subscriber +switch-master channel from ${sentinel}")
                    // 防止连接未创建成功的情况下,尝试订阅
                    redisSubscriberRef.store(None)
                } finally {
                    redisSubscriber.close()
                }
            }
            if (running.load()) {
                try {
                    let redisSubscriber = SentinelRedisClientBuilder.buildSentinelSubscriber(
                        sentinel,
                        sentinelManager.getSentinelConfig(),
                        sentinelManager.getThreadPool()
                    )
                    redisSubscriber.setSubscriberListener(switchMasterListener)
                    // 新创建的Subscriber，直接获取MasterName
                    let command = RedisCommandBuilder.sentinelGetMasterAddrByName(sentinelConfig.masterName)
                    let getMasterResponse = redisSubscriber.executeCommand<(String, String)>(command)
                    if (let Some((address, port)) <- getMasterResponse) {
                        let master = HostAndPort(address, UInt16.parse(port))
                        sentinelManager.switchMaster(master)
                    }
                    redisSubscriberRef.store(redisSubscriber)
                } catch (ex: Exception) {
                    SentinelManager.logger.warn("Could not get master address from ${sentinel}", ex)
                    sleep(sentinelConfig.subscribeMasterRetryWaitTime)
                }
            }
        }
    }
    public func stop() {
        if (running.compareAndSwap(true, false)) {
            if (let Some(redisSubscriber) <- redisSubscriberRef.load()) {
                redisSubscriber.close()
                redisSubscriberRef.store(None)
            }
        }
    }
}
public class SwitchMasterListener <: SubscriberListener {
    private static let logger: Logger = LoggerFactory.getLogger("redis-sdk")
    private let masterName: String
    private let sentinel: HostAndPort
    private let sentinelManager: SentinelManager
    public init(masterName: String, sentinel: HostAndPort, sentinelManager: SentinelManager) {
        this.masterName = masterName
        this.sentinel = sentinel
        this.sentinelManager = sentinelManager
    }
    public func onMessage(channel: String, message: String): Unit {
        if (logger.isDebugEnabled()) {
            logger.debug("Sentinel ${sentinel} published: ${message}")
        }
        let switchMasterMsg = message.split(" ")
        if (switchMasterMsg.size > 3) {
            if (masterName == switchMasterMsg[0]) {
                let newMaster = HostAndPort.toHostAndPort(switchMasterMsg[3], switchMasterMsg[4])
                sentinelManager.switchMaster(newMaster)
            } else {
                if (logger.isDebugEnabled()) {
                    logger.debug(
                        "Ignoring message on +switch-master for master ${switchMasterMsg[0]}. Our master is ${masterName}"
                    )
                }
            }
        } else {
            if (logger.isDebugEnabled()) {
                logger.debug(
                    "Invalid message received on sentinel ${sentinel} on channel +switch-master: ${masterName}")
            }
        }
    }
    public func onPMessage(pattern: String, channel: String, message: String): Unit {
    }
    public func onSubscribe(channel: String, subscribedChannels: Int64): Unit {
    }
    public func onUnsubscribe(channel: String, subscribedChannels: Int64): Unit {
    }
    public func onPSubscribe(pattern: String, subscribedChannels: Int64): Unit {
    }
    public func onPUnsubscribe(pattern: String, subscribedChannels: Int64): Unit {
    }
    public func onPong(message: String): Unit {
    }
    public func onExceptionCaught(ex: Exception): Unit {
    }
}