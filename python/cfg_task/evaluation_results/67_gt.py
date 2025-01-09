import logging
from typing import TYPE_CHECKING, Callable, Optional, cast
from backend.data.block import BlockWebhookConfig, get_block
from backend.data.graph import set_node_webhook
from backend.data.model import CREDENTIALS_FIELD_NAME
from backend.integrations.webhooks import WEBHOOK_MANAGERS_BY_NAME
TYPE_CHECKING
from backend.data.graph import GraphModel, NodeModel
from backend.data.model import Credentials
from ._base import BaseWebhooksManager
logger = logging.getLogger(__name__)
async def on_graph_activate(graph: 'GraphModel', get_credentials: Callable[[str], 'Credentials | None']):
    """
    Hook to be called when a graph is activated/created.

    ⚠️ Assuming node entities are not re-used between graph versions, ⚠️
    this hook calls `on_node_activate` on all nodes in this graph.

    Params:
        get_credentials: `credentials_id` -> Credentials
    """
    updated_nodes = []
    for new_node in graph.nodes:
        node_credentials = None
        if (creds_meta := new_node.input_default.get(CREDENTIALS_FIELD_NAME)):
            node_credentials = get_credentials(creds_meta['id'])
            if not node_credentials:
                raise ValueError(f'Node #{new_node.id} updated with non-existent credentials #{node_credentials}')
        updated_node = await on_node_activate(graph.user_id, new_node, credentials=node_credentials)
        updated_nodes.append(updated_node)
    graph.nodes = updated_nodes
    return graph
'\n    Hook to be called when a graph is activated/created.\n\n    ⚠️ Assuming node entities are not re-used between graph versions, ⚠️\n    this hook calls `on_node_activate` on all nodes in this graph.\n\n    Params:\n        get_credentials: `credentials_id` -> Credentials\n    '
updated_nodes = []
new_node
graph.nodes
node_credentials = None
(creds_meta := new_node.input_default.get(CREDENTIALS_FIELD_NAME))
graph.nodes = updated_nodes
return graph
node_credentials = get_credentials(creds_meta['id'])
not node_credentials
updated_node = await on_node_activate(graph.user_id, new_node, credentials=node_credentials)
updated_nodes.append(updated_node)
raise ValueError(f'Node #{new_node.id} updated with non-existent credentials #{node_credentials}')
async def on_graph_deactivate(graph: 'GraphModel', get_credentials: Callable[[str], 'Credentials | None']):
    """
    Hook to be called when a graph is deactivated/deleted.

    ⚠️ Assuming node entities are not re-used between graph versions, ⚠️
    this hook calls `on_node_deactivate` on all nodes in `graph`.

    Params:
        get_credentials: `credentials_id` -> Credentials
    """
    updated_nodes = []
    for node in graph.nodes:
        node_credentials = None
        if (creds_meta := node.input_default.get(CREDENTIALS_FIELD_NAME)):
            node_credentials = get_credentials(creds_meta['id'])
            if not node_credentials:
                logger.error(f"Node #{node.id} referenced non-existent credentials #{creds_meta['id']}")
        updated_node = await on_node_deactivate(node, credentials=node_credentials)
        updated_nodes.append(updated_node)
    graph.nodes = updated_nodes
    return graph
