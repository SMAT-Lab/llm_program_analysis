import asyncio
import logging
import uuid
from collections import defaultdict
from datetime import datetime, timezone
from typing import Any, Literal, Optional, Type
import prisma
from prisma.models import AgentGraph, AgentGraphExecution, AgentNode, AgentNodeLink
from prisma.types import AgentGraphWhereInput
from pydantic.fields import computed_field
from backend.blocks.agent import AgentExecutorBlock
from backend.blocks.basic import AgentInputBlock, AgentOutputBlock
from backend.util import json
from .block import BlockInput, BlockType, get_block, get_blocks
from .db import BaseDbModel, transaction
from .execution import ExecutionStatus
from .includes import AGENT_GRAPH_INCLUDE, AGENT_NODE_INCLUDE
from .integrations import Webhook
logger = logging.getLogger(__name__)
class Link(BaseDbModel):
    source_id: str
    sink_id: str
    source_name: str
    sink_name: str
    is_static: bool = False

    @staticmethod
    def from_db(link: AgentNodeLink):
        return Link(id=link.id, source_name=link.sourceName, source_id=link.agentNodeSourceId, sink_name=link.sinkName, sink_id=link.agentNodeSinkId, is_static=link.isStatic)

    def __hash__(self):
        return hash((self.source_id, self.sink_id, self.source_name, self.sink_name))
source_id: str
sink_id: str
source_name: str
sink_name: str
is_static: bool = False
@staticmethod
def from_db(link: AgentNodeLink):
    return Link(id=link.id, source_name=link.sourceName, source_id=link.agentNodeSourceId, sink_name=link.sinkName, sink_id=link.agentNodeSinkId, is_static=link.isStatic)
return Link(id=link.id, source_name=link.sourceName, source_id=link.agentNodeSourceId, sink_name=link.sinkName, sink_id=link.agentNodeSinkId, is_static=link.isStatic)
def __hash__(self):
    return hash((self.source_id, self.sink_id, self.source_name, self.sink_name))
return hash((self.source_id, self.sink_id, self.source_name, self.sink_name))
class Node(BaseDbModel):
    block_id: str
    input_default: BlockInput = {}
    metadata: dict[str, Any] = {}
    input_links: list[Link] = []
    output_links: list[Link] = []
    webhook_id: Optional[str] = None
block_id: str
input_default: BlockInput = {}
metadata: dict[str, Any] = {}
input_links: list[Link] = []
output_links: list[Link] = []
webhook_id: Optional[str] = None
class NodeModel(Node):
    graph_id: str
    graph_version: int
    webhook: Optional[Webhook] = None

    @staticmethod
    def from_db(node: AgentNode):
        if not node.AgentBlock:
            raise ValueError(f'Invalid node {node.id}, invalid AgentBlock.')
        obj = NodeModel(id=node.id, block_id=node.AgentBlock.id, input_default=json.loads(node.constantInput, target_type=dict[str, Any]), metadata=json.loads(node.metadata, target_type=dict[str, Any]), graph_id=node.agentGraphId, graph_version=node.agentGraphVersion, webhook_id=node.webhookId, webhook=Webhook.from_db(node.Webhook) if node.Webhook else None)
        obj.input_links = [Link.from_db(link) for link in node.Input or []]
        obj.output_links = [Link.from_db(link) for link in node.Output or []]
        return obj

    def is_triggered_by_event_type(self, event_type: str) -> bool:
        if not (block := get_block(self.block_id)):
            raise ValueError(f'Block #{self.block_id} not found for node #{self.id}')
        if not block.webhook_config:
            raise TypeError("This method can't be used on non-webhook blocks")
        if not block.webhook_config.event_filter_input:
            return True
        event_filter = self.input_default.get(block.webhook_config.event_filter_input)
        if not event_filter:
            raise ValueError(f'Event filter is not configured on node #{self.id}')
        return event_type in [block.webhook_config.event_format.format(event=k) for k in event_filter if event_filter[k] is True]
graph_id: str
graph_version: int
webhook: Optional[Webhook] = None
@staticmethod
def from_db(node: AgentNode):
    if not node.AgentBlock:
        raise ValueError(f'Invalid node {node.id}, invalid AgentBlock.')
    obj = NodeModel(id=node.id, block_id=node.AgentBlock.id, input_default=json.loads(node.constantInput, target_type=dict[str, Any]), metadata=json.loads(node.metadata, target_type=dict[str, Any]), graph_id=node.agentGraphId, graph_version=node.agentGraphVersion, webhook_id=node.webhookId, webhook=Webhook.from_db(node.Webhook) if node.Webhook else None)
    obj.input_links = [Link.from_db(link) for link in node.Input or []]
    obj.output_links = [Link.from_db(link) for link in node.Output or []]
    return obj
