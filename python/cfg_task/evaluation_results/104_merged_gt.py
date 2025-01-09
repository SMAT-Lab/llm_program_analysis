import datetime
import typing
import fuzzywuzzy.fuzz
import prisma.enums
import prisma.errors
import prisma.models
import prisma.types
import pydantic
import market.model
import market.utils.extension_types
class AgentQueryError(Exception):
    """Custom exception for agent query errors"""
    pass
'Custom exception for agent query errors'
pass
class TopAgentsDBResponse(pydantic.BaseModel):
    """
    Represents a response containing a list of top agents.

    Attributes:
        analytics (list[AgentResponse]): The list of top agents.
        total_count (int): The total count of agents.
        page (int): The current page number.
        page_size (int): The number of agents per page.
        total_pages (int): The total number of pages.
    """
    analytics: list[prisma.models.AnalyticsTracker]
    total_count: int
    page: int
    page_size: int
    total_pages: int
'\n    Represents a response containing a list of top agents.\n\n    Attributes:\n        analytics (list[AgentResponse]): The list of top agents.\n        total_count (int): The total count of agents.\n        page (int): The current page number.\n        page_size (int): The number of agents per page.\n        total_pages (int): The total number of pages.\n    '
analytics: list[prisma.models.AnalyticsTracker]
total_count: int
page: int
page_size: int
total_pages: int
class FeaturedAgentResponse(pydantic.BaseModel):
    """
    Represents a response containing a list of featured agents.

    Attributes:
        featured_agents (list[FeaturedAgent]): The list of featured agents.
        total_count (int): The total count of featured agents.
        page (int): The current page number.
        page_size (int): The number of agents per page.
        total_pages (int): The total number of pages.
    """
    featured_agents: list[prisma.models.FeaturedAgent]
    total_count: int
    page: int
    page_size: int
    total_pages: int
'\n    Represents a response containing a list of featured agents.\n\n    Attributes:\n        featured_agents (list[FeaturedAgent]): The list of featured agents.\n        total_count (int): The total count of featured agents.\n        page (int): The current page number.\n        page_size (int): The number of agents per page.\n        total_pages (int): The total number of pages.\n    '
featured_agents: list[prisma.models.FeaturedAgent]
total_count: int
page: int
page_size: int
total_pages: int
async def delete_agent(agent_id: str) -> prisma.models.Agents | None:
    """
    Delete an agent from the database.

    Args:
        agent_id (str): The ID of the agent to delete.

    Returns:
        prisma.models.Agents | None: The deleted agent if found, None otherwise.

    Raises:
        AgentQueryError: If there is an error deleting the agent from the database.
    """
    try:
        deleted_agent = await prisma.models.Agents.prisma().delete(where={'id': agent_id})
        return deleted_agent
    except prisma.errors.PrismaError as e:
        raise AgentQueryError(f'Database query failed: {str(e)}')
    except Exception as e:
        raise AgentQueryError(f'Unexpected error occurred: {str(e)}')
'\n    Delete an agent from the database.\n\n    Args:\n        agent_id (str): The ID of the agent to delete.\n\n    Returns:\n        prisma.models.Agents | None: The deleted agent if found, None otherwise.\n\n    Raises:\n        AgentQueryError: If there is an error deleting the agent from the database.\n    '
try:
    deleted_agent = await prisma.models.Agents.prisma().delete(where={'id': agent_id})
    return deleted_agent
except prisma.errors.PrismaError as e:
    raise AgentQueryError(f'Database query failed: {str(e)}')
except Exception as e:
    raise AgentQueryError(f'Unexpected error occurred: {str(e)}')
deleted_agent = await prisma.models.Agents.prisma().delete(where={'id': agent_id})
return deleted_agent
raise AgentQueryError(f'Database query failed: {str(e)}')
raise AgentQueryError(f'Unexpected error occurred: {str(e)}')
async def create_agent_entry(name: str, description: str, author: str, keywords: typing.List[str], categories: typing.List[str], graph: prisma.Json, submission_state: prisma.enums.SubmissionStatus=prisma.enums.SubmissionStatus.PENDING):
    """
    Create a new agent entry in the database.

    Args:
        name (str): The name of the agent.
        description (str): The description of the agent.
        author (str): The author of the agent.
        keywords (List[str]): The keywords associated with the agent.
        categories (List[str]): The categories associated with the agent.
        graph (dict): The graph data of the agent.

    Returns:
        dict: The newly created agent entry.

    Raises:
        AgentQueryError: If there is an error creating the agent entry.
    """
    try:
        agent = await prisma.models.Agents.prisma().create(data={'name': name, 'description': description, 'author': author, 'keywords': keywords, 'categories': categories, 'graph': graph, 'AnalyticsTracker': {'create': {'downloads': 0, 'views': 0}}, 'submissionStatus': submission_state})
        return agent
    except prisma.errors.PrismaError as e:
        raise AgentQueryError(f'Database query failed: {str(e)}')
    except Exception as e:
        raise AgentQueryError(f'Unexpected error occurred: {str(e)}')
'\n    Create a new agent entry in the database.\n\n    Args:\n        name (str): The name of the agent.\n        description (str): The description of the agent.\n        author (str): The author of the agent.\n        keywords (List[str]): The keywords associated with the agent.\n        categories (List[str]): The categories associated with the agent.\n        graph (dict): The graph data of the agent.\n\n    Returns:\n        dict: The newly created agent entry.\n\n    Raises:\n        AgentQueryError: If there is an error creating the agent entry.\n    '
try:
    agent = await prisma.models.Agents.prisma().create(data={'name': name, 'description': description, 'author': author, 'keywords': keywords, 'categories': categories, 'graph': graph, 'AnalyticsTracker': {'create': {'downloads': 0, 'views': 0}}, 'submissionStatus': submission_state})
    return agent
except prisma.errors.PrismaError as e:
    raise AgentQueryError(f'Database query failed: {str(e)}')
except Exception as e:
    raise AgentQueryError(f'Unexpected error occurred: {str(e)}')
