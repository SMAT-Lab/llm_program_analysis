package redis_sdk.client.commands
public interface ServerCommands {
    func ping(): String
    func ping(message: String): String
    func echo(message: String): String
    func auth(password: String): String
    func auth(user: String, password: String): String
    func save(): String
    func bgsave(): String
    func bgsaveSchedule(): String
    func bgrewriteaof(): String
    func lastsave(): Int64
    func shutdown(): Unit
    func shutdown(saveMode: SaveMode): Unit
    func shutdown(shutdownParams: ShutdownParams): Unit
    func shutdownAbort(): String
    func info(): String
    func info(section: String): String
    func info(sections: Array<String>): String
    func slaveof(host: String, port: Int64): String
    func slaveofNoOne(): String
    func replicaof(host: String, port: Int64): String
    func replicaofNoOne(): String
    func wait(replicas: Int64, timeout: Int64): Int64
    func waitReplicas(replicas: Int64, timeout: Int64): Int64
    func waitAOF(numLocal: Int64, numReplicas: Int64, timeout: Int64): (Int64, Int64)
    func lolwut(): String
    func lolwut(lolwutParams: LolwutParams): String
    func reset(): String
    func latencyDoctor(): String
}
public interface ServerCommandsBuilder {
    func ping(): ParameterizedRedisCommand<String>
    func ping(message: String): ParameterizedRedisCommand<String>
    func echo(message: String): ParameterizedRedisCommand<String>
    func auth(password: String): ParameterizedRedisCommand<String>
    func auth(user: String, password: String): ParameterizedRedisCommand<String>
    func save(): ParameterizedRedisCommand<String>
    func bgsave(): ParameterizedRedisCommand<String>
    func bgsaveSchedule(): ParameterizedRedisCommand<String>
    func bgrewriteaof(): ParameterizedRedisCommand<String>
    func lastsave(): ParameterizedRedisCommand<Int64>
    func shutdownAbort(): ParameterizedRedisCommand<String>
    func info(): ParameterizedRedisCommand<String>
    func info(section: String): ParameterizedRedisCommand<String>
    func info(sections: Array<String>): ParameterizedRedisCommand<String>
    func slaveof(host: String, port: Int64): ParameterizedRedisCommand<String>
    func slaveofNoOne(): ParameterizedRedisCommand<String>
    func replicaof(host: String, port: Int64): ParameterizedRedisCommand<String>
    func replicaofNoOne(): ParameterizedRedisCommand<String>
    func wait(replicas: Int64, timeout: Int64): ParameterizedRedisCommand<Int64>
    func waitReplicas(replicas: Int64, timeout: Int64): ParameterizedRedisCommand<Int64>
    func waitAOF(numLocal: Int64, numReplicas: Int64, timeout: Int64): ParameterizedRedisCommand<(Int64, Int64)>
    func lolwut(): ParameterizedRedisCommand<String>
    func lolwut(lolwutParams: LolwutParams): ParameterizedRedisCommand<String>
    func reset(): ParameterizedRedisCommand<String>
    func latencyDoctor(): ParameterizedRedisCommand<String>
}
public class ShutdownParams <: CompositeArg {
    private var saveModeVal: ?SaveMode = None
    private var nowVal: Bool = false
    private var forceVal: Bool = false
    public func saveMode(saveMode: SaveMode): ShutdownParams {
        this.saveModeVal = saveMode
        return this
    }
    public func now(): ShutdownParams {
        this.nowVal = true
        return this
    }
    public func force(): ShutdownParams {
        this.forceVal = true
        return this
    }
    public func buildArgs(commandArgs: CommandArgs): Unit {
        if (let Some(saveMode) <- saveModeVal) {
            commandArgs.add(BytesArg(saveMode.getBytes()))
        }
        if (this.nowVal) {
            commandArgs.add(CommandKeyword.NOW);
        }
        if (this.forceVal) {
            commandArgs.add(CommandKeyword.FORCE);
        }
    }
}
public class LolwutParams <: CompositeArg {
    private var versionVal: ?Int64 = None
    private let opargs = ArrayList<String>()
    public func version(version: Int64): LolwutParams {
        this.versionVal = version
        return this
    }
    public func optionalArguments(args: Array<String>): LolwutParams {
        this.opargs.appendAll(args)
        return this
    }
    public func buildArgs(commandArgs: CommandArgs): Unit {
        if (let Some(version) <- versionVal) {
            commandArgs.add(CommandKeyword.VERSION).add(version)
            if (!opargs.isEmpty()) {
                for (oparg in opargs) {
                    commandArgs.add(StringArg(oparg))
                }
            }
        }
    }
}