not node.AgentBlock
raise ValueError(f'Invalid node {node.id}, invalid AgentBlock.')
obj = NodeModel(id=node.id, block_id=node.AgentBlock.id, input_default=json.loads(node.constantInput, target_type=dict[str, Any]), metadata=json.loads(node.metadata, target_type=dict[str, Any]), graph_id=node.agentGraphId, graph_version=node.agentGraphVersion, webhook_id=node.webhookId, webhook=Webhook.from_db(node.Webhook) if node.Webhook else None)
obj.input_links = [Link.from_db(link) for link in node.Input or []]
obj.output_links = [Link.from_db(link) for link in node.Output or []]
return obj
def is_triggered_by_event_type(self, event_type: str) -> bool:
    if not (block := get_block(self.block_id)):
        raise ValueError(f'Block #{self.block_id} not found for node #{self.id}')
    if not block.webhook_config:
        raise TypeError("This method can't be used on non-webhook blocks")
    if not block.webhook_config.event_filter_input:
        return True
    event_filter = self.input_default.get(block.webhook_config.event_filter_input)
    if not event_filter:
        raise ValueError(f'Event filter is not configured on node #{self.id}')
    return event_type in [block.webhook_config.event_format.format(event=k) for k in event_filter if event_filter[k] is True]
not (block := get_block(self.block_id))
raise ValueError(f'Block #{self.block_id} not found for node #{self.id}')
not block.webhook_config
raise TypeError("This method can't be used on non-webhook blocks")
not block.webhook_config.event_filter_input
return True
raise ValueError(f'Event filter is not configured on node #{self.id}')
return event_type in [block.webhook_config.event_format.format(event=k) for k in event_filter if event_filter[k] is True]
Webhook.model_rebuild()
class GraphExecution(BaseDbModel):
    execution_id: str
    started_at: datetime
    ended_at: datetime
    duration: float
    total_run_time: float
    status: ExecutionStatus
    graph_id: str
    graph_version: int

    @staticmethod
    def from_db(execution: AgentGraphExecution):
        now = datetime.now(timezone.utc)
        start_time = execution.startedAt or execution.createdAt
        end_time = execution.updatedAt or now
        duration = (end_time - start_time).total_seconds()
        total_run_time = duration
        try:
            stats = json.loads(execution.stats or '{}', target_type=dict[str, Any])
        except ValueError:
            stats = {}
        duration = stats.get('walltime', duration)
        total_run_time = stats.get('nodes_walltime', total_run_time)
        return GraphExecution(id=execution.id, execution_id=execution.id, started_at=start_time, ended_at=end_time, duration=duration, total_run_time=total_run_time, status=ExecutionStatus(execution.executionStatus), graph_id=execution.agentGraphId, graph_version=execution.agentGraphVersion)
execution_id: str
started_at: datetime
ended_at: datetime
duration: float
total_run_time: float
status: ExecutionStatus
graph_id: str
graph_version: int
@staticmethod
def from_db(execution: AgentGraphExecution):
    now = datetime.now(timezone.utc)
    start_time = execution.startedAt or execution.createdAt
    end_time = execution.updatedAt or now
    duration = (end_time - start_time).total_seconds()
    total_run_time = duration
    try:
        stats = json.loads(execution.stats or '{}', target_type=dict[str, Any])
    except ValueError:
        stats = {}
    duration = stats.get('walltime', duration)
    total_run_time = stats.get('nodes_walltime', total_run_time)
    return GraphExecution(id=execution.id, execution_id=execution.id, started_at=start_time, ended_at=end_time, duration=duration, total_run_time=total_run_time, status=ExecutionStatus(execution.executionStatus), graph_id=execution.agentGraphId, graph_version=execution.agentGraphVersion)
now = datetime.now(timezone.utc)
start_time = execution.startedAt or execution.createdAt
end_time = execution.updatedAt or now
duration = (end_time - start_time).total_seconds()
total_run_time = duration
try:
    stats = json.loads(execution.stats or '{}', target_type=dict[str, Any])
except ValueError:
    stats = {}
stats = json.loads(execution.stats or '{}', target_type=dict[str, Any])
stats = {}
duration = stats.get('walltime', duration)
total_run_time = stats.get('nodes_walltime', total_run_time)
return GraphExecution(id=execution.id, execution_id=execution.id, started_at=start_time, ended_at=end_time, duration=duration, total_run_time=total_run_time, status=ExecutionStatus(execution.executionStatus), graph_id=execution.agentGraphId, graph_version=execution.agentGraphVersion)
class Graph(BaseDbModel):
    version: int = 1
    is_active: bool = True
    is_template: bool = False
    name: str
    description: str
    nodes: list[Node] = []
    links: list[Link] = []

    @computed_field
    @property
    def input_schema(self) -> dict[str, Any]:
        return self._generate_schema(AgentInputBlock.Input, [node.input_default for node in self.nodes if (b := get_block(node.block_id)) and b.block_type == BlockType.INPUT and ('name' in node.input_default)])

    @computed_field
    @property
    def output_schema(self) -> dict[str, Any]:
        return self._generate_schema(AgentOutputBlock.Input, [node.input_default for node in self.nodes if (b := get_block(node.block_id)) and b.block_type == BlockType.OUTPUT and ('name' in node.input_default)])

    @staticmethod
    def _generate_schema(type_class: Type[AgentInputBlock.Input] | Type[AgentOutputBlock.Input], data: list[dict]) -> dict[str, Any]:
        props = []
        for p in data:
            try:
                props.append(type_class(**p))
            except Exception as e:
                logger.warning(f'Invalid {type_class}: {p}, {e}')
        return {'type': 'object', 'properties': {p.name: {'secret': p.secret, 'advanced': p.advanced, 'title': p.title or p.name, **({'description': p.description} if p.description else {}), **({'default': p.value} if p.value is not None else {})} for p in props}, 'required': [p.name for p in props if p.value is None]}
