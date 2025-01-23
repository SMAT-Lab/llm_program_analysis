package redis_sdk.client
public open class RedisSubscriberBuilder <: RedisClientBuilderBase {
    public static func builder(): RedisSubscriberBuilder {
        return RedisSubscriberBuilder()
    }
    public static func builder(clientConfig: RedisClientConfig): RedisSubscriberBuilder {
        return RedisSubscriberBuilder(clientConfig)
    }
    public static func buildRedisSubscriber(host: String, port: UInt16): RedisSubscriber {
        let clientBuilder = builder()
        return clientBuilder.host(host).port(port).build()
    }
    public static func buildRedisSubscriber(host: String, port: UInt16, password: String): RedisSubscriber {
        let clientBuilder = builder()
        return clientBuilder.host(host).port(port).password(password).build()
    }
    public static func buildRedisSubscriber(host: String, port: UInt16, user: String, password: String): RedisSubscriber {
        let clientBuilder = builder()
        return clientBuilder.host(host).port(port).user(user).password(password).build()
    }
    let redisClientConfig: RedisClientConfig
    protected init() {
        this(RedisClientConfig())
    }
    protected init(clientConfig: RedisClientConfig) {
        super(clientConfig)
        this.redisClientConfig = clientConfig
    }
    public func host(host: String) {
        redisClientConfig.host = host
        return this
    }
    public func port(port: UInt16) {
        redisClientConfig.port = port
        return this
    }
    public func checkSubscribeMessageInterval(checkSubscribeMessageInterval: Duration) {
        redisClientConfig.checkSubscribeMessageInterval = checkSubscribeMessageInterval
        return this
    }
    public open func build(): RedisSubscriber {
        let tcpEndpoint = RedisClientBuilder.buildClientEndPoint(this.redisClientConfig)
        let subscribeHandler = RedisSubscriberHandler.getInstance()
        configEndpoint(tcpEndpoint, subscribeHandler)
        let commandExecutor = DefaultCommandExecutor(tcpEndpoint)
        let redisSubscriber = RedisSubscriber(commandExecutor, subscribeHandler)
        redisSubscriber.setCheckSubscribeMessageInterval(redisClientConfig.checkSubscribeMessageInterval)
        let handshakeInfo = RedisClientBuilder.getHandShakeInfo(this.redisClientConfig)
        let clientInitializer: RedisClientInitializer = RedisClientInitializer(
            commandExecutor.getRespVersionAware(),
            handshakeInfo,
            redisClientConfig.waitResponseTimeout
        )
        tcpEndpoint.setConnectionInitializer(clientInitializer)
        tcpEndpoint.start()
        return redisSubscriber
    }
    public static func configEndpoint(tcpEndpoint: ClientTcpEndpoint, subscribeHandler: RedisSubscriberHandler) {
        // RedisCodec
        let encoder = RedisCommandToByteEncoder()
        let decoder = ByteToRedisMessageDecoder()
        let redisCodec = RedisCodec(encoder, decoder)
        tcpEndpoint.setMessageCompletedHandler(decoder)
        // RedisSubscriberHandler
        tcpEndpoint.addFilter(redisCodec)
        tcpEndpoint.addFilter(subscribeHandler)
    }
}