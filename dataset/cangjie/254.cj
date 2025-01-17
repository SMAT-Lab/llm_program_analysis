package orm
public interface RootService {
    func executor(name: String): SqlExecutor {
        if (name.isEmpty()) {
            ORM.executor()
        } else {
            ORM.executor(name)
        }
    }
    func executor(): SqlExecutor {
        ORM.executor()
    }
}