version: int = 1
is_active: bool = True
is_template: bool = False
name: str
description: str
nodes: list[Node] = []
links: list[Link] = []
@computed_field
@property
def input_schema(self) -> dict[str, Any]:
    return self._generate_schema(AgentInputBlock.Input, [node.input_default for node in self.nodes if (b := get_block(node.block_id)) and b.block_type == BlockType.INPUT and ('name' in node.input_default)])
return self._generate_schema(AgentInputBlock.Input, [node.input_default for node in self.nodes if (b := get_block(node.block_id)) and b.block_type == BlockType.INPUT and ('name' in node.input_default)])
@computed_field
@property
def output_schema(self) -> dict[str, Any]:
    return self._generate_schema(AgentOutputBlock.Input, [node.input_default for node in self.nodes if (b := get_block(node.block_id)) and b.block_type == BlockType.OUTPUT and ('name' in node.input_default)])
return self._generate_schema(AgentOutputBlock.Input, [node.input_default for node in self.nodes if (b := get_block(node.block_id)) and b.block_type == BlockType.OUTPUT and ('name' in node.input_default)])
@staticmethod
def _generate_schema(type_class: Type[AgentInputBlock.Input] | Type[AgentOutputBlock.Input], data: list[dict]) -> dict[str, Any]:
    props = []
    for p in data:
        try:
            props.append(type_class(**p))
        except Exception as e:
            logger.warning(f'Invalid {type_class}: {p}, {e}')
    return {'type': 'object', 'properties': {p.name: {'secret': p.secret, 'advanced': p.advanced, 'title': p.title or p.name, **({'description': p.description} if p.description else {}), **({'default': p.value} if p.value is not None else {})} for p in props}, 'required': [p.name for p in props if p.value is None]}
props = []
p
data
try:
    props.append(type_class(**p))
except Exception as e:
    logger.warning(f'Invalid {type_class}: {p}, {e}')
props.append(type_class())
logger.warning(f'Invalid {type_class}: {p}, {e}')
return {'type': 'object', 'properties': {p.name: {'secret': p.secret, 'advanced': p.advanced, 'title': p.title or p.name, **({'description': p.description} if p.description else {}), **({'default': p.value} if p.value is not None else {})} for p in props}, 'required': [p.name for p in props if p.value is None]}
class GraphModel(Graph):
    user_id: str
    nodes: list[NodeModel] = []

    @property
    def starting_nodes(self) -> list[Node]:
        outbound_nodes = {link.sink_id for link in self.links}
        input_nodes = {v.id for v in self.nodes if (b := get_block(v.block_id)) and b.block_type == BlockType.INPUT}
        return [node for node in self.nodes if node.id not in outbound_nodes or node.id in input_nodes]

    def reassign_ids(self, user_id: str, reassign_graph_id: bool=False):
        """
        Reassigns all IDs in the graph to new UUIDs.
        This method can be used before storing a new graph to the database.
        """
        id_map = {node.id: str(uuid.uuid4()) for node in self.nodes}
        if reassign_graph_id:
            self.id = str(uuid.uuid4())
        for node in self.nodes:
            node.id = id_map[node.id]
        for link in self.links:
            link.source_id = id_map[link.source_id]
            link.sink_id = id_map[link.sink_id]
        for node in self.nodes:
            if node.block_id != AgentExecutorBlock().id:
                continue
            node.input_default['user_id'] = user_id
            node.input_default.setdefault('data', {})
        self.validate_graph()

    def validate_graph(self, for_run: bool=False):

        def sanitize(name):
            return name.split('_#_')[0].split('_@_')[0].split('_$_')[0]
        input_links = defaultdict(list)
        for link in self.links:
            input_links[link.sink_id].append(link)
        for node in self.nodes:
            block = get_block(node.block_id)
            if block is None:
                raise ValueError(f'Invalid block {node.block_id} for node #{node.id}')
            provided_inputs = set([sanitize(name) for name in node.input_default] + [sanitize(link.sink_name) for link in input_links.get(node.id, [])])
            for name in block.input_schema.get_required_fields():
                if name not in provided_inputs and (not (name == 'payload' and block.block_type in (BlockType.WEBHOOK, BlockType.WEBHOOK_MANUAL))) and (for_run or block.block_type == BlockType.INPUT or block.block_type == BlockType.OUTPUT or (block.block_type == BlockType.AGENT)):
                    raise ValueError(f'Node {block.name} #{node.id} required input missing: `{name}`')
            input_schema = block.input_schema.model_fields
            required_fields = block.input_schema.get_required_fields()

            def has_value(name):
                return node is not None and name in node.input_default and (node.input_default[name] is not None) and (str(node.input_default[name]).strip() != '') or (name in input_schema and input_schema[name].default is not None)
            for (field_name, field_info) in input_schema.items():
                json_schema_extra = field_info.json_schema_extra or {}
                dependencies = json_schema_extra.get('depends_on', [])
                if not for_run or not dependencies:
                    continue
                field_has_value = has_value(field_name)
                field_is_required = field_name in required_fields
                missing_deps = [dep for dep in dependencies if not has_value(dep)]
                if missing_deps and (field_has_value or field_is_required):
                    raise ValueError(f"Node {block.name} #{node.id}: Field `{field_name}` requires [{', '.join(missing_deps)}] to be set")
        node_map = {v.id: v for v in self.nodes}

        def is_static_output_block(nid: str) -> bool:
            bid = node_map[nid].block_id
            b = get_block(bid)
            return b.static_output if b else False
        for link in self.links:
            source = (link.source_id, link.source_name)
            sink = (link.sink_id, link.sink_name)
            suffix = f'Link {source} <-> {sink}'
            for (i, (node_id, name)) in enumerate([source, sink]):
                node = node_map.get(node_id)
                if not node:
                    raise ValueError(f'{suffix}, {node_id} is invalid node id, available nodes: {node_map.keys()}')
                block = get_block(node.block_id)
                if not block:
                    blocks = {v().id: v().name for v in get_blocks().values()}
                    raise ValueError(f'{suffix}, {node.block_id} is invalid block id, available blocks: {blocks}')
                sanitized_name = sanitize(name)
                vals = node.input_default
                if i == 0:
                    fields = block.output_schema.get_fields() if block.block_type != BlockType.AGENT else vals.get('output_schema', {}).get('properties', {}).keys()
                else:
                    fields = block.input_schema.get_fields() if block.block_type != BlockType.AGENT else vals.get('input_schema', {}).get('properties', {}).keys()
                if sanitized_name not in fields:
                    fields_msg = f'Allowed fields: {fields}'
                    raise ValueError(f'{suffix}, `{name}` invalid, {fields_msg}')
            if is_static_output_block(link.source_id):
                link.is_static = True

    @staticmethod
    def from_db(graph: AgentGraph, for_export: bool=False):
        return GraphModel(id=graph.id, user_id=graph.userId, version=graph.version, is_active=graph.isActive, is_template=graph.isTemplate, name=graph.name or '', description=graph.description or '', nodes=[NodeModel.from_db(GraphModel._process_node(node, for_export)) for node in graph.AgentNodes or []], links=list({Link.from_db(link) for node in graph.AgentNodes or [] for link in (node.Input or []) + (node.Output or [])}))

    @staticmethod
    def _process_node(node: AgentNode, for_export: bool) -> AgentNode:
        if for_export:
            if node.constantInput:
                constant_input = json.loads(node.constantInput, target_type=dict[str, Any])
                constant_input = GraphModel._hide_node_input_credentials(constant_input)
                node.constantInput = json.dumps(constant_input)
            node.webhookId = None
            node.Webhook = None
        return node

    @staticmethod
    def _hide_node_input_credentials(input_data: dict[str, Any]) -> dict[str, Any]:
        sensitive_keys = ['credentials', 'api_key', 'password', 'token', 'secret']
        result = {}
        for (key, value) in input_data.items():
            if isinstance(value, dict):
                result[key] = GraphModel._hide_node_input_credentials(value)
            elif isinstance(value, str) and any((sensitive_key in key.lower() for sensitive_key in sensitive_keys)):
                continue
            else:
                result[key] = value
        return result