'\n    Hook to be called when a graph is deactivated/deleted.\n\n    ⚠️ Assuming node entities are not re-used between graph versions, ⚠️\n    this hook calls `on_node_deactivate` on all nodes in `graph`.\n\n    Params:\n        get_credentials: `credentials_id` -> Credentials\n    '
updated_nodes = []
node
graph.nodes
node_credentials = None
(creds_meta := node.input_default.get(CREDENTIALS_FIELD_NAME))
graph.nodes = updated_nodes
return graph
node_credentials = get_credentials(creds_meta['id'])
not node_credentials
updated_node = await on_node_deactivate(node, credentials=node_credentials)
updated_nodes.append(updated_node)
logger.error(f"Node #{node.id} referenced non-existent credentials #{creds_meta['id']}")
async def on_node_activate(user_id: str, node: 'NodeModel', *, credentials: Optional['Credentials']=None) -> 'NodeModel':
    """Hook to be called when the node is activated/created"""
    block = get_block(node.block_id)
    if not block:
        raise ValueError(f'Node #{node.id} is instance of unknown block #{node.block_id}')
    if not block.webhook_config:
        return node
    provider = block.webhook_config.provider
    if provider not in WEBHOOK_MANAGERS_BY_NAME:
        raise ValueError(f'Block #{block.id} has webhook_config for provider {provider} which does not support webhooks')
    logger.debug(f'Activating webhook node #{node.id} with config {block.webhook_config}')
    webhooks_manager = WEBHOOK_MANAGERS_BY_NAME[provider]()
    if (auto_setup_webhook := isinstance(block.webhook_config, BlockWebhookConfig)):
        try:
            resource = block.webhook_config.resource_format.format(**node.input_default)
        except KeyError:
            resource = None
        logger.debug(f'Constructed resource string {resource} from input {node.input_default}')
    else:
        resource = ''
    needs_credentials = CREDENTIALS_FIELD_NAME in block.input_schema.model_fields
    credentials_meta = node.input_default.get(CREDENTIALS_FIELD_NAME) if needs_credentials else None
    event_filter_input_name = block.webhook_config.event_filter_input
    has_everything_for_webhook = resource is not None and (credentials_meta or not needs_credentials) and (not event_filter_input_name or (event_filter_input_name in node.input_default and any((is_on for is_on in node.input_default[event_filter_input_name].values()))))
    if has_everything_for_webhook and resource is not None:
        logger.debug(f'Node #{node} has everything for a webhook!')
        if credentials_meta and (not credentials):
            raise ValueError(f"Cannot set up webhook for node #{node.id}: credentials #{credentials_meta['id']} not available")
        if event_filter_input_name:
            event_filter = cast(dict, node.input_default[event_filter_input_name])
            events = [block.webhook_config.event_format.format(event=event) for (event, enabled) in event_filter.items() if enabled is True]
            logger.debug(f"Webhook events to subscribe to: {', '.join(events)}")
        else:
            events = []
        if auto_setup_webhook:
            assert credentials is not None
            new_webhook = await webhooks_manager.get_suitable_auto_webhook(user_id, credentials, block.webhook_config.webhook_type, resource, events)
        else:
            new_webhook = await webhooks_manager.get_manual_webhook(user_id, node.graph_id, block.webhook_config.webhook_type, events)
        logger.debug(f'Acquired webhook: {new_webhook}')
        return await set_node_webhook(node.id, new_webhook.id)
    else:
        logger.debug(f'Node #{node.id} does not have everything for a webhook')
    return node
'Hook to be called when the node is activated/created'
block = get_block(node.block_id)
not block
raise ValueError(f'Node #{node.id} is instance of unknown block #{node.block_id}')
not block.webhook_config
return node
raise ValueError(f'Block #{block.id} has webhook_config for provider {provider} which does not support webhooks')
logger.debug(f'Activating webhook node #{node.id} with config {block.webhook_config}')
webhooks_manager = WEBHOOK_MANAGERS_BY_NAME[provider]()
(auto_setup_webhook := isinstance(block.webhook_config, BlockWebhookConfig))
try:
    resource = block.webhook_config.resource_format.format(**node.input_default)
except KeyError:
    resource = None
