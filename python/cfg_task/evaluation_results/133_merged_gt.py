import asyncio
import random
from datetime import datetime
import prisma.enums
from faker import Faker
from prisma import Prisma
faker = Faker()
NUM_USERS = 100
NUM_AGENT_BLOCKS = 100
MIN_GRAPHS_PER_USER = 1
MAX_GRAPHS_PER_USER = 5
MIN_NODES_PER_GRAPH = 2
MAX_NODES_PER_GRAPH = 5
MIN_PRESETS_PER_USER = 1
MAX_PRESETS_PER_USER = 5
MIN_AGENTS_PER_USER = 1
MAX_AGENTS_PER_USER = 10
MIN_EXECUTIONS_PER_GRAPH = 1
MAX_EXECUTIONS_PER_GRAPH = 20
MIN_REVIEWS_PER_VERSION = 1
MAX_REVIEWS_PER_VERSION = 5
def get_image():
    url = faker.image_url()
    while 'placekitten.com' in url:
        url = faker.image_url()
    return url
url = faker.image_url()
'placekitten.com' In url
url = faker.image_url()
return url
async def main():
    db = Prisma()
    await db.connect()
    print(f'Inserting {NUM_USERS} users')
    users = []
    for _ in range(NUM_USERS):
        user = await db.user.create(data={'id': str(faker.uuid4()), 'email': faker.unique.email(), 'name': faker.name(), 'metadata': prisma.Json({}), 'integrations': ''})
        users.append(user)
    agent_blocks = []
    print(f'Inserting {NUM_AGENT_BLOCKS} agent blocks')
    for _ in range(NUM_AGENT_BLOCKS):
        block = await db.agentblock.create(data={'name': f'{faker.word()}_{str(faker.uuid4())[:8]}', 'inputSchema': '{}', 'outputSchema': '{}'})
        agent_blocks.append(block)
    agent_graphs = []
    print(f'Inserting {NUM_USERS * MAX_GRAPHS_PER_USER} agent graphs')
    for user in users:
        for _ in range(random.randint(MIN_GRAPHS_PER_USER, MAX_GRAPHS_PER_USER)):
            graph = await db.agentgraph.create(data={'name': faker.sentence(nb_words=3), 'description': faker.text(max_nb_chars=200), 'userId': user.id, 'isActive': True, 'isTemplate': False})
            agent_graphs.append(graph)
    agent_nodes = []
    print(f'Inserting {NUM_USERS * MAX_GRAPHS_PER_USER * MAX_NODES_PER_GRAPH} agent nodes')
    for graph in agent_graphs:
        num_nodes = random.randint(MIN_NODES_PER_GRAPH, MAX_NODES_PER_GRAPH)
        for _ in range(num_nodes):
            block = random.choice(agent_blocks)
            node = await db.agentnode.create(data={'agentBlockId': block.id, 'agentGraphId': graph.id, 'agentGraphVersion': graph.version, 'constantInput': '{}', 'metadata': '{}'})
            agent_nodes.append(node)
    agent_presets = []
    print(f'Inserting {NUM_USERS * MAX_PRESETS_PER_USER} agent presets')
    for user in users:
        num_presets = random.randint(MIN_PRESETS_PER_USER, MAX_PRESETS_PER_USER)
        for _ in range(num_presets):
            graph = random.choice(agent_graphs)
            preset = await db.agentpreset.create(data={'name': faker.sentence(nb_words=3), 'description': faker.text(max_nb_chars=200), 'userId': user.id, 'agentId': graph.id, 'agentVersion': graph.version, 'isActive': True})
            agent_presets.append(preset)
    user_agents = []
    print(f'Inserting {NUM_USERS * MAX_AGENTS_PER_USER} user agents')
    for user in users:
        num_agents = random.randint(MIN_AGENTS_PER_USER, MAX_AGENTS_PER_USER)
        for _ in range(num_agents):
            graph = random.choice(agent_graphs)
            preset = random.choice(agent_presets)
            user_agent = await db.useragent.create(data={'userId': user.id, 'agentId': graph.id, 'agentVersion': graph.version, 'agentPresetId': preset.id, 'isFavorite': random.choice([True, False]), 'isCreatedByUser': random.choice([True, False]), 'isArchived': random.choice([True, False]), 'isDeleted': random.choice([True, False])})
            user_agents.append(user_agent)
    agent_graph_executions = []
    print(f'Inserting {NUM_USERS * MAX_GRAPHS_PER_USER * MAX_EXECUTIONS_PER_GRAPH} agent graph executions')
    graph_execution_data = []
    for graph in agent_graphs:
        user = random.choice(users)
        num_executions = random.randint(MIN_EXECUTIONS_PER_GRAPH, MAX_EXECUTIONS_PER_GRAPH)
        for _ in range(num_executions):
            matching_presets = [p for p in agent_presets if p.agentId == graph.id]
            preset = random.choice(matching_presets) if matching_presets and random.random() < 0.5 else None
            graph_execution_data.append({'agentGraphId': graph.id, 'agentGraphVersion': graph.version, 'userId': user.id, 'executionStatus': prisma.enums.AgentExecutionStatus.COMPLETED, 'startedAt': faker.date_time_this_year(), 'agentPresetId': preset.id if preset else None})
    agent_graph_executions = await db.agentgraphexecution.create_many(data=graph_execution_data)
    agent_graph_executions = await db.agentgraphexecution.find_many()
    print(f'Inserting {NUM_USERS * MAX_GRAPHS_PER_USER * MAX_EXECUTIONS_PER_GRAPH} agent node executions')
    node_execution_data = []
    for execution in agent_graph_executions:
        nodes = [node for node in agent_nodes if node.agentGraphId == execution.agentGraphId]
        for node in nodes:
            node_execution_data.append({'agentGraphExecutionId': execution.id, 'agentNodeId': node.id, 'executionStatus': prisma.enums.AgentExecutionStatus.COMPLETED, 'addedTime': datetime.now()})
    agent_node_executions = await db.agentnodeexecution.create_many(data=node_execution_data)
    agent_node_executions = await db.agentnodeexecution.find_many()
    print(f'Inserting {NUM_USERS * MAX_GRAPHS_PER_USER * MAX_EXECUTIONS_PER_GRAPH} agent node execution input/outputs')
    input_output_data = []
    for node_execution in agent_node_executions:
        input_output_data.append({'name': 'input1', 'data': '{}', 'time': datetime.now(), 'referencedByInputExecId': node_execution.id})
        input_output_data.append({'name': 'output1', 'data': '{}', 'time': datetime.now(), 'referencedByOutputExecId': node_execution.id})
    await db.agentnodeexecutioninputoutput.create_many(data=input_output_data)
    print(f'Inserting {NUM_USERS * MAX_GRAPHS_PER_USER} agent node links')
    for graph in agent_graphs:
        nodes = [node for node in agent_nodes if node.agentGraphId == graph.id]
        if len(nodes) >= 2:
            source_node = nodes[0]
            sink_node = nodes[1]
            await db.agentnodelink.create(data={'agentNodeSourceId': source_node.id, 'sourceName': 'output1', 'agentNodeSinkId': sink_node.id, 'sinkName': 'input1', 'isStatic': False})
    print(f'Inserting {NUM_USERS} analytics details')
    for user in users:
        for _ in range(1):
            await db.analyticsdetails.create(data={'userId': user.id, 'type': faker.word(), 'data': prisma.Json({}), 'dataIndex': faker.word()})
    print(f'Inserting {NUM_USERS} analytics metrics')
    for user in users:
        for _ in range(1):
            await db.analyticsmetrics.create(data={'userId': user.id, 'analyticMetric': faker.word(), 'value': random.uniform(0, 100), 'dataString': faker.word()})
    print(f'Inserting {NUM_USERS} credit transactions')
    for user in users:
        for _ in range(1):
            block = random.choice(agent_blocks)
            await db.credittransaction.create(data={'transactionKey': str(faker.uuid4()), 'userId': user.id, 'blockId': block.id, 'amount': random.randint(1, 100), 'type': prisma.enums.CreditTransactionType.TOP_UP if random.random() < 0.5 else prisma.enums.CreditTransactionType.USAGE, 'metadata': prisma.Json({})})
    profiles = []
    print(f'Inserting {NUM_USERS} profiles')
    for user in users:
        profile = await db.profile.create(data={'userId': user.id, 'name': user.name or faker.name(), 'username': faker.unique.user_name(), 'description': faker.text(), 'links': [faker.url() for _ in range(3)], 'avatarUrl': get_image()})
        profiles.append(profile)
    store_listings = []
    print(f'Inserting {NUM_USERS} store listings')
    for graph in agent_graphs:
        user = random.choice(users)
        listing = await db.storelisting.create(data={'agentId': graph.id, 'agentVersion': graph.version, 'owningUserId': user.id, 'isApproved': random.choice([True, False])})
        store_listings.append(listing)
    store_listing_versions = []
    print(f'Inserting {NUM_USERS} store listing versions')
    for listing in store_listings:
        graph = [g for g in agent_graphs if g.id == listing.agentId][0]
        version = await db.storelistingversion.create(data={'agentId': graph.id, 'agentVersion': graph.version, 'slug': faker.slug(), 'name': graph.name or faker.sentence(nb_words=3), 'subHeading': faker.sentence(), 'videoUrl': faker.url(), 'imageUrls': [get_image() for _ in range(3)], 'description': faker.text(), 'categories': [faker.word() for _ in range(3)], 'isFeatured': random.choice([True, False]), 'isAvailable': True, 'isApproved': random.choice([True, False]), 'storeListingId': listing.id})
        store_listing_versions.append(version)
    print(f'Inserting {NUM_USERS * MAX_REVIEWS_PER_VERSION} store listing reviews')
    for version in store_listing_versions:
        available_reviewers = users.copy()
        random.shuffle(available_reviewers)
        num_reviews = min(random.randint(MIN_REVIEWS_PER_VERSION, MAX_REVIEWS_PER_VERSION), len(available_reviewers))
        for reviewer in available_reviewers[:num_reviews]:
            await db.storelistingreview.create(data={'storeListingVersionId': version.id, 'reviewByUserId': reviewer.id, 'score': random.randint(1, 5), 'comments': faker.text()})
    print(f'Inserting {NUM_USERS} store listing submissions')
    for listing in store_listings:
        version = random.choice(store_listing_versions)
        reviewer = random.choice(users)
        status: prisma.enums.SubmissionStatus = random.choice([prisma.enums.SubmissionStatus.PENDING, prisma.enums.SubmissionStatus.APPROVED, prisma.enums.SubmissionStatus.REJECTED])
        await db.storelistingsubmission.create(data={'storeListingId': listing.id, 'storeListingVersionId': version.id, 'reviewerId': reviewer.id, 'Status': status, 'reviewComments': faker.text()})
    print(f'Inserting {NUM_USERS} api keys')
    for user in users:
        await db.apikey.create(data={'name': faker.word(), 'prefix': str(faker.uuid4())[:8], 'postfix': str(faker.uuid4())[-8:], 'key': str(faker.sha256()), 'status': prisma.enums.APIKeyStatus.ACTIVE, 'permissions': [prisma.enums.APIKeyPermission.EXECUTE_GRAPH, prisma.enums.APIKeyPermission.READ_GRAPH], 'description': faker.text(), 'userId': user.id})
    await db.disconnect()