user_id: str
nodes: list[NodeModel] = []
@property
def starting_nodes(self) -> list[Node]:
    outbound_nodes = {link.sink_id for link in self.links}
    input_nodes = {v.id for v in self.nodes if (b := get_block(v.block_id)) and b.block_type == BlockType.INPUT}
    return [node for node in self.nodes if node.id not in outbound_nodes or node.id in input_nodes]
outbound_nodes = {link.sink_id for link in self.links}
input_nodes = {v.id for v in self.nodes if (b := get_block(v.block_id)) and b.block_type == BlockType.INPUT}
return [node for node in self.nodes if node.id not in outbound_nodes or node.id in input_nodes]
def reassign_ids(self, user_id: str, reassign_graph_id: bool=False):
    """
        Reassigns all IDs in the graph to new UUIDs.
        This method can be used before storing a new graph to the database.
        """
    id_map = {node.id: str(uuid.uuid4()) for node in self.nodes}
    if reassign_graph_id:
        self.id = str(uuid.uuid4())
    for node in self.nodes:
        node.id = id_map[node.id]
    for link in self.links:
        link.source_id = id_map[link.source_id]
        link.sink_id = id_map[link.sink_id]
    for node in self.nodes:
        if node.block_id != AgentExecutorBlock().id:
            continue
        node.input_default['user_id'] = user_id
        node.input_default.setdefault('data', {})
    self.validate_graph()