resource = block.webhook_config.resource_format.format(**node.input_default)
resource = None
logger.debug(f'Constructed resource string {resource} from input {node.input_default}')
resource = ''
needs_credentials = CREDENTIALS_FIELD_NAME in block.input_schema.model_fields
credentials_meta = node.input_default.get(CREDENTIALS_FIELD_NAME) if needs_credentials else None
event_filter_input_name = block.webhook_config.event_filter_input
has_everything_for_webhook = resource is not None and (credentials_meta or not needs_credentials) and (not event_filter_input_name or (event_filter_input_name in node.input_default and any((is_on for is_on in node.input_default[event_filter_input_name].values()))))
has_everything_for_webhook and resource is not None
logger.debug(f'Node #{node} has everything for a webhook!')
credentials_meta and (not credentials)
logger.debug(f'Node #{node.id} does not have everything for a webhook')
raise ValueError(f"Cannot set up webhook for node #{node.id}: credentials #{credentials_meta['id']} not available")
event_filter_input_name
event_filter = cast(dict, node.input_default[event_filter_input_name])
events = [block.webhook_config.event_format.format(event=event) for (event, enabled) in event_filter.items() if enabled is True]
logger.debug(f"Webhook events to subscribe to: {', '.join(events)}")
events = []
auto_setup_webhook
assert credentials is not None
new_webhook = await webhooks_manager.get_suitable_auto_webhook(user_id, credentials, block.webhook_config.webhook_type, resource, events)
new_webhook = await webhooks_manager.get_manual_webhook(user_id, node.graph_id, block.webhook_config.webhook_type, events)
logger.debug(f'Acquired webhook: {new_webhook}')
return await set_node_webhook(node.id, new_webhook.id)
async def on_node_deactivate(node: 'NodeModel', *, credentials: Optional['Credentials']=None, webhooks_manager: Optional['BaseWebhooksManager']=None) -> 'NodeModel':
    """Hook to be called when node is deactivated/deleted"""
    logger.debug(f'Deactivating node #{node.id}')
    block = get_block(node.block_id)
    if not block:
        raise ValueError(f'Node #{node.id} is instance of unknown block #{node.block_id}')
    if not block.webhook_config:
        return node
    provider = block.webhook_config.provider
    if provider not in WEBHOOK_MANAGERS_BY_NAME:
        raise ValueError(f'Block #{block.id} has webhook_config for provider {provider} which does not support webhooks')
    webhooks_manager = WEBHOOK_MANAGERS_BY_NAME[provider]()
    if node.webhook_id:
        logger.debug(f'Node #{node.id} has webhook_id {node.webhook_id}')
        if not node.webhook:
            logger.error(f'Node #{node.id} has webhook_id but no webhook object')
            raise ValueError('node.webhook not included')
        logger.debug(f'Detaching webhook from node #{node.id}')
        updated_node = await set_node_webhook(node.id, None)
        webhook = node.webhook
        logger.debug(f"Pruning{(' and deregistering' if credentials else '')} webhook #{webhook.id}")
        await webhooks_manager.prune_webhook_if_dangling(webhook.id, credentials)
        if CREDENTIALS_FIELD_NAME in block.input_schema.model_fields and (not credentials):
            logger.warning(f'Cannot deregister webhook #{webhook.id}: credentials #{webhook.credentials_id} not available ({webhook.provider.value} webhook ID: {webhook.provider_webhook_id})')
        return updated_node
    logger.debug(f'Node #{node.id} has no webhook_id, returning')
    return node
'Hook to be called when node is deactivated/deleted'
logger.debug(f'Deactivating node #{node.id}')
block = get_block(node.block_id)
not block
raise ValueError(f'Node #{node.id} is instance of unknown block #{node.block_id}')
not block.webhook_config
return node
raise ValueError(f'Block #{block.id} has webhook_config for provider {provider} which does not support webhooks')
webhooks_manager = WEBHOOK_MANAGERS_BY_NAME[provider]()
node.webhook_id
logger.debug(f'Node #{node.id} has webhook_id {node.webhook_id}')
not node.webhook
logger.error(f'Node #{node.id} has webhook_id but no webhook object')
raise ValueError('node.webhook not included')
logger.debug(f'Detaching webhook from node #{node.id}')
updated_node = await set_node_webhook(node.id, None)
webhook = node.webhook
logger.debug(f"Pruning{(' and deregistering' if credentials else '')} webhook #{webhook.id}")
await webhooks_manager.prune_webhook_if_dangling(webhook.id, credentials)
CREDENTIALS_FIELD_NAME in block.input_schema.model_fields and (not credentials)
logger.warning(f'Cannot deregister webhook #{webhook.id}: credentials #{webhook.credentials_id} not available ({webhook.provider.value} webhook ID: {webhook.provider_webhook_id})')
return updated_node