agent = await prisma.models.Agents.prisma().create(data={'name': name, 'description': description, 'author': author, 'keywords': keywords, 'categories': categories, 'graph': graph, 'AnalyticsTracker': {'create': {'downloads': 0, 'views': 0}}, 'submissionStatus': submission_state})
return agent
raise AgentQueryError(f'Database query failed: {str(e)}')
raise AgentQueryError(f'Unexpected error occurred: {str(e)}')
async def update_agent_entry(agent_id: str, version: int, submission_state: prisma.enums.SubmissionStatus, comments: str | None=None) -> prisma.models.Agents | None:
    """
    Update an existing agent entry in the database.

    Args:
        agent_id (str): The ID of the agent.
        version (int): The version of the agent.
        submission_state (prisma.enums.SubmissionStatus): The submission state of the agent.
    """
    try:
        agent = await prisma.models.Agents.prisma().update(where={'id': agent_id}, data={'version': version, 'submissionStatus': submission_state, 'submissionReviewDate': datetime.datetime.now(datetime.timezone.utc), 'submissionReviewComments': comments})
        return agent
    except prisma.errors.PrismaError as e:
        raise AgentQueryError(f'Agent Update Failed Database query failed: {str(e)}')
    except Exception as e:
        raise AgentQueryError(f'Unexpected error occurred: {str(e)}')
'\n    Update an existing agent entry in the database.\n\n    Args:\n        agent_id (str): The ID of the agent.\n        version (int): The version of the agent.\n        submission_state (prisma.enums.SubmissionStatus): The submission state of the agent.\n    '
try:
    agent = await prisma.models.Agents.prisma().update(where={'id': agent_id}, data={'version': version, 'submissionStatus': submission_state, 'submissionReviewDate': datetime.datetime.now(datetime.timezone.utc), 'submissionReviewComments': comments})
    return agent
except prisma.errors.PrismaError as e:
    raise AgentQueryError(f'Agent Update Failed Database query failed: {str(e)}')
except Exception as e:
    raise AgentQueryError(f'Unexpected error occurred: {str(e)}')