'\n        Reassigns all IDs in the graph to new UUIDs.\n        This method can be used before storing a new graph to the database.\n        '
id_map = {node.id: str(uuid.uuid4()) for node in self.nodes}
reassign_graph_id
self.id = str(uuid.uuid4())
node
self.nodes
node.id = id_map[node.id]
link
self.links
link.source_id = id_map[link.source_id]
link.sink_id = id_map[link.sink_id]
node
self.nodes
node.block_id NotEq AgentExecutorBlock().id
self.validate_graph()
def validate_graph(self, for_run: bool=False):

    def sanitize(name):
        return name.split('_#_')[0].split('_@_')[0].split('_$_')[0]
    input_links = defaultdict(list)
    for link in self.links:
        input_links[link.sink_id].append(link)
    for node in self.nodes:
        block = get_block(node.block_id)
        if block is None:
            raise ValueError(f'Invalid block {node.block_id} for node #{node.id}')
        provided_inputs = set([sanitize(name) for name in node.input_default] + [sanitize(link.sink_name) for link in input_links.get(node.id, [])])
        for name in block.input_schema.get_required_fields():
            if name not in provided_inputs and (not (name == 'payload' and block.block_type in (BlockType.WEBHOOK, BlockType.WEBHOOK_MANUAL))) and (for_run or block.block_type == BlockType.INPUT or block.block_type == BlockType.OUTPUT or (block.block_type == BlockType.AGENT)):
                raise ValueError(f'Node {block.name} #{node.id} required input missing: `{name}`')
        input_schema = block.input_schema.model_fields
        required_fields = block.input_schema.get_required_fields()

        def has_value(name):
            return node is not None and name in node.input_default and (node.input_default[name] is not None) and (str(node.input_default[name]).strip() != '') or (name in input_schema and input_schema[name].default is not None)
        for (field_name, field_info) in input_schema.items():
            json_schema_extra = field_info.json_schema_extra or {}
            dependencies = json_schema_extra.get('depends_on', [])
            if not for_run or not dependencies:
                continue
            field_has_value = has_value(field_name)
            field_is_required = field_name in required_fields
            missing_deps = [dep for dep in dependencies if not has_value(dep)]
            if missing_deps and (field_has_value or field_is_required):
                raise ValueError(f"Node {block.name} #{node.id}: Field `{field_name}` requires [{', '.join(missing_deps)}] to be set")
    node_map = {v.id: v for v in self.nodes}

    def is_static_output_block(nid: str) -> bool:
        bid = node_map[nid].block_id
        b = get_block(bid)
        return b.static_output if b else False
    for link in self.links:
        source = (link.source_id, link.source_name)
        sink = (link.sink_id, link.sink_name)
        suffix = f'Link {source} <-> {sink}'
        for (i, (node_id, name)) in enumerate([source, sink]):
            node = node_map.get(node_id)
            if not node:
                raise ValueError(f'{suffix}, {node_id} is invalid node id, available nodes: {node_map.keys()}')
            block = get_block(node.block_id)
            if not block:
                blocks = {v().id: v().name for v in get_blocks().values()}
                raise ValueError(f'{suffix}, {node.block_id} is invalid block id, available blocks: {blocks}')
            sanitized_name = sanitize(name)
            vals = node.input_default
            if i == 0:
                fields = block.output_schema.get_fields() if block.block_type != BlockType.AGENT else vals.get('output_schema', {}).get('properties', {}).keys()
            else:
                fields = block.input_schema.get_fields() if block.block_type != BlockType.AGENT else vals.get('input_schema', {}).get('properties', {}).keys()
            if sanitized_name not in fields:
                fields_msg = f'Allowed fields: {fields}'
                raise ValueError(f'{suffix}, `{name}` invalid, {fields_msg}')
        if is_static_output_block(link.source_id):
            link.is_static = True
def sanitize(name):
    return name.split('_#_')[0].split('_@_')[0].split('_$_')[0]
return name.split('_#_')[0].split('_@_')[0].split('_$_')[0]
continue
node.input_default['user_id'] = user_id
node.input_default.setdefault('data', {})
input_links = defaultdict(list)
link
self.links
input_links[link.sink_id].append(link)
node
self.nodes
block = get_block(node.block_id)
block Is None
node_map = {v.id: v for v in self.nodes}
def is_static_output_block(nid: str) -> bool:
    bid = node_map[nid].block_id
    b = get_block(bid)
    return b.static_output if b else False
bid = node_map[nid].block_id
b = get_block(bid)
return b.static_output if b else False
raise ValueError(f'Invalid block {node.block_id} for node #{node.id}')
provided_inputs = set([sanitize(name) for name in node.input_default] + [sanitize(link.sink_name) for link in input_links.get(node.id, [])])
name
block.input_schema.get_required_fields()
name not in provided_inputs and (not (name == 'payload' and block.block_type in (BlockType.WEBHOOK, BlockType.WEBHOOK_MANUAL))) and (for_run or block.block_type == BlockType.INPUT or block.block_type == BlockType.OUTPUT or (block.block_type == BlockType.AGENT))
input_schema = block.input_schema.model_fields
required_fields = block.input_schema.get_required_fields()
def has_value(name):
    return node is not None and name in node.input_default and (node.input_default[name] is not None) and (str(node.input_default[name]).strip() != '') or (name in input_schema and input_schema[name].default is not None)
return node is not None and name in node.input_default and (node.input_default[name] is not None) and (str(node.input_default[name]).strip() != '') or (name in input_schema and input_schema[name].default is not None)
raise ValueError(f'Node {block.name} #{node.id} required input missing: `{name}`')
(field_name, field_info)
input_schema.items()
json_schema_extra = field_info.json_schema_extra or {}
dependencies = json_schema_extra.get('depends_on', [])
not for_run or not dependencies
continue
field_has_value = has_value(field_name)
field_is_required = field_name in required_fields
missing_deps = [dep for dep in dependencies if not has_value(dep)]
missing_deps and (field_has_value or field_is_required)
raise ValueError(f"Node {block.name} #{node.id}: Field `{field_name}` requires [{', '.join(missing_deps)}] to be set")
link
self.links
source = (link.source_id, link.source_name)
sink = (link.sink_id, link.sink_name)
suffix = f'Link {source} <-> {sink}'
@staticmethod
def from_db(graph: AgentGraph, for_export: bool=False):
    return GraphModel(id=graph.id, user_id=graph.userId, version=graph.version, is_active=graph.isActive, is_template=graph.isTemplate, name=graph.name or '', description=graph.description or '', nodes=[NodeModel.from_db(GraphModel._process_node(node, for_export)) for node in graph.AgentNodes or []], links=list({Link.from_db(link) for node in graph.AgentNodes or [] for link in (node.Input or []) + (node.Output or [])}))
