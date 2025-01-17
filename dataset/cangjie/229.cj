package benchmark_client_pooled_conn
public class PooledConnPerformanceTask {
    let tcpEndpoint: ClientTcpEndpoint
    private let totalRequestCount: Int64
    private let executeNum: Int64
    private let message: String
    private let barrier: Barrier
    public init(
        tcpEndpoint: ClientTcpEndpoint,
        totalRequestCount: Int64,
        executeNum: Int64,
        message: String,
        barrier: Barrier
    ) {
        this.tcpEndpoint = tcpEndpoint
        this.totalRequestCount = totalRequestCount
        this.executeNum = executeNum
        this.message = message
        this.barrier = barrier
    }
    public func run() {
        // 等待所有线程一起执行
        barrier.wait()
        var i = 0
        while (TaskController.running.load() && (executeNum == -1 || i < executeNum)) {
            // 发送消息，并收取对应的响应
            let echoRequest = EchoRequest(TaskController.requestIdGenerator.fetchAdd(1), message)
            try (session = tcpEndpoint.createSession()) {
                session.writeAndFlushMessage(echoRequest)
            }
            try {
                let echoResponse = echoRequest.waitForResponse()
                if (TaskController.stopTime.load() == 0) {
                    let totalCount = TaskController.totalInvokeCount.fetchAdd(1)
                    if (totalCount + 1 >= totalRequestCount) {
                        // 设置停止时间
                        TaskController.stopTime.compareAndSwap(0, DateTime.now().toUnixTimeStamp().toMilliseconds());
                    }
                }
                i++
            } catch (ex: Exception) {
                ex.printStackTrace()
                break
            }
        }
    }
}