agent = await prisma.models.Agents.prisma().update(where={'id': agent_id}, data={'version': version, 'submissionStatus': submission_state, 'submissionReviewDate': datetime.datetime.now(datetime.timezone.utc), 'submissionReviewComments': comments})
return agent
raise AgentQueryError(f'Agent Update Failed Database query failed: {str(e)}')
raise AgentQueryError(f'Unexpected error occurred: {str(e)}')
async def get_agents(page: int=1, page_size: int=10, name: str | None=None, keyword: str | None=None, category: str | None=None, description: str | None=None, description_threshold: int=60, submission_status: prisma.enums.SubmissionStatus=prisma.enums.SubmissionStatus.APPROVED, sort_by: str='createdAt', sort_order: typing.Literal['desc'] | typing.Literal['asc']='desc'):
    """
    Retrieve a list of agents from the database based on the provided filters and pagination parameters.

    Args:
        page (int, optional): The page number to retrieve. Defaults to 1.
        page_size (int, optional): The number of agents per page. Defaults to 10.
        name (str, optional): Filter agents by name. Defaults to None.
        keyword (str, optional): Filter agents by keyword. Defaults to None.
        category (str, optional): Filter agents by category. Defaults to None.
        description (str, optional): Filter agents by description. Defaults to None.
        description_threshold (int, optional): The minimum fuzzy search threshold for the description. Defaults to 60.
        sort_by (str, optional): The field to sort the agents by. Defaults to "createdAt".
        sort_order (str, optional): The sort order ("asc" or "desc"). Defaults to "desc".

    Returns:
        dict: A dictionary containing the list of agents, total count, current page number, page size, and total number of pages.
    """
    try:
        query = {}
        if name:
            query['name'] = {'contains': name, 'mode': 'insensitive'}
        if keyword:
            query['keywords'] = {'has': keyword}
        if category:
            query['categories'] = {'has': category}
        query['submissionStatus'] = submission_status
        order = {sort_by: sort_order}
        skip = (page - 1) * page_size
        try:
            agents = await prisma.models.Agents.prisma().find_many(where=query, order=order, skip=skip, take=page_size)
        except prisma.errors.PrismaError as e:
            raise AgentQueryError(f'Database query failed: {str(e)}')
        if description:
            try:
                filtered_agents = []
                for agent in agents:
                    if agent.description and fuzzywuzzy.fuzz.partial_ratio(description.lower(), agent.description.lower()) >= description_threshold:
                        filtered_agents.append(agent)
                agents = filtered_agents
            except AttributeError as e:
                raise AgentQueryError(f'Error during fuzzy search: {str(e)}')
        total_count = len(agents)
        return {'agents': agents, 'total_count': total_count, 'page': page, 'page_size': page_size, 'total_pages': (total_count + page_size - 1) // page_size}
    except AgentQueryError as e:
        raise e
    except ValueError as e:
        raise AgentQueryError(f'Invalid input parameter: {str(e)}')
    except Exception as e:
        raise AgentQueryError(f'Unexpected error occurred: {str(e)}')
'\n    Retrieve a list of agents from the database based on the provided filters and pagination parameters.\n\n    Args:\n        page (int, optional): The page number to retrieve. Defaults to 1.\n        page_size (int, optional): The number of agents per page. Defaults to 10.\n        name (str, optional): Filter agents by name. Defaults to None.\n        keyword (str, optional): Filter agents by keyword. Defaults to None.\n        category (str, optional): Filter agents by category. Defaults to None.\n        description (str, optional): Filter agents by description. Defaults to None.\n        description_threshold (int, optional): The minimum fuzzy search threshold for the description. Defaults to 60.\n        sort_by (str, optional): The field to sort the agents by. Defaults to "createdAt".\n        sort_order (str, optional): The sort order ("asc" or "desc"). Defaults to "desc".\n\n    Returns:\n        dict: A dictionary containing the list of agents, total count, current page number, page size, and total number of pages.\n    '
try:
    query = {}
    if name:
        query['name'] = {'contains': name, 'mode': 'insensitive'}
    if keyword:
        query['keywords'] = {'has': keyword}
    if category:
        query['categories'] = {'has': category}
    query['submissionStatus'] = submission_status
    order = {sort_by: sort_order}
    skip = (page - 1) * page_size
    try:
        agents = await prisma.models.Agents.prisma().find_many(where=query, order=order, skip=skip, take=page_size)
    except prisma.errors.PrismaError as e:
        raise AgentQueryError(f'Database query failed: {str(e)}')
    if description:
        try:
            filtered_agents = []
            for agent in agents:
                if agent.description and fuzzywuzzy.fuzz.partial_ratio(description.lower(), agent.description.lower()) >= description_threshold:
                    filtered_agents.append(agent)
            agents = filtered_agents
        except AttributeError as e:
            raise AgentQueryError(f'Error during fuzzy search: {str(e)}')
    total_count = len(agents)
    return {'agents': agents, 'total_count': total_count, 'page': page, 'page_size': page_size, 'total_pages': (total_count + page_size - 1) // page_size}
except AgentQueryError as e:
    raise e
except ValueError as e:
    raise AgentQueryError(f'Invalid input parameter: {str(e)}')
except Exception as e:
    raise AgentQueryError(f'Unexpected error occurred: {str(e)}')
query = {}
name
query['name'] = {'contains': name, 'mode': 'insensitive'}
keyword
query['keywords'] = {'has': keyword}
category
query['categories'] = {'has': category}
query['submissionStatus'] = submission_status
order = {sort_by: sort_order}
skip = (page - 1) * page_size
try:
    agents = await prisma.models.Agents.prisma().find_many(where=query, order=order, skip=skip, take=page_size)
except prisma.errors.PrismaError as e:
    raise AgentQueryError(f'Database query failed: {str(e)}')
agents = await prisma.models.Agents.prisma().find_many(where=query, order=order, skip=skip, take=page_size)
raise AgentQueryError(f'Database query failed: {str(e)}')
description
try:
    filtered_agents = []
    for agent in agents:
        if agent.description and fuzzywuzzy.fuzz.partial_ratio(description.lower(), agent.description.lower()) >= description_threshold:
            filtered_agents.append(agent)
    agents = filtered_agents
except AttributeError as e:
    raise AgentQueryError(f'Error during fuzzy search: {str(e)}')
filtered_agents = []
total_count = len(agents)
return {'agents': agents, 'total_count': total_count, 'page': page, 'page_size': page_size, 'total_pages': (total_count + page_size - 1) // page_size}
agent
agents
agent.description and fuzzywuzzy.fuzz.partial_ratio(description.lower(), agent.description.lower()) >= description_threshold
agents = filtered_agents
raise AgentQueryError(f'Error during fuzzy search: {str(e)}')
filtered_agents.append(agent)
raise e
raise AgentQueryError(f'Invalid input parameter: {str(e)}')
raise AgentQueryError(f'Unexpected error occurred: {str(e)}')
async def get_agent_details(agent_id: str, version: int | None=None):
    """
    Retrieve agent details from the database.

    Args:
        agent_id (str): The ID of the agent.
        version (int | None, optional): The version of the agent. Defaults to None.

    Returns:
        dict: The agent details.

    Raises:
        AgentQueryError: If the agent is not found or if there is an error querying the database.
    """
    try:
        query = {'id': agent_id}
        if version is not None:
            query['version'] = version
        agent = await prisma.models.Agents.prisma().find_first(where=query)
        if not agent:
            raise AgentQueryError('Agent not found')
        return agent
    except prisma.errors.PrismaError as e:
        raise AgentQueryError(f'Database query failed: {str(e)}')
    except Exception as e:
        raise AgentQueryError(f'Unexpected error occurred: {str(e)}')
'\n    Retrieve agent details from the database.\n\n    Args:\n        agent_id (str): The ID of the agent.\n        version (int | None, optional): The version of the agent. Defaults to None.\n\n    Returns:\n        dict: The agent details.\n\n    Raises:\n        AgentQueryError: If the agent is not found or if there is an error querying the database.\n    '
try:
    query = {'id': agent_id}
    if version is not None:
        query['version'] = version
    agent = await prisma.models.Agents.prisma().find_first(where=query)
    if not agent:
        raise AgentQueryError('Agent not found')
    return agent
except prisma.errors.PrismaError as e:
    raise AgentQueryError(f'Database query failed: {str(e)}')
except Exception as e:
    raise AgentQueryError(f'Unexpected error occurred: {str(e)}')
query = {'id': agent_id}
version IsNot None
query['version'] = version
agent = await prisma.models.Agents.prisma().find_first(where=query)
not agent
raise AgentQueryError('Agent not found')
return agent
raise AgentQueryError(f'Database query failed: {str(e)}')
raise AgentQueryError(f'Unexpected error occurred: {str(e)}')
async def search_db(query: str, page: int=1, page_size: int=10, categories: typing.List[str] | None=None, description_threshold: int=60, sort_by: str='rank', sort_order: typing.Literal['desc'] | typing.Literal['asc']='desc', submission_status: prisma.enums.SubmissionStatus=prisma.enums.SubmissionStatus.APPROVED) -> market.model.ListResponse[market.utils.extension_types.AgentsWithRank]:
    """Perform a search for agents based on the provided query string.

    Args:
        query (str): the search string
        page (int, optional): page for searching. Defaults to 1.
        page_size (int, optional): the number of results to return. Defaults to 10.
        categories (List[str] | None, optional): list of category filters. Defaults to None.
        description_threshold (int, optional): number of characters to return. Defaults to 60.
        sort_by (str, optional): sort by option. Defaults to "rank".
        sort_order ("asc" | "desc", optional): the sort order. Defaults to "desc".

    Raises:
        AgentQueryError: Raises an error if the query fails.
        AgentQueryError: Raises if an unexpected error occurs.

    Returns:
        List[AgentsWithRank]: List of agents matching the search criteria.
    """
    try:
        offset = (page - 1) * page_size
        category_filter = '1=1'
        if categories:
            category_conditions = [f"'{cat}' = ANY(categories)" for cat in categories]
            category_filter = 'AND (' + ' OR '.join(category_conditions) + ')'
        if sort_by in ['createdAt', 'updatedAt']:
            order_by_clause = f'"{sort_by}" {sort_order.upper()}, rank DESC'
        elif sort_by == 'name':
            order_by_clause = f'name {sort_order.upper()}, rank DESC'
        else:
            order_by_clause = 'rank DESC, "createdAt" DESC'
        submission_status_filter = f""""submissionStatus" = '{submission_status}'"""
        sql_query = f"""\n        WITH query AS (\n            SELECT to_tsquery(string_agg(lexeme || ':*', ' & ' ORDER BY positions)) AS q \n            FROM unnest(to_tsvector('{query}'))\n        )\n        SELECT \n            id, \n            "createdAt", \n            "updatedAt", \n            version, \n            name, \n            LEFT(description, {description_threshold}) AS description, \n            author, \n            keywords, \n            categories, \n            graph,\n            "submissionStatus",\n            "submissionDate",\n            CASE \n                WHEN query.q::text = '' THEN 1.0\n                ELSE COALESCE(ts_rank(CAST(search AS tsvector), query.q), 0.0)\n            END AS rank\n        FROM market."Agents", query\n        WHERE \n            (query.q::text = '' OR search @@ query.q)\n            AND {category_filter} \n            AND {submission_status_filter}\n        ORDER BY {order_by_clause}\n        LIMIT {page_size}\n        OFFSET {offset};\n        """
        results = await prisma.client.get_client().query_raw(query=sql_query, model=market.utils.extension_types.AgentsWithRank)

        class CountResponse(pydantic.BaseModel):
            count: int
        count_query = f"""\n        WITH query AS (\n            SELECT to_tsquery(string_agg(lexeme || ':*', ' & ' ORDER BY positions)) AS q \n            FROM unnest(to_tsvector('{query}'))\n        )\n        SELECT COUNT(*)\n        FROM market."Agents", query\n        WHERE (search @@ query.q OR query.q = '') AND {category_filter} AND {submission_status_filter};\n        """
        total_count = await prisma.client.get_client().query_first(query=count_query, model=CountResponse)
        total_count = total_count.count if total_count else 0
        return market.model.ListResponse(items=results, total_count=total_count, page=page, page_size=page_size, total_pages=(total_count + page_size - 1) // page_size)
    except prisma.errors.PrismaError as e:
        raise AgentQueryError(f'Database query failed: {str(e)}')
    except Exception as e:
        raise AgentQueryError(f'Unexpected error occurred: {str(e)}')
'Perform a search for agents based on the provided query string.\n\n    Args:\n        query (str): the search string\n        page (int, optional): page for searching. Defaults to 1.\n        page_size (int, optional): the number of results to return. Defaults to 10.\n        categories (List[str] | None, optional): list of category filters. Defaults to None.\n        description_threshold (int, optional): number of characters to return. Defaults to 60.\n        sort_by (str, optional): sort by option. Defaults to "rank".\n        sort_order ("asc" | "desc", optional): the sort order. Defaults to "desc".\n\n    Raises:\n        AgentQueryError: Raises an error if the query fails.\n        AgentQueryError: Raises if an unexpected error occurs.\n\n    Returns:\n        List[AgentsWithRank]: List of agents matching the search criteria.\n    '
try:
    offset = (page - 1) * page_size
    category_filter = '1=1'
    if categories:
        category_conditions = [f"'{cat}' = ANY(categories)" for cat in categories]
        category_filter = 'AND (' + ' OR '.join(category_conditions) + ')'
    if sort_by in ['createdAt', 'updatedAt']:
        order_by_clause = f'"{sort_by}" {sort_order.upper()}, rank DESC'
    elif sort_by == 'name':
        order_by_clause = f'name {sort_order.upper()}, rank DESC'
    else:
        order_by_clause = 'rank DESC, "createdAt" DESC'
    submission_status_filter = f""""submissionStatus" = '{submission_status}'"""
    sql_query = f"""\n        WITH query AS (\n            SELECT to_tsquery(string_agg(lexeme || ':*', ' & ' ORDER BY positions)) AS q \n            FROM unnest(to_tsvector('{query}'))\n        )\n        SELECT \n            id, \n            "createdAt", \n            "updatedAt", \n            version, \n            name, \n            LEFT(description, {description_threshold}) AS description, \n            author, \n            keywords, \n            categories, \n            graph,\n            "submissionStatus",\n            "submissionDate",\n            CASE \n                WHEN query.q::text = '' THEN 1.0\n                ELSE COALESCE(ts_rank(CAST(search AS tsvector), query.q), 0.0)\n            END AS rank\n        FROM market."Agents", query\n        WHERE \n            (query.q::text = '' OR search @@ query.q)\n            AND {category_filter} \n            AND {submission_status_filter}\n        ORDER BY {order_by_clause}\n        LIMIT {page_size}\n        OFFSET {offset};\n        """
    results = await prisma.client.get_client().query_raw(query=sql_query, model=market.utils.extension_types.AgentsWithRank)

    class CountResponse(pydantic.BaseModel):
        count: int
    count_query = f"""\n        WITH query AS (\n            SELECT to_tsquery(string_agg(lexeme || ':*', ' & ' ORDER BY positions)) AS q \n            FROM unnest(to_tsvector('{query}'))\n        )\n        SELECT COUNT(*)\n        FROM market."Agents", query\n        WHERE (search @@ query.q OR query.q = '') AND {category_filter} AND {submission_status_filter};\n        """
    total_count = await prisma.client.get_client().query_first(query=count_query, model=CountResponse)
    total_count = total_count.count if total_count else 0
    return market.model.ListResponse(items=results, total_count=total_count, page=page, page_size=page_size, total_pages=(total_count + page_size - 1) // page_size)
except prisma.errors.PrismaError as e:
    raise AgentQueryError(f'Database query failed: {str(e)}')
except Exception as e:
    raise AgentQueryError(f'Unexpected error occurred: {str(e)}')
offset = (page - 1) * page_size
category_filter = '1=1'
categories
category_conditions = [f"'{cat}' = ANY(categories)" for cat in categories]
category_filter = 'AND (' + ' OR '.join(category_conditions) + ')'
sort_by In ['createdAt', 'updatedAt']
order_by_clause = f'"{sort_by}" {sort_order.upper()}, rank DESC'
sort_by Eq 'name'
submission_status_filter = f""""submissionStatus" = '{submission_status}'"""
sql_query = f"""\n        WITH query AS (\n            SELECT to_tsquery(string_agg(lexeme || ':*', ' & ' ORDER BY positions)) AS q \n            FROM unnest(to_tsvector('{query}'))\n        )\n        SELECT \n            id, \n            "createdAt", \n            "updatedAt", \n            version, \n            name, \n            LEFT(description, {description_threshold}) AS description, \n            author, \n            keywords, \n            categories, \n            graph,\n            "submissionStatus",\n            "submissionDate",\n            CASE \n                WHEN query.q::text = '' THEN 1.0\n                ELSE COALESCE(ts_rank(CAST(search AS tsvector), query.q), 0.0)\n            END AS rank\n        FROM market."Agents", query\n        WHERE \n            (query.q::text = '' OR search @@ query.q)\n            AND {category_filter} \n            AND {submission_status_filter}\n        ORDER BY {order_by_clause}\n        LIMIT {page_size}\n        OFFSET {offset};\n        """
results = await prisma.client.get_client().query_raw(query=sql_query, model=market.utils.extension_types.AgentsWithRank)
class CountResponse(pydantic.BaseModel):
    count: int
count: int
count_query = f"""\n        WITH query AS (\n            SELECT to_tsquery(string_agg(lexeme || ':*', ' & ' ORDER BY positions)) AS q \n            FROM unnest(to_tsvector('{query}'))\n        )\n        SELECT COUNT(*)\n        FROM market."Agents", query\n        WHERE (search @@ query.q OR query.q = '') AND {category_filter} AND {submission_status_filter};\n        """
total_count = await prisma.client.get_client().query_first(query=count_query, model=CountResponse)
total_count = total_count.count if total_count else 0
return market.model.ListResponse(items=results, total_count=total_count, page=page, page_size=page_size, total_pages=(total_count + page_size - 1) // page_size)
order_by_clause = f'name {sort_order.upper()}, rank DESC'
order_by_clause = 'rank DESC, "createdAt" DESC'
raise AgentQueryError(f'Database query failed: {str(e)}')
raise AgentQueryError(f'Unexpected error occurred: {str(e)}')
async def get_top_agents_by_downloads(page: int=1, page_size: int=10, submission_status: prisma.enums.SubmissionStatus=prisma.enums.SubmissionStatus.APPROVED) -> market.model.ListResponse[prisma.models.AnalyticsTracker]:
    """Retrieve the top agents by download count.

    Args:
        page (int, optional): The page number. Defaults to 1.
        page_size (int, optional): The number of agents per page. Defaults to 10.

    Returns:
        dict: A dictionary containing the list of agents, total count, current page number, page size, and total number of pages.
    """
    try:
        skip = (page - 1) * page_size
        try:
            analytics = await prisma.models.AnalyticsTracker.prisma().find_many(include={'agent': True}, order={'downloads': 'desc'}, where={'agent': {'is': {'submissionStatus': submission_status}}}, skip=skip, take=page_size)
        except prisma.errors.PrismaError as e:
            raise AgentQueryError(f'Database query failed: {str(e)}')
        try:
            total_count = await prisma.models.AnalyticsTracker.prisma().count(where={'agent': {'is': {'submissionStatus': submission_status}}})
        except prisma.errors.PrismaError as e:
            raise AgentQueryError(f'Database query failed: {str(e)}')
        return market.model.ListResponse(items=analytics, total_count=total_count, page=page, page_size=page_size, total_pages=(total_count + page_size - 1) // page_size)
    except AgentQueryError as e:
        raise e from e
    except ValueError as e:
        raise AgentQueryError(f'Invalid input parameter: {str(e)}') from e
    except Exception as e:
        raise AgentQueryError(f'Unexpected error occurred: {str(e)}') from e
'Retrieve the top agents by download count.\n\n    Args:\n        page (int, optional): The page number. Defaults to 1.\n        page_size (int, optional): The number of agents per page. Defaults to 10.\n\n    Returns:\n        dict: A dictionary containing the list of agents, total count, current page number, page size, and total number of pages.\n    '
try:
    skip = (page - 1) * page_size
    try:
        analytics = await prisma.models.AnalyticsTracker.prisma().find_many(include={'agent': True}, order={'downloads': 'desc'}, where={'agent': {'is': {'submissionStatus': submission_status}}}, skip=skip, take=page_size)
    except prisma.errors.PrismaError as e:
        raise AgentQueryError(f'Database query failed: {str(e)}')
    try:
        total_count = await prisma.models.AnalyticsTracker.prisma().count(where={'agent': {'is': {'submissionStatus': submission_status}}})
    except prisma.errors.PrismaError as e:
        raise AgentQueryError(f'Database query failed: {str(e)}')
    return market.model.ListResponse(items=analytics, total_count=total_count, page=page, page_size=page_size, total_pages=(total_count + page_size - 1) // page_size)
except AgentQueryError as e:
    raise e from e
except ValueError as e:
    raise AgentQueryError(f'Invalid input parameter: {str(e)}') from e
except Exception as e:
    raise AgentQueryError(f'Unexpected error occurred: {str(e)}') from e
skip = (page - 1) * page_size
try:
    analytics = await prisma.models.AnalyticsTracker.prisma().find_many(include={'agent': True}, order={'downloads': 'desc'}, where={'agent': {'is': {'submissionStatus': submission_status}}}, skip=skip, take=page_size)
except prisma.errors.PrismaError as e:
    raise AgentQueryError(f'Database query failed: {str(e)}')
analytics = await prisma.models.AnalyticsTracker.prisma().find_many(include={'agent': True}, order={'downloads': 'desc'}, where={'agent': {'is': {'submissionStatus': submission_status}}}, skip=skip, take=page_size)
raise AgentQueryError(f'Database query failed: {str(e)}')
try:
    total_count = await prisma.models.AnalyticsTracker.prisma().count(where={'agent': {'is': {'submissionStatus': submission_status}}})
except prisma.errors.PrismaError as e:
    raise AgentQueryError(f'Database query failed: {str(e)}')
total_count = await prisma.models.AnalyticsTracker.prisma().count(where={'agent': {'is': {'submissionStatus': submission_status}}})
raise AgentQueryError(f'Database query failed: {str(e)}')
return market.model.ListResponse(items=analytics, total_count=total_count, page=page, page_size=page_size, total_pages=(total_count + page_size - 1) // page_size)
raise e from e
raise AgentQueryError(f'Invalid input parameter: {str(e)}') from e
raise AgentQueryError(f'Unexpected error occurred: {str(e)}') from e
async def set_agent_featured(agent_id: str, is_active: bool=True, featured_categories: list[str]=['featured']) -> prisma.models.FeaturedAgent:
    """Set an agent as featured in the database.

    Args:
        agent_id (str): The ID of the agent.
        category (str, optional): The category to set the agent as featured. Defaults to "featured".

    Raises:
        AgentQueryError: If there is an error setting the agent as featured.
    """
    try:
        agent = await prisma.models.Agents.prisma().find_unique(where={'id': agent_id})
        if not agent:
            raise AgentQueryError(f'Agent with ID {agent_id} not found.')
        featured = await prisma.models.FeaturedAgent.prisma().upsert(where={'agentId': agent_id}, data={'update': {'featuredCategories': featured_categories, 'isActive': is_active}, 'create': {'featuredCategories': featured_categories, 'isActive': is_active, 'agent': {'connect': {'id': agent_id}}}})
        return featured
    except prisma.errors.PrismaError as e:
        raise AgentQueryError(f'Database query failed: {str(e)}')
    except Exception as e:
        raise AgentQueryError(f'Unexpected error occurred: {str(e)}')
'Set an agent as featured in the database.\n\n    Args:\n        agent_id (str): The ID of the agent.\n        category (str, optional): The category to set the agent as featured. Defaults to "featured".\n\n    Raises:\n        AgentQueryError: If there is an error setting the agent as featured.\n    '
try:
    agent = await prisma.models.Agents.prisma().find_unique(where={'id': agent_id})
    if not agent:
        raise AgentQueryError(f'Agent with ID {agent_id} not found.')
    featured = await prisma.models.FeaturedAgent.prisma().upsert(where={'agentId': agent_id}, data={'update': {'featuredCategories': featured_categories, 'isActive': is_active}, 'create': {'featuredCategories': featured_categories, 'isActive': is_active, 'agent': {'connect': {'id': agent_id}}}})
    return featured
except prisma.errors.PrismaError as e:
    raise AgentQueryError(f'Database query failed: {str(e)}')
except Exception as e:
    raise AgentQueryError(f'Unexpected error occurred: {str(e)}')
agent = await prisma.models.Agents.prisma().find_unique(where={'id': agent_id})
not agent
raise AgentQueryError(f'Agent with ID {agent_id} not found.')
featured = await prisma.models.FeaturedAgent.prisma().upsert(where={'agentId': agent_id}, data={'update': {'featuredCategories': featured_categories, 'isActive': is_active}, 'create': {'featuredCategories': featured_categories, 'isActive': is_active, 'agent': {'connect': {'id': agent_id}}}})
return featured
raise AgentQueryError(f'Database query failed: {str(e)}')
raise AgentQueryError(f'Unexpected error occurred: {str(e)}')
async def get_featured_agents(category: str='featured', page: int=1, page_size: int=10, submission_status: prisma.enums.SubmissionStatus=prisma.enums.SubmissionStatus.APPROVED) -> FeaturedAgentResponse:
    """Retrieve a list of featured agents from the database based on the provided category.

    Args:
        category (str, optional): The category of featured agents to retrieve. Defaults to "featured".
        page (int, optional): The page number to retrieve. Defaults to 1.
        page_size (int, optional): The number of agents per page. Defaults to 10.

    Returns:
        dict: A dictionary containing the list of featured agents, total count, current page number, page size, and total number of pages.
    """
    try:
        skip = (page - 1) * page_size
        try:
            featured_agents = await prisma.models.FeaturedAgent.prisma().find_many(where={'featuredCategories': {'has': category}, 'isActive': True, 'agent': {'is': {'submissionStatus': submission_status}}}, include={'agent': {'include': {'AnalyticsTracker': True}}}, skip=skip, take=page_size)
        except prisma.errors.PrismaError as e:
            raise AgentQueryError(f'Database query failed: {str(e)}')
        total_count = len(featured_agents)
        return FeaturedAgentResponse(featured_agents=featured_agents, total_count=total_count, page=page, page_size=page_size, total_pages=(total_count + page_size - 1) // page_size)
    except AgentQueryError as e:
        raise e from e
    except ValueError as e:
        raise AgentQueryError(f'Invalid input parameter: {str(e)}') from e
    except Exception as e:
        raise AgentQueryError(f'Unexpected error occurred: {str(e)}') from e
'Retrieve a list of featured agents from the database based on the provided category.\n\n    Args:\n        category (str, optional): The category of featured agents to retrieve. Defaults to "featured".\n        page (int, optional): The page number to retrieve. Defaults to 1.\n        page_size (int, optional): The number of agents per page. Defaults to 10.\n\n    Returns:\n        dict: A dictionary containing the list of featured agents, total count, current page number, page size, and total number of pages.\n    '
try:
    skip = (page - 1) * page_size
    try:
        featured_agents = await prisma.models.FeaturedAgent.prisma().find_many(where={'featuredCategories': {'has': category}, 'isActive': True, 'agent': {'is': {'submissionStatus': submission_status}}}, include={'agent': {'include': {'AnalyticsTracker': True}}}, skip=skip, take=page_size)
    except prisma.errors.PrismaError as e:
        raise AgentQueryError(f'Database query failed: {str(e)}')
    total_count = len(featured_agents)
    return FeaturedAgentResponse(featured_agents=featured_agents, total_count=total_count, page=page, page_size=page_size, total_pages=(total_count + page_size - 1) // page_size)
except AgentQueryError as e:
    raise e from e
except ValueError as e:
    raise AgentQueryError(f'Invalid input parameter: {str(e)}') from e
except Exception as e:
    raise AgentQueryError(f'Unexpected error occurred: {str(e)}') from e
skip = (page - 1) * page_size
try:
    featured_agents = await prisma.models.FeaturedAgent.prisma().find_many(where={'featuredCategories': {'has': category}, 'isActive': True, 'agent': {'is': {'submissionStatus': submission_status}}}, include={'agent': {'include': {'AnalyticsTracker': True}}}, skip=skip, take=page_size)
except prisma.errors.PrismaError as e:
    raise AgentQueryError(f'Database query failed: {str(e)}')
featured_agents = await prisma.models.FeaturedAgent.prisma().find_many(where={'featuredCategories': {'has': category}, 'isActive': True, 'agent': {'is': {'submissionStatus': submission_status}}}, include={'agent': {'include': {'AnalyticsTracker': True}}}, skip=skip, take=page_size)
raise AgentQueryError(f'Database query failed: {str(e)}')
total_count = len(featured_agents)
return FeaturedAgentResponse(featured_agents=featured_agents, total_count=total_count, page=page, page_size=page_size, total_pages=(total_count + page_size - 1) // page_size)
raise e from e
raise AgentQueryError(f'Invalid input parameter: {str(e)}') from e
raise AgentQueryError(f'Unexpected error occurred: {str(e)}') from e
async def remove_featured_category(agent_id: str, category: str) -> prisma.models.FeaturedAgent | None:
    """Adds a featured category to an agent.

    Args:
        agent_id (str): The ID of the agent.
        category (str): The category to add to the agent.

    Returns:
        FeaturedAgentResponse: The updated list of featured agents.
    """
    try:
        featured_agent = await prisma.models.FeaturedAgent.prisma().find_unique(where={'agentId': agent_id}, include={'agent': True})
        if not featured_agent:
            raise AgentQueryError(f'Agent with ID {agent_id} not found.')
        featured_agent.featuredCategories.remove(category)
        featured_agent = await prisma.models.FeaturedAgent.prisma().update(where={'agentId': agent_id}, data={'featuredCategories': featured_agent.featuredCategories})
        return featured_agent
    except prisma.errors.PrismaError as e:
        raise AgentQueryError(f'Database query failed: {str(e)}')
    except Exception as e:
        raise AgentQueryError(f'Unexpected error occurred: {str(e)}')
'Adds a featured category to an agent.\n\n    Args:\n        agent_id (str): The ID of the agent.\n        category (str): The category to add to the agent.\n\n    Returns:\n        FeaturedAgentResponse: The updated list of featured agents.\n    '
try:
    featured_agent = await prisma.models.FeaturedAgent.prisma().find_unique(where={'agentId': agent_id}, include={'agent': True})
    if not featured_agent:
        raise AgentQueryError(f'Agent with ID {agent_id} not found.')
    featured_agent.featuredCategories.remove(category)
    featured_agent = await prisma.models.FeaturedAgent.prisma().update(where={'agentId': agent_id}, data={'featuredCategories': featured_agent.featuredCategories})
    return featured_agent
except prisma.errors.PrismaError as e:
    raise AgentQueryError(f'Database query failed: {str(e)}')
except Exception as e:
    raise AgentQueryError(f'Unexpected error occurred: {str(e)}')
featured_agent = await prisma.models.FeaturedAgent.prisma().find_unique(where={'agentId': agent_id}, include={'agent': True})
not featured_agent
raise AgentQueryError(f'Agent with ID {agent_id} not found.')
featured_agent.featuredCategories.remove(category)
featured_agent = await prisma.models.FeaturedAgent.prisma().update(where={'agentId': agent_id}, data={'featuredCategories': featured_agent.featuredCategories})
return featured_agent
raise AgentQueryError(f'Database query failed: {str(e)}')
raise AgentQueryError(f'Unexpected error occurred: {str(e)}')
async def add_featured_category(agent_id: str, category: str) -> prisma.models.FeaturedAgent | None:
    """Removes a featured category from an agent.

    Args:
        agent_id (str): The ID of the agent.
        category (str): The category to remove from the agent.

    Returns:
        FeaturedAgentResponse: The updated list of featured agents.
    """
    try:
        featured_agent = await prisma.models.FeaturedAgent.prisma().update(where={'agentId': agent_id}, data={'featuredCategories': {'push': [category]}})
        return featured_agent
    except prisma.errors.PrismaError as e:
        raise AgentQueryError(f'Database query failed: {str(e)}')
    except Exception as e:
        raise AgentQueryError(f'Unexpected error occurred: {str(e)}')
'Removes a featured category from an agent.\n\n    Args:\n        agent_id (str): The ID of the agent.\n        category (str): The category to remove from the agent.\n\n    Returns:\n        FeaturedAgentResponse: The updated list of featured agents.\n    '
try:
    featured_agent = await prisma.models.FeaturedAgent.prisma().update(where={'agentId': agent_id}, data={'featuredCategories': {'push': [category]}})
    return featured_agent
except prisma.errors.PrismaError as e:
    raise AgentQueryError(f'Database query failed: {str(e)}')
except Exception as e:
    raise AgentQueryError(f'Unexpected error occurred: {str(e)}')
featured_agent = await prisma.models.FeaturedAgent.prisma().update(where={'agentId': agent_id}, data={'featuredCategories': {'push': [category]}})
return featured_agent
raise AgentQueryError(f'Database query failed: {str(e)}')
raise AgentQueryError(f'Unexpected error occurred: {str(e)}')
async def get_agent_featured(agent_id: str) -> prisma.models.FeaturedAgent | None:
    """Retrieve an agent's featured categories from the database.

    Args:
        agent_id (str): The ID of the agent.

    Returns:
        FeaturedAgentResponse: The list of featured agents.
    """
    try:
        featured_agent = await prisma.models.FeaturedAgent.prisma().find_unique(where={'agentId': agent_id})
        return featured_agent
    except prisma.errors.PrismaError as e:
        raise AgentQueryError(f'Database query failed: {str(e)}')
    except Exception as e:
        raise AgentQueryError(f'Unexpected error occurred: {str(e)}')
"Retrieve an agent's featured categories from the database.\n\n    Args:\n        agent_id (str): The ID of the agent.\n\n    Returns:\n        FeaturedAgentResponse: The list of featured agents.\n    "
try:
    featured_agent = await prisma.models.FeaturedAgent.prisma().find_unique(where={'agentId': agent_id})
    return featured_agent
except prisma.errors.PrismaError as e:
    raise AgentQueryError(f'Database query failed: {str(e)}')
except Exception as e:
    raise AgentQueryError(f'Unexpected error occurred: {str(e)}')
featured_agent = await prisma.models.FeaturedAgent.prisma().find_unique(where={'agentId': agent_id})
return featured_agent
raise AgentQueryError(f'Database query failed: {str(e)}')
raise AgentQueryError(f'Unexpected error occurred: {str(e)}')
async def get_not_featured_agents(page: int=1, page_size: int=10) -> typing.List[prisma.models.Agents]:
    """
    Retrieve a list of not featured agents from the database.
    """
    try:
        agents = await prisma.client.get_client().query_raw(query=f"""\n            SELECT \n                "market"."Agents".id, \n                "market"."Agents"."createdAt", \n                "market"."Agents"."updatedAt", \n                "market"."Agents".version, \n                "market"."Agents".name, \n                LEFT("market"."Agents".description, 500) AS description, \n                "market"."Agents".author, \n                "market"."Agents".keywords, \n                "market"."Agents".categories, \n                "market"."Agents".graph,\n                "market"."Agents"."submissionStatus",\n                "market"."Agents"."submissionDate",\n                "market"."Agents".search::text AS search\n            FROM "market"."Agents"\n            LEFT JOIN "market"."FeaturedAgent" ON "market"."Agents"."id" = "market"."FeaturedAgent"."agentId"\n            WHERE ("market"."FeaturedAgent"."agentId" IS NULL OR "market"."FeaturedAgent"."featuredCategories" = '{{}}')\n                AND "market"."Agents"."submissionStatus" = 'APPROVED'\n            ORDER BY "market"."Agents"."createdAt" DESC\n            LIMIT {page_size} OFFSET {page_size * (page - 1)}\n            """, model=prisma.models.Agents)
        return agents
    except prisma.errors.PrismaError as e:
        raise AgentQueryError(f'Database query failed: {str(e)}')
    except Exception as e:
        raise AgentQueryError(f'Unexpected error occurred: {str(e)}')
'\n    Retrieve a list of not featured agents from the database.\n    '
try:
    agents = await prisma.client.get_client().query_raw(query=f"""\n            SELECT \n                "market"."Agents".id, \n                "market"."Agents"."createdAt", \n                "market"."Agents"."updatedAt", \n                "market"."Agents".version, \n                "market"."Agents".name, \n                LEFT("market"."Agents".description, 500) AS description, \n                "market"."Agents".author, \n                "market"."Agents".keywords, \n                "market"."Agents".categories, \n                "market"."Agents".graph,\n                "market"."Agents"."submissionStatus",\n                "market"."Agents"."submissionDate",\n                "market"."Agents".search::text AS search\n            FROM "market"."Agents"\n            LEFT JOIN "market"."FeaturedAgent" ON "market"."Agents"."id" = "market"."FeaturedAgent"."agentId"\n            WHERE ("market"."FeaturedAgent"."agentId" IS NULL OR "market"."FeaturedAgent"."featuredCategories" = '{{}}')\n                AND "market"."Agents"."submissionStatus" = 'APPROVED'\n            ORDER BY "market"."Agents"."createdAt" DESC\n            LIMIT {page_size} OFFSET {page_size * (page - 1)}\n            """, model=prisma.models.Agents)
    return agents
except prisma.errors.PrismaError as e:
    raise AgentQueryError(f'Database query failed: {str(e)}')
except Exception as e:
    raise AgentQueryError(f'Unexpected error occurred: {str(e)}')
agents = await prisma.client.get_client().query_raw(query=f"""\n            SELECT \n                "market"."Agents".id, \n                "market"."Agents"."createdAt", \n                "market"."Agents"."updatedAt", \n                "market"."Agents".version, \n                "market"."Agents".name, \n                LEFT("market"."Agents".description, 500) AS description, \n                "market"."Agents".author, \n                "market"."Agents".keywords, \n                "market"."Agents".categories, \n                "market"."Agents".graph,\n                "market"."Agents"."submissionStatus",\n                "market"."Agents"."submissionDate",\n                "market"."Agents".search::text AS search\n            FROM "market"."Agents"\n            LEFT JOIN "market"."FeaturedAgent" ON "market"."Agents"."id" = "market"."FeaturedAgent"."agentId"\n            WHERE ("market"."FeaturedAgent"."agentId" IS NULL OR "market"."FeaturedAgent"."featuredCategories" = '{{}}')\n                AND "market"."Agents"."submissionStatus" = 'APPROVED'\n            ORDER BY "market"."Agents"."createdAt" DESC\n            LIMIT {page_size} OFFSET {page_size * (page - 1)}\n            """, model=prisma.models.Agents)
return agents
raise AgentQueryError(f'Database query failed: {str(e)}')
raise AgentQueryError(f'Unexpected error occurred: {str(e)}')
async def get_all_categories() -> market.model.CategoriesResponse:
    """
    Retrieve all unique categories from the database.

    Returns:
        CategoriesResponse: A list of unique categories.
    """
    try:
        agents = await prisma.models.Agents.prisma().find_many(distinct=['categories'])
        all_categories = set()
        for agent in agents:
            all_categories.update(agent.categories)
        unique_categories = sorted(list(all_categories))
        return market.model.CategoriesResponse(unique_categories=unique_categories)
    except prisma.errors.PrismaError as e:
        raise AgentQueryError(f'Database query failed: {str(e)}')
    except Exception:
        return market.model.CategoriesResponse(unique_categories=[])
'\n    Retrieve all unique categories from the database.\n\n    Returns:\n        CategoriesResponse: A list of unique categories.\n    '
try:
    agents = await prisma.models.Agents.prisma().find_many(distinct=['categories'])
    all_categories = set()
    for agent in agents:
        all_categories.update(agent.categories)
    unique_categories = sorted(list(all_categories))
    return market.model.CategoriesResponse(unique_categories=unique_categories)
except prisma.errors.PrismaError as e:
    raise AgentQueryError(f'Database query failed: {str(e)}')
except Exception:
    return market.model.CategoriesResponse(unique_categories=[])
agents = await prisma.models.Agents.prisma().find_many(distinct=['categories'])
all_categories = set()
agent
agents
all_categories.update(agent.categories)
unique_categories = sorted(list(all_categories))
return market.model.CategoriesResponse(unique_categories=unique_categories)
raise AgentQueryError(f'Database query failed: {str(e)}')
return market.model.CategoriesResponse(unique_categories=[])
async def create_agent_installed_event(event_data: market.model.AgentInstalledFromMarketplaceEventData):
    try:
        await prisma.models.InstallTracker.prisma().create(data={'installedAgentId': event_data.installed_agent_id, 'marketplaceAgentId': event_data.marketplace_agent_id, 'installationLocation': prisma.enums.InstallationLocation(event_data.installation_location.name)})
    except prisma.errors.PrismaError as e:
        raise AgentQueryError(f'Database query failed: {str(e)}')
    except Exception as e:
        raise AgentQueryError(f'Unexpected error occurred: {str(e)}')
try:
    await prisma.models.InstallTracker.prisma().create(data={'installedAgentId': event_data.installed_agent_id, 'marketplaceAgentId': event_data.marketplace_agent_id, 'installationLocation': prisma.enums.InstallationLocation(event_data.installation_location.name)})
except prisma.errors.PrismaError as e:
    raise AgentQueryError(f'Database query failed: {str(e)}')
except Exception as e:
    raise AgentQueryError(f'Unexpected error occurred: {str(e)}')
await prisma.models.InstallTracker.prisma().create(data={'installedAgentId': event_data.installed_agent_id, 'marketplaceAgentId': event_data.marketplace_agent_id, 'installationLocation': prisma.enums.InstallationLocation(event_data.installation_location.name)})
raise AgentQueryError(f'Database query failed: {str(e)}')
raise AgentQueryError(f'Unexpected error occurred: {str(e)}')