return GraphModel(id=graph.id, user_id=graph.userId, version=graph.version, is_active=graph.isActive, is_template=graph.isTemplate, name=graph.name or '', description=graph.description or '', nodes=[NodeModel.from_db(GraphModel._process_node(node, for_export)) for node in graph.AgentNodes or []], links=list({Link.from_db(link) for node in graph.AgentNodes or [] for link in (node.Input or []) + (node.Output or [])}))
(i, (node_id, name))
enumerate([source, sink])
node = node_map.get(node_id)
not node
is_static_output_block(link.source_id)
raise ValueError(f'{suffix}, {node_id} is invalid node id, available nodes: {node_map.keys()}')
block = get_block(node.block_id)
not block
blocks = {v().id: v().name for v in get_blocks().values()}
raise ValueError(f'{suffix}, {node.block_id} is invalid block id, available blocks: {blocks}')
sanitized_name = sanitize(name)
vals = node.input_default
i Eq 0
fields = block.output_schema.get_fields() if block.block_type != BlockType.AGENT else vals.get('output_schema', {}).get('properties', {}).keys()
fields = block.input_schema.get_fields() if block.block_type != BlockType.AGENT else vals.get('input_schema', {}).get('properties', {}).keys()
sanitized_name NotIn fields
fields_msg = f'Allowed fields: {fields}'
raise ValueError(f'{suffix}, `{name}` invalid, {fields_msg}')
link.is_static = True
@staticmethod
def _process_node(node: AgentNode, for_export: bool) -> AgentNode:
    if for_export:
        if node.constantInput:
            constant_input = json.loads(node.constantInput, target_type=dict[str, Any])
            constant_input = GraphModel._hide_node_input_credentials(constant_input)
            node.constantInput = json.dumps(constant_input)
        node.webhookId = None
        node.Webhook = None
    return node
for_export
node.constantInput
return node
constant_input = json.loads(node.constantInput, target_type=dict[str, Any])
constant_input = GraphModel._hide_node_input_credentials(constant_input)
node.constantInput = json.dumps(constant_input)
node.webhookId = None
node.Webhook = None
@staticmethod
def _hide_node_input_credentials(input_data: dict[str, Any]) -> dict[str, Any]:
    sensitive_keys = ['credentials', 'api_key', 'password', 'token', 'secret']
    result = {}
    for (key, value) in input_data.items():
        if isinstance(value, dict):
            result[key] = GraphModel._hide_node_input_credentials(value)
        elif isinstance(value, str) and any((sensitive_key in key.lower() for sensitive_key in sensitive_keys)):
            continue
        else:
            result[key] = value
    return result
sensitive_keys = ['credentials', 'api_key', 'password', 'token', 'secret']
result = {}
(key, value)
input_data.items()
isinstance(value, dict)
return result
result[key] = GraphModel._hide_node_input_credentials(value)
isinstance(value, str) and any((sensitive_key in key.lower() for sensitive_key in sensitive_keys))
continue
result[key] = value
async def get_node(node_id: str) -> NodeModel:
    node = await AgentNode.prisma().find_unique_or_raise(where={'id': node_id}, include=AGENT_NODE_INCLUDE)
    return NodeModel.from_db(node)
node = await AgentNode.prisma().find_unique_or_raise(where={'id': node_id}, include=AGENT_NODE_INCLUDE)
return NodeModel.from_db(node)
async def set_node_webhook(node_id: str, webhook_id: str | None) -> NodeModel:
    node = await AgentNode.prisma().update(where={'id': node_id}, data={'Webhook': {'connect': {'id': webhook_id}}} if webhook_id else {'Webhook': {'disconnect': True}}, include=AGENT_NODE_INCLUDE)
    if not node:
        raise ValueError(f'Node #{node_id} not found')
    return NodeModel.from_db(node)
node = await AgentNode.prisma().update(where={'id': node_id}, data={'Webhook': {'connect': {'id': webhook_id}}} if webhook_id else {'Webhook': {'disconnect': True}}, include=AGENT_NODE_INCLUDE)
not node
raise ValueError(f'Node #{node_id} not found')
return NodeModel.from_db(node)
async def get_graphs(user_id: str, filter_by: Literal['active', 'template'] | None='active') -> list[GraphModel]:
    """
    Retrieves graph metadata objects.
    Default behaviour is to get all currently active graphs.

    Args:
        filter_by: An optional filter to either select templates or active graphs.
        user_id: The ID of the user that owns the graph.

    Returns:
        list[GraphModel]: A list of objects representing the retrieved graphs.
    """
    where_clause: AgentGraphWhereInput = {'userId': user_id}
    if filter_by == 'active':
        where_clause['isActive'] = True
    elif filter_by == 'template':
        where_clause['isTemplate'] = True
    graphs = await AgentGraph.prisma().find_many(where=where_clause, distinct=['id'], order={'version': 'desc'}, include=AGENT_GRAPH_INCLUDE)
    graph_models = []
    for graph in graphs:
        try:
            graph_models.append(GraphModel.from_db(graph))
        except Exception as e:
            logger.error(f'Error processing graph {graph.id}: {e}')
            continue
    return graph_models
