引入 异步IO
引入 随机
从 日期时间 引入 日期时间

引入 prisma.枚举
从 faker 引入 Faker
从 prisma 引入 Prisma

faker = Faker()

# 数据生成限制的常量

# 基础实体
NUM_USERS = 100  # 创建100个用户记录
NUM_AGENT_BLOCKS = 100  # 创建100个代理块模板

# 每个用户的实体
MIN_GRAPHS_PER_USER = 1  # 每个用户将有1-5个图
MAX_GRAPHS_PER_USER = 5  # 总图数：500-2500 (NUM_USERS * MIN/MAX_GRAPHS)

# 每个图的实体
MIN_NODES_PER_GRAPH = 2  # 每个图将有2-5个节点
MAX_NODES_PER_GRAPH = (
    5  # 总节点数：1000-2500 (GRAPHS_PER_USER * NUM_USERS * MIN/MAX_NODES)
)

# 额外的每个用户实体
MIN_PRESETS_PER_USER = 1  # 每个用户将有1-2个预设
MAX_PRESETS_PER_USER = 5  # 总预设数：500-2500 (NUM_USERS * MIN/MAX_PRESETS)
MIN_AGENTS_PER_USER = 1  # 每个用户将有1-2个代理
MAX_AGENTS_PER_USER = 10  # 总代理数：500-5000 (NUM_USERS * MIN/MAX_AGENTS)

# 执行和审查记录
MIN_EXECUTIONS_PER_GRAPH = 1  # 每个图将有1-5个执行记录
MAX_EXECUTIONS_PER_GRAPH = (
    20  # 总执行数：1000
)

函数 获取图片()
    url = faker.图片URL()
    当 url == "placekitten.com" 时
        url = faker.图片URL()
    返回 url
结束