db = Prisma()
await db.connect()
print(f'Inserting {NUM_USERS} users')
users = []
_
range(NUM_USERS)
user = await db.user.create(data={'id': str(faker.uuid4()), 'email': faker.unique.email(), 'name': faker.name(), 'metadata': prisma.Json({}), 'integrations': ''})
users.append(user)
agent_blocks = []
print(f'Inserting {NUM_AGENT_BLOCKS} agent blocks')
_
range(NUM_AGENT_BLOCKS)
block = await db.agentblock.create(data={'name': f'{faker.word()}_{str(faker.uuid4())[:8]}', 'inputSchema': '{}', 'outputSchema': '{}'})
agent_blocks.append(block)
agent_graphs = []
print(f'Inserting {NUM_USERS * MAX_GRAPHS_PER_USER} agent graphs')
user
users
agent_nodes = []
print(f'Inserting {NUM_USERS * MAX_GRAPHS_PER_USER * MAX_NODES_PER_GRAPH} agent nodes')
_
range(random.randint(MIN_GRAPHS_PER_USER, MAX_GRAPHS_PER_USER))
graph = await db.agentgraph.create(data={'name': faker.sentence(nb_words=3), 'description': faker.text(max_nb_chars=200), 'userId': user.id, 'isActive': True, 'isTemplate': False})
agent_graphs.append(graph)
graph
agent_graphs
num_nodes = random.randint(MIN_NODES_PER_GRAPH, MAX_NODES_PER_GRAPH)
agent_presets = []
print(f'Inserting {NUM_USERS * MAX_PRESETS_PER_USER} agent presets')
_
range(num_nodes)
block = random.choice(agent_blocks)
node = await db.agentnode.create(data={'agentBlockId': block.id, 'agentGraphId': graph.id, 'agentGraphVersion': graph.version, 'constantInput': '{}', 'metadata': '{}'})
agent_nodes.append(node)
user
users
num_presets = random.randint(MIN_PRESETS_PER_USER, MAX_PRESETS_PER_USER)
user_agents = []
print(f'Inserting {NUM_USERS * MAX_AGENTS_PER_USER} user agents')
_
range(num_presets)
graph = random.choice(agent_graphs)
preset = await db.agentpreset.create(data={'name': faker.sentence(nb_words=3), 'description': faker.text(max_nb_chars=200), 'userId': user.id, 'agentId': graph.id, 'agentVersion': graph.version, 'isActive': True})
agent_presets.append(preset)
user
users
num_agents = random.randint(MIN_AGENTS_PER_USER, MAX_AGENTS_PER_USER)
agent_graph_executions = []
print(f'Inserting {NUM_USERS * MAX_GRAPHS_PER_USER * MAX_EXECUTIONS_PER_GRAPH} agent graph executions')
graph_execution_data = []
_
range(num_agents)
graph = random.choice(agent_graphs)
preset = random.choice(agent_presets)
user_agent = await db.useragent.create(data={'userId': user.id, 'agentId': graph.id, 'agentVersion': graph.version, 'agentPresetId': preset.id, 'isFavorite': random.choice([True, False]), 'isCreatedByUser': random.choice([True, False]), 'isArchived': random.choice([True, False]), 'isDeleted': random.choice([True, False])})
user_agents.append(user_agent)
graph
agent_graphs
user = random.choice(users)
num_executions = random.randint(MIN_EXECUTIONS_PER_GRAPH, MAX_EXECUTIONS_PER_GRAPH)
agent_graph_executions = await db.agentgraphexecution.create_many(data=graph_execution_data)
agent_graph_executions = await db.agentgraphexecution.find_many()
print(f'Inserting {NUM_USERS * MAX_GRAPHS_PER_USER * MAX_EXECUTIONS_PER_GRAPH} agent node executions')
node_execution_data = []
_
range(num_executions)
matching_presets = [p for p in agent_presets if p.agentId == graph.id]
preset = random.choice(matching_presets) if matching_presets and random.random() < 0.5 else None
graph_execution_data.append({'agentGraphId': graph.id, 'agentGraphVersion': graph.version, 'userId': user.id, 'executionStatus': prisma.enums.AgentExecutionStatus.COMPLETED, 'startedAt': faker.date_time_this_year(), 'agentPresetId': preset.id if preset else None})
execution
agent_graph_executions
nodes = [node for node in agent_nodes if node.agentGraphId == execution.agentGraphId]
agent_node_executions = await db.agentnodeexecution.create_many(data=node_execution_data)
agent_node_executions = await db.agentnodeexecution.find_many()
print(f'Inserting {NUM_USERS * MAX_GRAPHS_PER_USER * MAX_EXECUTIONS_PER_GRAPH} agent node execution input/outputs')
input_output_data = []
node
nodes
node_execution_data.append({'agentGraphExecutionId': execution.id, 'agentNodeId': node.id, 'executionStatus': prisma.enums.AgentExecutionStatus.COMPLETED, 'addedTime': datetime.now()})
node_execution
agent_node_executions
input_output_data.append({'name': 'input1', 'data': '{}', 'time': datetime.now(), 'referencedByInputExecId': node_execution.id})
input_output_data.append({'name': 'output1', 'data': '{}', 'time': datetime.now(), 'referencedByOutputExecId': node_execution.id})
await db.agentnodeexecutioninputoutput.create_many(data=input_output_data)
print(f'Inserting {NUM_USERS * MAX_GRAPHS_PER_USER} agent node links')
graph
agent_graphs
nodes = [node for node in agent_nodes if node.agentGraphId == graph.id]
len(nodes) GtE 2
print(f'Inserting {NUM_USERS} analytics details')
source_node = nodes[0]
sink_node = nodes[1]
await db.agentnodelink.create(data={'agentNodeSourceId': source_node.id, 'sourceName': 'output1', 'agentNodeSinkId': sink_node.id, 'sinkName': 'input1', 'isStatic': False})
user
users
print(f'Inserting {NUM_USERS} analytics metrics')
_
range(1)
await db.analyticsdetails.create(data={'userId': user.id, 'type': faker.word(), 'data': prisma.Json({}), 'dataIndex': faker.word()})
user
users
print(f'Inserting {NUM_USERS} credit transactions')
_
range(1)
await db.analyticsmetrics.create(data={'userId': user.id, 'analyticMetric': faker.word(), 'value': random.uniform(0, 100), 'dataString': faker.word()})
user
users
profiles = []
print(f'Inserting {NUM_USERS} profiles')
_
range(1)
block = random.choice(agent_blocks)
await db.credittransaction.create(data={'transactionKey': str(faker.uuid4()), 'userId': user.id, 'blockId': block.id, 'amount': random.randint(1, 100), 'type': prisma.enums.CreditTransactionType.TOP_UP if random.random() < 0.5 else prisma.enums.CreditTransactionType.USAGE, 'metadata': prisma.Json({})})
user
users
profile = await db.profile.create(data={'userId': user.id, 'name': user.name or faker.name(), 'username': faker.unique.user_name(), 'description': faker.text(), 'links': [faker.url() for _ in range(3)], 'avatarUrl': get_image()})
profiles.append(profile)
store_listings = []
print(f'Inserting {NUM_USERS} store listings')
graph
agent_graphs
user = random.choice(users)
listing = await db.storelisting.create(data={'agentId': graph.id, 'agentVersion': graph.version, 'owningUserId': user.id, 'isApproved': random.choice([True, False])})
store_listings.append(listing)
store_listing_versions = []
print(f'Inserting {NUM_USERS} store listing versions')
listing
store_listings
graph = [g for g in agent_graphs if g.id == listing.agentId][0]
version = await db.storelistingversion.create(data={'agentId': graph.id, 'agentVersion': graph.version, 'slug': faker.slug(), 'name': graph.name or faker.sentence(nb_words=3), 'subHeading': faker.sentence(), 'videoUrl': faker.url(), 'imageUrls': [get_image() for _ in range(3)], 'description': faker.text(), 'categories': [faker.word() for _ in range(3)], 'isFeatured': random.choice([True, False]), 'isAvailable': True, 'isApproved': random.choice([True, False]), 'storeListingId': listing.id})
store_listing_versions.append(version)
print(f'Inserting {NUM_USERS * MAX_REVIEWS_PER_VERSION} store listing reviews')
version
store_listing_versions
available_reviewers = users.copy()
random.shuffle(available_reviewers)
num_reviews = min(random.randint(MIN_REVIEWS_PER_VERSION, MAX_REVIEWS_PER_VERSION), len(available_reviewers))
print(f'Inserting {NUM_USERS} store listing submissions')
reviewer
available_reviewers[:num_reviews]
await db.storelistingreview.create(data={'storeListingVersionId': version.id, 'reviewByUserId': reviewer.id, 'score': random.randint(1, 5), 'comments': faker.text()})
listing
store_listings
version = random.choice(store_listing_versions)
reviewer = random.choice(users)
status: prisma.enums.SubmissionStatus = random.choice([prisma.enums.SubmissionStatus.PENDING, prisma.enums.SubmissionStatus.APPROVED, prisma.enums.SubmissionStatus.REJECTED])
await db.storelistingsubmission.create(data={'storeListingId': listing.id, 'storeListingVersionId': version.id, 'reviewerId': reviewer.id, 'Status': status, 'reviewComments': faker.text()})
print(f'Inserting {NUM_USERS} api keys')
user
users
await db.apikey.create(data={'name': faker.word(), 'prefix': str(faker.uuid4())[:8], 'postfix': str(faker.uuid4())[-8:], 'key': str(faker.sha256()), 'status': prisma.enums.APIKeyStatus.ACTIVE, 'permissions': [prisma.enums.APIKeyPermission.EXECUTE_GRAPH, prisma.enums.APIKeyPermission.READ_GRAPH], 'description': faker.text(), 'userId': user.id})
await db.disconnect()
__name__ Eq '__main__'
asyncio.run(main())