'\n    Retrieves graph metadata objects.\n    Default behaviour is to get all currently active graphs.\n\n    Args:\n        filter_by: An optional filter to either select templates or active graphs.\n        user_id: The ID of the user that owns the graph.\n\n    Returns:\n        list[GraphModel]: A list of objects representing the retrieved graphs.\n    '
where_clause: AgentGraphWhereInput = {'userId': user_id}
filter_by Eq 'active'
where_clause['isActive'] = True
filter_by Eq 'template'
graphs = await AgentGraph.prisma().find_many(where=where_clause, distinct=['id'], order={'version': 'desc'}, include=AGENT_GRAPH_INCLUDE)
graph_models = []
where_clause['isTemplate'] = True
graph
graphs
try:
    graph_models.append(GraphModel.from_db(graph))
except Exception as e:
    logger.error(f'Error processing graph {graph.id}: {e}')
    continue
graph_models.append(GraphModel.from_db(graph))
logger.error(f'Error processing graph {graph.id}: {e}')
continue
return graph_models
async def get_executions(user_id: str) -> list[GraphExecution]:
    executions = await AgentGraphExecution.prisma().find_many(where={'userId': user_id}, order={'createdAt': 'desc'})
    return [GraphExecution.from_db(execution) for execution in executions]
executions = await AgentGraphExecution.prisma().find_many(where={'userId': user_id}, order={'createdAt': 'desc'})
return [GraphExecution.from_db(execution) for execution in executions]
async def get_execution(user_id: str, execution_id: str) -> GraphExecution | None:
    execution = await AgentGraphExecution.prisma().find_first(where={'id': execution_id, 'userId': user_id})
    return GraphExecution.from_db(execution) if execution else None
execution = await AgentGraphExecution.prisma().find_first(where={'id': execution_id, 'userId': user_id})
return GraphExecution.from_db(execution) if execution else None
async def get_graph(graph_id: str, version: int | None=None, template: bool=False, user_id: str | None=None, for_export: bool=False) -> GraphModel | None:
    """
    Retrieves a graph from the DB.
    Defaults to the version with `is_active` if `version` is not passed,
    or the latest version with `is_template` if `template=True`.

    Returns `None` if the record is not found.
    """
    where_clause: AgentGraphWhereInput = {'id': graph_id}
    if version is not None:
        where_clause['version'] = version
    elif not template:
        where_clause['isActive'] = True
    if user_id is not None and (not template):
        where_clause['userId'] = user_id
    graph = await AgentGraph.prisma().find_first(where=where_clause, include=AGENT_GRAPH_INCLUDE, order={'version': 'desc'})
    return GraphModel.from_db(graph, for_export) if graph else None
'\n    Retrieves a graph from the DB.\n    Defaults to the version with `is_active` if `version` is not passed,\n    or the latest version with `is_template` if `template=True`.\n\n    Returns `None` if the record is not found.\n    '
where_clause: AgentGraphWhereInput = {'id': graph_id}
version IsNot None
where_clause['version'] = version
not template
user_id is not None and (not template)
where_clause['isActive'] = True
where_clause['userId'] = user_id
graph = await AgentGraph.prisma().find_first(where=where_clause, include=AGENT_GRAPH_INCLUDE, order={'version': 'desc'})
return GraphModel.from_db(graph, for_export) if graph else None
async def set_graph_active_version(graph_id: str, version: int, user_id: str) -> None:
    updated_count = await AgentGraph.prisma().update_many(data={'isActive': True}, where={'id': graph_id, 'version': version, 'userId': user_id})
    if updated_count == 0:
        raise Exception(f'Graph #{graph_id} v{version} not found or not owned by user')
    await AgentGraph.prisma().update_many(data={'isActive': False}, where={'id': graph_id, 'version': {'not': version}, 'userId': user_id, 'isActive': True})
updated_count = await AgentGraph.prisma().update_many(data={'isActive': True}, where={'id': graph_id, 'version': version, 'userId': user_id})
updated_count Eq 0
raise Exception(f'Graph #{graph_id} v{version} not found or not owned by user')
await AgentGraph.prisma().update_many(data={'isActive': False}, where={'id': graph_id, 'version': {'not': version}, 'userId': user_id, 'isActive': True})
async def get_graph_all_versions(graph_id: str, user_id: str) -> list[GraphModel]:
    graph_versions = await AgentGraph.prisma().find_many(where={'id': graph_id, 'userId': user_id}, order={'version': 'desc'}, include=AGENT_GRAPH_INCLUDE)
    if not graph_versions:
        return []
    return [GraphModel.from_db(graph) for graph in graph_versions]
graph_versions = await AgentGraph.prisma().find_many(where={'id': graph_id, 'userId': user_id}, order={'version': 'desc'}, include=AGENT_GRAPH_INCLUDE)
not graph_versions
return []
async def delete_graph(graph_id: str, user_id: str) -> int:
    entries_count = await AgentGraph.prisma().delete_many(where={'id': graph_id, 'userId': user_id})
    if entries_count:
        logger.info(f'Deleted {entries_count} graph entries for Graph #{graph_id}')
    return entries_count
