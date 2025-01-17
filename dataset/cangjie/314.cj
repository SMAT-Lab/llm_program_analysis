package redis_sdk.client.commands.impl
public class TransactionCommandsImpl <: BaseCommand & TransactionCommands {
    public init(commandExecutor: CommandExecutor) {
        super(commandExecutor)
    }
    public func watch(keys: Array<String>): String {
        let command = RedisCommandBuilder.watch(keys)
        return executeCommand<String>(command)
    }
    public func unwatch(): String {
        let command = RedisCommandBuilder.unwatch()
        return executeCommand<String>(command)
    }
}