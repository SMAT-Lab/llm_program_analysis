package access
public class UserGroup <: AccessInfo & AccessorContext {
    public let name: String
    // 用户
    let userMap: HashMap<String, User>
    // 策略
    let policyMap: HashMap<String, Policy>
    public init(name: String) {
        this.name = name
        this.userMap = HashMap<String, User>()
        this.policyMap = HashMap<String, Policy>()
    }
    public func getName(): String {
        name
    }
    public func addUser(user: User) {
        this.userMap[user.getName()] = user
    }
    func addUser(user: String) {
        addUser(User(user))
    }
    func getUserMap(): Array<User> {
        userMap.values().toArray()
    }
    func removeUser(user: User): ?User {
        removeUser(user.getName())
    }
    func removeUser(user: String): ?User {
        this.userMap.remove(user)
    }
    public func addPolicy(policy: Policy) {
        this.policyMap[policy.getName()] = policy
    }
    func removePolicy(policy: Policy): ?Policy {
        removePolicy(policy.getName())
    }
    func removePolicy(policy: String): ?Policy {
        this.policyMap.remove(policy)
    }
    func checkUser(user: User): Bool {
        let result = userMap.contains(user.getName())
        if (!result) {
            user.removeUserGroup(this)
        }
        result
    }
    func checkPolicy(policy: Policy): Bool {
        let result = policyMap.contains(policy.getName())
        if (!result) {
            policy.removeUserGroup(this)
        }
        result
    }
    public func reset() {
        this.userMap.clear()
        this.policyMap.clear()
    }
    public operator func ==(other: AccessInfo): Bool {
        if (let Some(o) = (other as UserGroup)) {
            this.getName() == other.getName() || refEq(this, o)
        } else {
            false
        }
    }
    public operator func !=(other: AccessInfo): Bool {
        !(this == other)
    }
    public func toString(): String {
        "{\"name\": \"${getName()}\", \"user-list\": ${getUserMap()}}"
    }
    public func addUserGroup(userGroup: UserGroup): Unit {}
}