entries_count = await AgentGraph.prisma().delete_many(where={'id': graph_id, 'userId': user_id})
entries_count
logger.info(f'Deleted {entries_count} graph entries for Graph #{graph_id}')
return entries_count
async def create_graph(graph: Graph, user_id: str) -> GraphModel:
    async with transaction() as tx:
        await __create_graph(tx, graph, user_id)
    if (created_graph := (await get_graph(graph.id, graph.version, graph.is_template, user_id=user_id))):
        return created_graph
    raise ValueError(f'Created graph {graph.id} v{graph.version} is not in DB')
async with transaction() as tx:
    await __create_graph(tx, graph, user_id)
await __create_graph(tx, graph, user_id)
(created_graph := (await get_graph(graph.id, graph.version, graph.is_template, user_id=user_id)))
return created_graph
async def fix_llm_provider_credentials():
    """Fix node credentials with provider `llm`"""
    from backend.integrations.credentials_store import IntegrationCredentialsStore
    from .user import get_user_integrations
    store = IntegrationCredentialsStore()
    broken_nodes = await prisma.get_client().query_raw('\n        SELECT    graph."userId"       user_id,\n                  node.id              node_id,\n                  node."constantInput" node_preset_input\n        FROM      platform."AgentNode"  node\n        LEFT JOIN platform."AgentGraph" graph\n        ON        node."agentGraphId" = graph.id\n        WHERE     node."constantInput"::jsonb->\'credentials\'->>\'provider\' = \'llm\'\n        ORDER BY  graph."userId";\n        ')
    logger.info(f'Fixing LLM credential inputs on {len(broken_nodes)} nodes')
    user_id: str = ''
    user_integrations = None
    for node in broken_nodes:
        if node['user_id'] != user_id:
            user_id = node['user_id']
            user_integrations = await get_user_integrations(user_id)
        elif not user_integrations:
            raise RuntimeError(f'Impossible state while processing node {node}')
        node_id: str = node['node_id']
        node_preset_input: dict = json.loads(node['node_preset_input'])
        credentials_meta: dict = node_preset_input['credentials']
        credentials = next((c for c in user_integrations.credentials if c.id == credentials_meta['id']), None)
        if not credentials:
            continue
        if credentials.type != 'api_key':
            logger.warning(f"User {user_id} credentials {credentials.id} with provider 'llm' has invalid type '{credentials.type}'")
            continue
        api_key = credentials.api_key.get_secret_value()
        if api_key.startswith('sk-ant-api03-'):
            credentials.provider = credentials_meta['provider'] = 'anthropic'
        elif api_key.startswith('sk-'):
            credentials.provider = credentials_meta['provider'] = 'openai'
        elif api_key.startswith('gsk_'):
            credentials.provider = credentials_meta['provider'] = 'groq'
        else:
            logger.warning(f'Could not identify provider from key prefix {api_key[:13]}*****')
            continue
        store.update_creds(user_id, credentials)
        await AgentNode.prisma().update(where={'id': node_id}, data={'constantInput': json.dumps(node_preset_input)})
'Fix node credentials with provider `llm`'
from backend.integrations.credentials_store import IntegrationCredentialsStore
from .user import get_user_integrations
store = IntegrationCredentialsStore()
broken_nodes = await prisma.get_client().query_raw('\n        SELECT    graph."userId"       user_id,\n                  node.id              node_id,\n                  node."constantInput" node_preset_input\n        FROM      platform."AgentNode"  node\n        LEFT JOIN platform."AgentGraph" graph\n        ON        node."agentGraphId" = graph.id\n        WHERE     node."constantInput"::jsonb->\'credentials\'->>\'provider\' = \'llm\'\n        ORDER BY  graph."userId";\n        ')
logger.info(f'Fixing LLM credential inputs on {len(broken_nodes)} nodes')
user_id: str = ''
user_integrations = None
node
broken_nodes
node['user_id'] NotEq user_id
user_id = node['user_id']
user_integrations = await get_user_integrations(user_id)
not user_integrations
node_id: str = node['node_id']
node_preset_input: dict = json.loads(node['node_preset_input'])
credentials_meta: dict = node_preset_input['credentials']
credentials = next((c for c in user_integrations.credentials if c.id == credentials_meta['id']), None)
not credentials
raise RuntimeError(f'Impossible state while processing node {node}')
continue
credentials.type NotEq 'api_key'
logger.warning(f"User {user_id} credentials {credentials.id} with provider 'llm' has invalid type '{credentials.type}'")
continue
api_key = credentials.api_key.get_secret_value()
api_key.startswith('sk-ant-api03-')
credentials.provider = credentials_meta['provider'] = 'anthropic'
api_key.startswith('sk-')
store.update_creds(user_id, credentials)
await AgentNode.prisma().update(where={'id': node_id}, data={'constantInput': json.dumps(node_preset_input)})
credentials.provider = credentials_meta['provider'] = 'openai'
api_key.startswith('gsk_')
credentials.provider = credentials_meta['provider'] = 'groq'
logger.warning(f'Could not identify provider from key prefix {api_key[:13]}*****')
continue