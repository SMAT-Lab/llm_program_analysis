package mqtt4cj.mqttv3
public class MqttConnectOptions <: ToString {
    public static let KEEP_ALIVE_INTERVAL_DEFAULT: Int64 = 60
    public static let CONNECTION_TIMEOUT_DEFAULT: Int64 = 30
    public static let MAX_INFLIGHT_DEFAULT: Int64 = 10
    public static let CLEAN_SESSION_DEFAULT: Bool = true
    public static let MQTT_VERSION_DEFAULT: Int64 = 0
    public static let MQTT_VERSION_3_1: Int64 = 3
    public static let MQTT_VERSION_3_1_1: Int64 = 4
    private var maxInflight: Int64 = MAX_INFLIGHT_DEFAULT
    private var mqttVersion: Int64 = MQTT_VERSION_DEFAULT
    private var cleanSession: Bool = CLEAN_SESSION_DEFAULT
    private var connectionTimeout: Duration = Duration.second * CONNECTION_TIMEOUT_DEFAULT
    private var keepAliveInterval: Duration = Duration.second * KEEP_ALIVE_INTERVAL_DEFAULT
    private var automaticReconnect: Bool = false
    private var skipPortDuringHandshake: Bool = false
    private var httpsHostnameVerificationEnabled: Bool = true
    private var maxReconnectDelay: Duration = Duration.millisecond * 128000
    private var userName: ?String = None
    private var userpass: ?Array<Rune> = None
    private var willDestination: ?String = None
    private var willMessage: ?MqttMessage = None
    private var serverURIs: ?Array<String> = None
    private var socketFactory: ?SocketFactory = None
    private var tlsClientConfig: ?TlsClientConfig = None
    private var sslClientProps: ?HashMap<String, ToString> = None
    private var customWebSocketHeaders: ?HashMap<String, String> = None
    // Client Operation Parameters
    // private var executorServiceTimeout:Int64 = 1 // How long to wait in seconds when terminating the executor service.
    public init() {
        // Initialise Base MqttConnectOptions Any
    }
    public func getPassword(): ?Array<Rune> {
        return userpass
    }
    public func setPassword(userpass: ?Array<Rune>): Unit {
        this.userpass = userpass?.clone()
    }
    public func getUserName(): ?String {
        return userName
    }
    public func setUserName(userName: ?String): Unit {
        this.userName = userName
    }
    public func getMaxReconnectDelay(): Duration {
        return maxReconnectDelay
    }
    public func setMaxReconnectDelay(maxReconnectDelay: Duration): Unit {
        this.maxReconnectDelay = maxReconnectDelay
    }
    public func setWill(topic: MqttTopic, payload: Array<Byte>, qos: Int64, retained: Bool): Unit {
        let topicS: String = topic.getName()
        validateWill(topicS, payload)
        this.setWill(topicS, MqttMessage(payload), qos, retained)
    }
    public func setWill(topic: String, payload: Array<Byte>, qos: Int64, retained: Bool): Unit {
        validateWill(topic, payload)
        this.setWill(topic, MqttMessage(payload), qos, retained)
    }
    private func validateWill(dest: String, _: Any): Unit {
        MqttTopic.validate(dest, false)
    }
    protected func setWill(topic: String, msg: MqttMessage, qos: Int64, retained: Bool): Unit {
        willDestination = topic
        msg.setQos(qos)
        msg.setRetained(retained)
        // Prevent any more changes to the will message
        msg.setMutable(false)
        willMessage = msg
    }
    public func getKeepAliveInterval(): Duration {
        return keepAliveInterval
    }
    public func setKeepAliveInterval(keepAliveInterval: Duration): Unit {
        this.keepAliveInterval = keepAliveInterval
    }
    public func getMqttVersion(): Int64 {
        return mqttVersion
    }
    public func setMqttVersion(mqttVersion: Int64): Unit {
        if (mqttVersion != MQTT_VERSION_DEFAULT && mqttVersion != MQTT_VERSION_3_1 && mqttVersion != MQTT_VERSION_3_1_1) {
            throw IllegalArgumentException(
                "An incorrect version was used \"${mqttVersion}\". Acceptable version options are ${MQTT_VERSION_DEFAULT}, ${MQTT_VERSION_3_1} and ${MQTT_VERSION_3_1_1}."
            )
        }
        this.mqttVersion = mqttVersion
    }
    public func getMaxInflight(): Int64 {
        return maxInflight
    }
    public func setMaxInflight(maxInflight: Int64): Unit {
        if (maxInflight < 0) {
            throw IllegalArgumentException()
        }
        this.maxInflight = maxInflight
    }
    public func getConnectionTimeout(): Duration {
        return connectionTimeout
    }
    public func setConnectionTimeout(connectionTimeout: Duration): Unit {
        this.connectionTimeout = connectionTimeout
    }
    public func getSocketFactory(): ?SocketFactory {
        return socketFactory
    }
    public func setSocketFactory(socketFactory: ?SocketFactory): Unit {
        this.socketFactory = socketFactory
    }
    public func getTlsClientConfig(): ?TlsClientConfig {
        return tlsClientConfig
    }
    public func setTlsClientConfig(tlsClientConfig: ?TlsClientConfig): Unit {
        this.tlsClientConfig = tlsClientConfig
    }
    public func getWillDestination(): ?String {
        return willDestination
    }
    public func getWillMessage(): ?MqttMessage {
        return willMessage
    }
    public func isCleanSession(): Bool {
        return this.cleanSession
    }
    public func setCleanSession(cleanSession: Bool): Unit {
        this.cleanSession = cleanSession
    }
    public func getServerURIs(): ?Array<String> {
        return serverURIs
    }
    public func setServerURIs(serverURIs: Array<String>): Unit {
        for (serverURI in serverURIs) {
            NetworkModuleService.validateURI(serverURI)
        }
        this.serverURIs = serverURIs.clone()
    }
    public func isAutomaticReconnect(): Bool {
        return automaticReconnect
    }
    public func setAutomaticReconnect(automaticReconnect: Bool): Unit {
        this.automaticReconnect = automaticReconnect
    }
    public func isSkipPortDuringHandshake(): Bool {
        return skipPortDuringHandshake
    }
    public func setSkipPortDuringHandshake(skip: Bool): Unit {
        this.skipPortDuringHandshake = skip
    }
    public func getDebug(): HashMap<String, ToString> {
        let strNull: String = "None"
        let p: HashMap<String, ToString> = HashMap<String, ToString>()
        p.put("MqttVersion", getMqttVersion())
        p.put("CleanSession", isCleanSession())
        p.put("ConTimeout", getConnectionTimeout())
        p.put("KeepAliveInterval", getKeepAliveInterval())
        p.put("UserName", getUserName() ?? strNull)
        p.put("WillDestination", getWillDestination() ?? strNull)
        if (getSocketFactory().isNone()) {
            p.put("SocketFactory", strNull)
        } else {
            p.put("SocketFactory", "SocketFactory")
        }
        if (getTlsClientConfig().isNone()) {
            p.put("TlsClientConfig", strNull)
        } else {
            p.put("TlsClientConfig", "TlsClientConfig")
        }
        p.put("SkipPortDuringHandshake", isSkipPortDuringHandshake())
        return p
    }
    public func getCustomWebSocketHeaders(): ?HashMap<String, String> {
        return customWebSocketHeaders
    }
    public func setCustomWebSocketHeaders(props: ?HashMap<String, String>): Unit {
        this.customWebSocketHeaders = props
    }
    public func toString(): String {
        return "Connection options"
    }
}