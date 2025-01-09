import atexit
import logging
import multiprocessing
import os
import signal
import sys
import threading
from concurrent.futures import Future, ProcessPoolExecutor
from contextlib import contextmanager
from multiprocessing.pool import AsyncResult, Pool
from typing import TYPE_CHECKING, Any, Generator, TypeVar, cast
from pydantic import BaseModel
from redis.lock import Lock as RedisLock
TYPE_CHECKING
from backend.executor import DatabaseManager
from autogpt_libs.utils.cache import thread_cached
from backend.blocks.agent import AgentExecutorBlock
from backend.data import redis
from backend.data.block import Block, BlockData, BlockInput, BlockType, get_block
from backend.data.execution import ExecutionQueue, ExecutionResult, ExecutionStatus, GraphExecutionEntry, NodeExecutionEntry, merge_execution_input, parse_execution_output
from backend.data.graph import GraphModel, Link, Node
from backend.data.model import CREDENTIALS_FIELD_NAME, CredentialsMetaInput
from backend.integrations.creds_manager import IntegrationCredentialsManager
from backend.util import json
from backend.util.decorator import error_logged, time_measured
from backend.util.logging import configure_logging
from backend.util.process import set_service_name
from backend.util.service import AppService, close_service_client, expose, get_service_client
from backend.util.settings import Settings
from backend.util.type import convert
logger = logging.getLogger(__name__)
settings = Settings()
class LogMetadata:

    def __init__(self, user_id: str, graph_eid: str, graph_id: str, node_eid: str, node_id: str, block_name: str):
        self.metadata = {'component': 'ExecutionManager', 'user_id': user_id, 'graph_eid': graph_eid, 'graph_id': graph_id, 'node_eid': node_eid, 'node_id': node_id, 'block_name': block_name}
        self.prefix = f'[ExecutionManager|uid:{user_id}|gid:{graph_id}|nid:{node_id}]|geid:{graph_eid}|nid:{node_eid}|{block_name}]'

    def info(self, msg: str, **extra):
        msg = self._wrap(msg, **extra)
        logger.info(msg, extra={'json_fields': {**self.metadata, **extra}})

    def warning(self, msg: str, **extra):
        msg = self._wrap(msg, **extra)
        logger.warning(msg, extra={'json_fields': {**self.metadata, **extra}})

    def error(self, msg: str, **extra):
        msg = self._wrap(msg, **extra)
        logger.error(msg, extra={'json_fields': {**self.metadata, **extra}})

    def debug(self, msg: str, **extra):
        msg = self._wrap(msg, **extra)
        logger.debug(msg, extra={'json_fields': {**self.metadata, **extra}})

    def exception(self, msg: str, **extra):
        msg = self._wrap(msg, **extra)
        logger.exception(msg, extra={'json_fields': {**self.metadata, **extra}})

    def _wrap(self, msg: str, **extra):
        return f'{self.prefix} {msg} {extra}'
def __init__(self, user_id: str, graph_eid: str, graph_id: str, node_eid: str, node_id: str, block_name: str):
    self.metadata = {'component': 'ExecutionManager', 'user_id': user_id, 'graph_eid': graph_eid, 'graph_id': graph_id, 'node_eid': node_eid, 'node_id': node_id, 'block_name': block_name}
    self.prefix = f'[ExecutionManager|uid:{user_id}|gid:{graph_id}|nid:{node_id}]|geid:{graph_eid}|nid:{node_eid}|{block_name}]'
self.metadata = {'component': 'ExecutionManager', 'user_id': user_id, 'graph_eid': graph_eid, 'graph_id': graph_id, 'node_eid': node_eid, 'node_id': node_id, 'block_name': block_name}
self.prefix = f'[ExecutionManager|uid:{user_id}|gid:{graph_id}|nid:{node_id}]|geid:{graph_eid}|nid:{node_eid}|{block_name}]'
def info(self, msg: str, **extra):
    msg = self._wrap(msg, **extra)
    logger.info(msg, extra={'json_fields': {**self.metadata, **extra}})
msg = self._wrap(msg, **extra)
logger.info(msg)
def warning(self, msg: str, **extra):
    msg = self._wrap(msg, **extra)
    logger.warning(msg, extra={'json_fields': {**self.metadata, **extra}})
msg = self._wrap(msg, **extra)
logger.warning(msg)
def error(self, msg: str, **extra):
    msg = self._wrap(msg, **extra)
    logger.error(msg, extra={'json_fields': {**self.metadata, **extra}})
msg = self._wrap(msg, **extra)
logger.error(msg)
def debug(self, msg: str, **extra):
    msg = self._wrap(msg, **extra)
    logger.debug(msg, extra={'json_fields': {**self.metadata, **extra}})
msg = self._wrap(msg, **extra)
logger.debug(msg)
def exception(self, msg: str, **extra):
    msg = self._wrap(msg, **extra)
    logger.exception(msg, extra={'json_fields': {**self.metadata, **extra}})
msg = self._wrap(msg, **extra)
logger.exception(msg)
def _wrap(self, msg: str, **extra):
    return f'{self.prefix} {msg} {extra}'
return f'{self.prefix} {msg} {extra}'
T = TypeVar('T')
ExecutionStream = Generator[NodeExecutionEntry, None, None]
def execute_node(db_client: 'DatabaseManager', creds_manager: IntegrationCredentialsManager, data: NodeExecutionEntry, execution_stats: dict[str, Any] | None=None) -> ExecutionStream:
    """
    Execute a node in the graph. This will trigger a block execution on a node,
    persist the execution result, and return the subsequent node to be executed.

    Args:
        db_client: The client to send execution updates to the server.
        creds_manager: The manager to acquire and release credentials.
        data: The execution data for executing the current node.
        execution_stats: The execution statistics to be updated.

    Returns:
        The subsequent node to be enqueued, or None if there is no subsequent node.
    """
    user_id = data.user_id
    graph_exec_id = data.graph_exec_id
    graph_id = data.graph_id
    node_exec_id = data.node_exec_id
    node_id = data.node_id

    def update_execution(status: ExecutionStatus) -> ExecutionResult:
        exec_update = db_client.update_execution_status(node_exec_id, status)
        db_client.send_execution_update(exec_update)
        return exec_update
    node = db_client.get_node(node_id)
    node_block = get_block(node.block_id)
    if not node_block:
        logger.error(f'Block {node.block_id} not found.')
        return
    log_metadata = LogMetadata(user_id=user_id, graph_eid=graph_exec_id, graph_id=graph_id, node_eid=node_exec_id, node_id=node_id, block_name=node_block.name)
    (input_data, error) = validate_exec(node, data.data, resolve_input=False)
    if input_data is None:
        log_metadata.error(f'Skip execution, input validation error: {error}')
        db_client.upsert_execution_output(node_exec_id, 'error', error)
        update_execution(ExecutionStatus.FAILED)
        return
    if isinstance(node_block, AgentExecutorBlock):
        input_data = {**node.input_default, 'data': input_data}
    input_data_str = json.dumps(input_data)
    input_size = len(input_data_str)
    log_metadata.info('Executed node with input', input=input_data_str)
    update_execution(ExecutionStatus.RUNNING)
    extra_exec_kwargs = {}
    creds_lock = None
    if CREDENTIALS_FIELD_NAME in input_data:
        credentials_meta = CredentialsMetaInput(**input_data[CREDENTIALS_FIELD_NAME])
        (credentials, creds_lock) = creds_manager.acquire(user_id, credentials_meta.id)
        extra_exec_kwargs['credentials'] = credentials
    output_size = 0
    end_status = ExecutionStatus.COMPLETED
    credit = db_client.get_or_refill_credit(user_id)
    if credit < 0:
        raise ValueError(f'Insufficient credit: {credit}')
    try:
        for (output_name, output_data) in node_block.execute(input_data, **extra_exec_kwargs):
            output_size += len(json.dumps(output_data))
            log_metadata.info('Node produced output', **{output_name: output_data})
            db_client.upsert_execution_output(node_exec_id, output_name, output_data)
            for execution in _enqueue_next_nodes(db_client=db_client, node=node, output=(output_name, output_data), user_id=user_id, graph_exec_id=graph_exec_id, graph_id=graph_id, log_metadata=log_metadata):
                yield execution
    except Exception as e:
        end_status = ExecutionStatus.FAILED
        error_msg = str(e)
        log_metadata.exception(f'Node execution failed with error {error_msg}')
        db_client.upsert_execution_output(node_exec_id, 'error', error_msg)
        for execution in _enqueue_next_nodes(db_client=db_client, node=node, output=('error', error_msg), user_id=user_id, graph_exec_id=graph_exec_id, graph_id=graph_id, log_metadata=log_metadata):
            yield execution
        raise e
    finally:
        if creds_lock:
            try:
                creds_lock.release()
            except Exception as e:
                log_metadata.error(f'Failed to release credentials lock: {e}')
        res = update_execution(end_status)
        if end_status == ExecutionStatus.COMPLETED:
            s = input_size + output_size
            t = (res.end_time - res.start_time).total_seconds() if res.end_time and res.start_time else 0
            db_client.spend_credits(user_id, credit, node_block.id, input_data, s, t)
        if execution_stats is not None:
            execution_stats.update(node_block.execution_stats)
            execution_stats['input_size'] = input_size
            execution_stats['output_size'] = output_size
'\n    Execute a node in the graph. This will trigger a block execution on a node,\n    persist the execution result, and return the subsequent node to be executed.\n\n    Args:\n        db_client: The client to send execution updates to the server.\n        creds_manager: The manager to acquire and release credentials.\n        data: The execution data for executing the current node.\n        execution_stats: The execution statistics to be updated.\n\n    Returns:\n        The subsequent node to be enqueued, or None if there is no subsequent node.\n    '
user_id = data.user_id
graph_exec_id = data.graph_exec_id
graph_id = data.graph_id
node_exec_id = data.node_exec_id
node_id = data.node_id
def update_execution(status: ExecutionStatus) -> ExecutionResult:
    exec_update = db_client.update_execution_status(node_exec_id, status)
    db_client.send_execution_update(exec_update)
    return exec_update
exec_update = db_client.update_execution_status(node_exec_id, status)
db_client.send_execution_update(exec_update)
return exec_update
node = db_client.get_node(node_id)
node_block = get_block(node.block_id)
not node_block
logger.error(f'Block {node.block_id} not found.')
return
log_metadata.error(f'Skip execution, input validation error: {error}')
db_client.upsert_execution_output(node_exec_id, 'error', error)
update_execution(ExecutionStatus.FAILED)
return
input_data = {**node.input_default, 'data': input_data}
input_data_str = json.dumps(input_data)
input_size = len(input_data_str)
log_metadata.info('Executed node with input')
update_execution(ExecutionStatus.RUNNING)
extra_exec_kwargs = {}
creds_lock = None
CREDENTIALS_FIELD_NAME In input_data
credentials_meta = CredentialsMetaInput(**input_data[CREDENTIALS_FIELD_NAME])
(credentials, creds_lock) = creds_manager.acquire(user_id, credentials_meta.id)
extra_exec_kwargs['credentials'] = credentials
output_size = 0
end_status = ExecutionStatus.COMPLETED
credit = db_client.get_or_refill_credit(user_id)
credit Lt 0
raise ValueError(f'Insufficient credit: {credit}')
try:
    for (output_name, output_data) in node_block.execute(input_data, **extra_exec_kwargs):
        output_size += len(json.dumps(output_data))
        log_metadata.info('Node produced output', **{output_name: output_data})
        db_client.upsert_execution_output(node_exec_id, output_name, output_data)
        for execution in _enqueue_next_nodes(db_client=db_client, node=node, output=(output_name, output_data), user_id=user_id, graph_exec_id=graph_exec_id, graph_id=graph_id, log_metadata=log_metadata):
            yield execution
except Exception as e:
    end_status = ExecutionStatus.FAILED
    error_msg = str(e)
    log_metadata.exception(f'Node execution failed with error {error_msg}')
    db_client.upsert_execution_output(node_exec_id, 'error', error_msg)
    for execution in _enqueue_next_nodes(db_client=db_client, node=node, output=('error', error_msg), user_id=user_id, graph_exec_id=graph_exec_id, graph_id=graph_id, log_metadata=log_metadata):
        yield execution
    raise e
finally:
    if creds_lock:
        try:
            creds_lock.release()
        except Exception as e:
            log_metadata.error(f'Failed to release credentials lock: {e}')
    res = update_execution(end_status)
    if end_status == ExecutionStatus.COMPLETED:
        s = input_size + output_size
        t = (res.end_time - res.start_time).total_seconds() if res.end_time and res.start_time else 0
        db_client.spend_credits(user_id, credit, node_block.id, input_data, s, t)
    if execution_stats is not None:
        execution_stats.update(node_block.execution_stats)
        execution_stats['input_size'] = input_size
        execution_stats['output_size'] = output_size
(output_name, output_data)
node_block.execute(input_data)
output_size += len(json.dumps(output_data))
log_metadata.info('Node produced output')
db_client.upsert_execution_output(node_exec_id, output_name, output_data)
end_status = ExecutionStatus.FAILED
error_msg = str(e)
log_metadata.exception(f'Node execution failed with error {error_msg}')
db_client.upsert_execution_output(node_exec_id, 'error', error_msg)
execution
_enqueue_next_nodes()
(yield execution)
execution
_enqueue_next_nodes()
(yield execution)
raise e
creds_lock
try:
    creds_lock.release()
except Exception as e:
    log_metadata.error(f'Failed to release credentials lock: {e}')
creds_lock.release()
log_metadata.error(f'Failed to release credentials lock: {e}')
res = update_execution(end_status)
end_status Eq ExecutionStatus.COMPLETED
s = input_size + output_size
t = (res.end_time - res.start_time).total_seconds() if res.end_time and res.start_time else 0
db_client.spend_credits(user_id, credit, node_block.id, input_data, s, t)
execution_stats IsNot None
execution_stats.update(node_block.execution_stats)
execution_stats['input_size'] = input_size
execution_stats['output_size'] = output_size
def _enqueue_next_nodes(db_client: 'DatabaseManager', node: Node, output: BlockData, user_id: str, graph_exec_id: str, graph_id: str, log_metadata: LogMetadata) -> list[NodeExecutionEntry]:

    def add_enqueued_execution(node_exec_id: str, node_id: str, data: BlockInput) -> NodeExecutionEntry:
        exec_update = db_client.update_execution_status(node_exec_id, ExecutionStatus.QUEUED, data)
        db_client.send_execution_update(exec_update)
        return NodeExecutionEntry(user_id=user_id, graph_exec_id=graph_exec_id, graph_id=graph_id, node_exec_id=node_exec_id, node_id=node_id, data=data)

    def register_next_executions(node_link: Link) -> list[NodeExecutionEntry]:
        enqueued_executions = []
        next_output_name = node_link.source_name
        next_input_name = node_link.sink_name
        next_node_id = node_link.sink_id
        next_data = parse_execution_output(output, next_output_name)
        if next_data is None:
            return enqueued_executions
        next_node = db_client.get_node(next_node_id)
        with synchronized(f'upsert_input-{next_node_id}-{graph_exec_id}'):
            (next_node_exec_id, next_node_input) = db_client.upsert_execution_input(node_id=next_node_id, graph_exec_id=graph_exec_id, input_name=next_input_name, input_data=next_data)
            static_link_names = {link.sink_name for link in next_node.input_links if link.is_static and link.sink_name not in next_node_input}
            if static_link_names and (latest_execution := db_client.get_latest_execution(next_node_id, graph_exec_id)):
                for name in static_link_names:
                    next_node_input[name] = latest_execution.input_data.get(name)
            (next_node_input, validation_msg) = validate_exec(next_node, next_node_input)
            suffix = f'{next_output_name}>{next_input_name}~{next_node_exec_id}:{validation_msg}'
            if not next_node_input:
                log_metadata.warning(f'Skipped queueing {suffix}')
                return enqueued_executions
            log_metadata.info(f'Enqueued {suffix}')
            enqueued_executions.append(add_enqueued_execution(next_node_exec_id, next_node_id, next_node_input))
            if not node_link.is_static:
                return enqueued_executions
            for iexec in db_client.get_incomplete_executions(next_node_id, graph_exec_id):
                idata = iexec.input_data
                ineid = iexec.node_exec_id
                static_link_names = {link.sink_name for link in next_node.input_links if link.is_static and link.sink_name not in idata}
                for input_name in static_link_names:
                    idata[input_name] = next_node_input[input_name]
                (idata, msg) = validate_exec(next_node, idata)
                suffix = f'{next_output_name}>{next_input_name}~{ineid}:{msg}'
                if not idata:
                    log_metadata.info(f'Enqueueing static-link skipped: {suffix}')
                    continue
                log_metadata.info(f'Enqueueing static-link execution {suffix}')
                enqueued_executions.append(add_enqueued_execution(iexec.node_exec_id, next_node_id, idata))
            return enqueued_executions
    return [execution for link in node.output_links for execution in register_next_executions(link)]
def add_enqueued_execution(node_exec_id: str, node_id: str, data: BlockInput) -> NodeExecutionEntry:
    exec_update = db_client.update_execution_status(node_exec_id, ExecutionStatus.QUEUED, data)
    db_client.send_execution_update(exec_update)
    return NodeExecutionEntry(user_id=user_id, graph_exec_id=graph_exec_id, graph_id=graph_id, node_exec_id=node_exec_id, node_id=node_id, data=data)
exec_update = db_client.update_execution_status(node_exec_id, ExecutionStatus.QUEUED, data)
db_client.send_execution_update(exec_update)
return NodeExecutionEntry(user_id=user_id, graph_exec_id=graph_exec_id, graph_id=graph_id, node_exec_id=node_exec_id, node_id=node_id, data=data)
def register_next_executions(node_link: Link) -> list[NodeExecutionEntry]:
    enqueued_executions = []
    next_output_name = node_link.source_name
    next_input_name = node_link.sink_name
    next_node_id = node_link.sink_id
    next_data = parse_execution_output(output, next_output_name)
    if next_data is None:
        return enqueued_executions
    next_node = db_client.get_node(next_node_id)
    with synchronized(f'upsert_input-{next_node_id}-{graph_exec_id}'):
        (next_node_exec_id, next_node_input) = db_client.upsert_execution_input(node_id=next_node_id, graph_exec_id=graph_exec_id, input_name=next_input_name, input_data=next_data)
        static_link_names = {link.sink_name for link in next_node.input_links if link.is_static and link.sink_name not in next_node_input}
        if static_link_names and (latest_execution := db_client.get_latest_execution(next_node_id, graph_exec_id)):
            for name in static_link_names:
                next_node_input[name] = latest_execution.input_data.get(name)
        (next_node_input, validation_msg) = validate_exec(next_node, next_node_input)
        suffix = f'{next_output_name}>{next_input_name}~{next_node_exec_id}:{validation_msg}'
        if not next_node_input:
            log_metadata.warning(f'Skipped queueing {suffix}')
            return enqueued_executions
        log_metadata.info(f'Enqueued {suffix}')
        enqueued_executions.append(add_enqueued_execution(next_node_exec_id, next_node_id, next_node_input))
        if not node_link.is_static:
            return enqueued_executions
        for iexec in db_client.get_incomplete_executions(next_node_id, graph_exec_id):
            idata = iexec.input_data
            ineid = iexec.node_exec_id
            static_link_names = {link.sink_name for link in next_node.input_links if link.is_static and link.sink_name not in idata}
            for input_name in static_link_names:
                idata[input_name] = next_node_input[input_name]
            (idata, msg) = validate_exec(next_node, idata)
            suffix = f'{next_output_name}>{next_input_name}~{ineid}:{msg}'
            if not idata:
                log_metadata.info(f'Enqueueing static-link skipped: {suffix}')
                continue
            log_metadata.info(f'Enqueueing static-link execution {suffix}')
            enqueued_executions.append(add_enqueued_execution(iexec.node_exec_id, next_node_id, idata))
        return enqueued_executions
enqueued_executions = []
next_output_name = node_link.source_name
next_input_name = node_link.sink_name
next_node_id = node_link.sink_id
next_data = parse_execution_output(output, next_output_name)
next_data Is None
return enqueued_executions
(next_node_input, validation_msg) = validate_exec(next_node, next_node_input)
suffix = f'{next_output_name}>{next_input_name}~{next_node_exec_id}:{validation_msg}'
not next_node_input
name
static_link_names
next_node_input[name] = latest_execution.input_data.get(name)
log_metadata.warning(f'Skipped queueing {suffix}')
return enqueued_executions
return enqueued_executions
iexec
db_client.get_incomplete_executions(next_node_id, graph_exec_id)
idata = iexec.input_data
ineid = iexec.node_exec_id
static_link_names = {link.sink_name for link in next_node.input_links if link.is_static and link.sink_name not in idata}
return enqueued_executions
input_name
static_link_names
idata[input_name] = next_node_input[input_name]
(idata, msg) = validate_exec(next_node, idata)
suffix = f'{next_output_name}>{next_input_name}~{ineid}:{msg}'
not idata
log_metadata.info(f'Enqueueing static-link skipped: {suffix}')
continue
log_metadata.info(f'Enqueueing static-link execution {suffix}')
enqueued_executions.append(add_enqueued_execution(iexec.node_exec_id, next_node_id, idata))
return [execution for link in node.output_links for execution in register_next_executions(link)]
def validate_exec(node: Node, data: BlockInput, resolve_input: bool=True) -> tuple[BlockInput | None, str]:
    """
    Validate the input data for a node execution.

    Args:
        node: The node to execute.
        data: The input data for the node execution.
        resolve_input: Whether to resolve dynamic pins into dict/list/object.

    Returns:
        A tuple of the validated data and the block name.
        If the data is invalid, the first element will be None, and the second element
        will be an error message.
        If the data is valid, the first element will be the resolved input data, and
        the second element will be the block name.
    """
    node_block: Block | None = get_block(node.block_id)
    if not node_block:
        return (None, f'Block for {node.block_id} not found.')
    if isinstance(node_block, AgentExecutorBlock):
        try:
            exec_data = AgentExecutorBlock.Input(**node.input_default)
        except Exception as e:
            return (None, f"Input data doesn't match {node_block.name}: {str(e)}")
        input_schema = exec_data.input_schema
        required_fields = set(input_schema['required'])
        input_default = exec_data.data
    else:
        for (name, data_type) in node_block.input_schema.__annotations__.items():
            if (value := data.get(name)) and type(value) is not data_type:
                data[name] = convert(value, data_type)
        input_schema = node_block.input_schema.jsonschema()
        required_fields = node_block.input_schema.get_required_fields()
        input_default = node.input_default
    error_prefix = f'Input data missing or mismatch for `{node_block.name}`:'
    input_fields_from_nodes = {link.sink_name for link in node.input_links}
    if not input_fields_from_nodes.issubset(data):
        return (None, f'{error_prefix} {input_fields_from_nodes - set(data)}')
    data = {**input_default, **data}
    if resolve_input:
        data = merge_execution_input(data)
    if not required_fields.issubset(data):
        return (None, f'{error_prefix} {required_fields - set(data)}')
    if (error := json.validate_with_jsonschema(schema=input_schema, data=data)):
        error_message = f'{error_prefix} {error}'
        logger.error(error_message)
        return (None, error_message)
    return (data, node_block.name)
'\n    Validate the input data for a node execution.\n\n    Args:\n        node: The node to execute.\n        data: The input data for the node execution.\n        resolve_input: Whether to resolve dynamic pins into dict/list/object.\n\n    Returns:\n        A tuple of the validated data and the block name.\n        If the data is invalid, the first element will be None, and the second element\n        will be an error message.\n        If the data is valid, the first element will be the resolved input data, and\n        the second element will be the block name.\n    '
node_block: Block | None = get_block(node.block_id)
not node_block
return (None, f'Block for {node.block_id} not found.')
try:
    exec_data = AgentExecutorBlock.Input(**node.input_default)
except Exception as e:
    return (None, f"Input data doesn't match {node_block.name}: {str(e)}")
exec_data = AgentExecutorBlock.Input(**node.input_default)
return (None, f"Input data doesn't match {node_block.name}: {str(e)}")
error_prefix = f'Input data missing or mismatch for `{node_block.name}`:'
input_fields_from_nodes = {link.sink_name for link in node.input_links}
not input_fields_from_nodes.issubset(data)
input_schema = exec_data.input_schema
required_fields = set(input_schema['required'])
input_default = exec_data.data
(name, data_type)
node_block.input_schema.__annotations__.items()
(value := data.get(name)) and type(value) is not data_type
input_schema = node_block.input_schema.jsonschema()
required_fields = node_block.input_schema.get_required_fields()
input_default = node.input_default
data[name] = convert(value, data_type)
return (None, f'{error_prefix} {input_fields_from_nodes - set(data)}')
data = merge_execution_input(data)
not required_fields.issubset(data)
return (None, f'{error_prefix} {required_fields - set(data)}')
error_message = f'{error_prefix} {error}'
logger.error(error_message)
return (None, error_message)
class Executor:
    """
    This class contains event handlers for the process pool executor events.

    The main events are:
        on_node_executor_start: Initialize the process that executes the node.
        on_node_execution: Execution logic for a node.

        on_graph_executor_start: Initialize the process that executes the graph.
        on_graph_execution: Execution logic for a graph.

    The execution flow:
        1. Graph execution request is added to the queue.
        2. Graph executor loop picks the request from the queue.
        3. Graph executor loop submits the graph execution request to the executor pool.
      [on_graph_execution]
        4. Graph executor initialize the node execution queue.
        5. Graph executor adds the starting nodes to the node execution queue.
        6. Graph executor waits for all nodes to be executed.
      [on_node_execution]
        7. Node executor picks the node execution request from the queue.
        8. Node executor executes the node.
        9. Node executor enqueues the next executed nodes to the node execution queue.
    """

    @classmethod
    def on_node_executor_start(cls):
        configure_logging()
        set_service_name('NodeExecutor')
        redis.connect()
        cls.pid = os.getpid()
        cls.db_client = get_db_client()
        cls.creds_manager = IntegrationCredentialsManager()
        cls.shutdown_lock = threading.Lock()
        atexit.register(cls.on_node_executor_stop)
        signal.signal(signal.SIGTERM, lambda _, __: cls.on_node_executor_sigterm())

    @classmethod
    def on_node_executor_stop(cls):
        if not cls.shutdown_lock.acquire(blocking=False):
            return
        logger.info(f'[on_node_executor_stop {cls.pid}] ⏳ Releasing locks...')
        cls.creds_manager.release_all_locks()
        logger.info(f'[on_node_executor_stop {cls.pid}] ⏳ Disconnecting Redis...')
        redis.disconnect()
        logger.info(f'[on_node_executor_stop {cls.pid}] ⏳ Disconnecting DB manager...')
        close_service_client(cls.db_client)
        logger.info(f'[on_node_executor_stop {cls.pid}] ✅ Finished cleanup')

    @classmethod
    def on_node_executor_sigterm(cls):
        llprint(f'[on_node_executor_sigterm {cls.pid}] ⚠️ SIGTERM received')
        if not cls.shutdown_lock.acquire(blocking=False):
            return
        llprint(f'[on_node_executor_stop {cls.pid}] ⏳ Releasing locks...')
        cls.creds_manager.release_all_locks()
        llprint(f'[on_node_executor_stop {cls.pid}] ⏳ Disconnecting Redis...')
        redis.disconnect()
        llprint(f'[on_node_executor_stop {cls.pid}] ✅ Finished cleanup')
        sys.exit(0)

    @classmethod
    @error_logged
    def on_node_execution(cls, q: ExecutionQueue[NodeExecutionEntry], node_exec: NodeExecutionEntry) -> dict[str, Any]:
        log_metadata = LogMetadata(user_id=node_exec.user_id, graph_eid=node_exec.graph_exec_id, graph_id=node_exec.graph_id, node_eid=node_exec.node_exec_id, node_id=node_exec.node_id, block_name='-')
        execution_stats = {}
        (timing_info, _) = cls._on_node_execution(q, node_exec, log_metadata, execution_stats)
        execution_stats['walltime'] = timing_info.wall_time
        execution_stats['cputime'] = timing_info.cpu_time
        cls.db_client.update_node_execution_stats(node_exec.node_exec_id, execution_stats)
        return execution_stats

    @classmethod
    @time_measured
    def _on_node_execution(cls, q: ExecutionQueue[NodeExecutionEntry], node_exec: NodeExecutionEntry, log_metadata: LogMetadata, stats: dict[str, Any] | None=None):
        try:
            log_metadata.info(f'Start node execution {node_exec.node_exec_id}')
            for execution in execute_node(cls.db_client, cls.creds_manager, node_exec, stats):
                q.add(execution)
            log_metadata.info(f'Finished node execution {node_exec.node_exec_id}')
        except Exception as e:
            log_metadata.exception(f'Failed node execution {node_exec.node_exec_id}: {e}')

    @classmethod
    def on_graph_executor_start(cls):
        configure_logging()
        set_service_name('GraphExecutor')
        cls.db_client = get_db_client()
        cls.pool_size = settings.config.num_node_workers
        cls.pid = os.getpid()
        cls._init_node_executor_pool()
        logger.info(f'Graph executor {cls.pid} started with {cls.pool_size} node workers')
        atexit.register(cls.on_graph_executor_stop)

    @classmethod
    def on_graph_executor_stop(cls):
        prefix = f'[on_graph_executor_stop {cls.pid}]'
        logger.info(f'{prefix} ⏳ Terminating node executor pool...')
        cls.executor.terminate()
        logger.info(f'{prefix} ⏳ Disconnecting DB manager...')
        close_service_client(cls.db_client)
        logger.info(f'{prefix} ✅ Finished cleanup')

    @classmethod
    def _init_node_executor_pool(cls):
        cls.executor = Pool(processes=cls.pool_size, initializer=cls.on_node_executor_start)

    @classmethod
    @error_logged
    def on_graph_execution(cls, graph_exec: GraphExecutionEntry, cancel: threading.Event):
        log_metadata = LogMetadata(user_id=graph_exec.user_id, graph_eid=graph_exec.graph_exec_id, graph_id=graph_exec.graph_id, node_id='*', node_eid='*', block_name='-')
        (timing_info, (exec_stats, error)) = cls._on_graph_execution(graph_exec, cancel, log_metadata)
        exec_stats['walltime'] = timing_info.wall_time
        exec_stats['cputime'] = timing_info.cpu_time
        exec_stats['error'] = str(error) if error else None
        result = cls.db_client.update_graph_execution_stats(graph_exec_id=graph_exec.graph_exec_id, stats=exec_stats)
        cls.db_client.send_execution_update(result)

    @classmethod
    @time_measured
    def _on_graph_execution(cls, graph_exec: GraphExecutionEntry, cancel: threading.Event, log_metadata: LogMetadata) -> tuple[dict[str, Any], Exception | None]:
        """
        Returns:
            The execution statistics of the graph execution.
            The error that occurred during the execution.
        """
        log_metadata.info(f'Start graph execution {graph_exec.graph_exec_id}')
        exec_stats = {'nodes_walltime': 0, 'nodes_cputime': 0, 'node_count': 0}
        error = None
        finished = False

        def cancel_handler():
            while not cancel.is_set():
                cancel.wait(1)
            if finished:
                return
            cls.executor.terminate()
            log_metadata.info(f'Terminated graph execution {graph_exec.graph_exec_id}')
            cls._init_node_executor_pool()
        cancel_thread = threading.Thread(target=cancel_handler)
        cancel_thread.start()
        try:
            queue = ExecutionQueue[NodeExecutionEntry]()
            for node_exec in graph_exec.start_node_execs:
                queue.add(node_exec)
            running_executions: dict[str, AsyncResult] = {}

            def make_exec_callback(exec_data: NodeExecutionEntry):
                node_id = exec_data.node_id

                def callback(result: object):
                    running_executions.pop(node_id)
                    nonlocal exec_stats
                    if isinstance(result, dict):
                        exec_stats['node_count'] += 1
                        exec_stats['nodes_cputime'] += result.get('cputime', 0)
                        exec_stats['nodes_walltime'] += result.get('walltime', 0)
                return callback
            while not queue.empty():
                if cancel.is_set():
                    error = RuntimeError('Execution is cancelled')
                    return (exec_stats, error)
                exec_data = queue.get()
                execution = running_executions.get(exec_data.node_id)
                if execution and (not execution.ready()):
                    execution.wait()
                log_metadata.debug(f'Dispatching node execution {exec_data.node_exec_id} for node {exec_data.node_id}')
                running_executions[exec_data.node_id] = cls.executor.apply_async(cls.on_node_execution, (queue, exec_data), callback=make_exec_callback(exec_data))
                while queue.empty() and running_executions:
                    log_metadata.debug(f'Queue empty; running nodes: {list(running_executions.keys())}')
                    for (node_id, execution) in list(running_executions.items()):
                        if cancel.is_set():
                            error = RuntimeError('Execution is cancelled')
                            return (exec_stats, error)
                        if not queue.empty():
                            break
                        log_metadata.debug(f'Waiting on execution of node {node_id}')
                        execution.wait(3)
            log_metadata.info(f'Finished graph execution {graph_exec.graph_exec_id}')
        except Exception as e:
            log_metadata.exception(f'Failed graph execution {graph_exec.graph_exec_id}: {e}')
            error = e
        finally:
            if not cancel.is_set():
                finished = True
                cancel.set()
            cancel_thread.join()
            return (exec_stats, error)
'\n    This class contains event handlers for the process pool executor events.\n\n    The main events are:\n        on_node_executor_start: Initialize the process that executes the node.\n        on_node_execution: Execution logic for a node.\n\n        on_graph_executor_start: Initialize the process that executes the graph.\n        on_graph_execution: Execution logic for a graph.\n\n    The execution flow:\n        1. Graph execution request is added to the queue.\n        2. Graph executor loop picks the request from the queue.\n        3. Graph executor loop submits the graph execution request to the executor pool.\n      [on_graph_execution]\n        4. Graph executor initialize the node execution queue.\n        5. Graph executor adds the starting nodes to the node execution queue.\n        6. Graph executor waits for all nodes to be executed.\n      [on_node_execution]\n        7. Node executor picks the node execution request from the queue.\n        8. Node executor executes the node.\n        9. Node executor enqueues the next executed nodes to the node execution queue.\n    '
@classmethod
def on_node_executor_start(cls):
    configure_logging()
    set_service_name('NodeExecutor')
    redis.connect()
    cls.pid = os.getpid()
    cls.db_client = get_db_client()
    cls.creds_manager = IntegrationCredentialsManager()
    cls.shutdown_lock = threading.Lock()
    atexit.register(cls.on_node_executor_stop)
    signal.signal(signal.SIGTERM, lambda _, __: cls.on_node_executor_sigterm())
configure_logging()
set_service_name('NodeExecutor')
redis.connect()
cls.pid = os.getpid()
cls.db_client = get_db_client()
cls.creds_manager = IntegrationCredentialsManager()
cls.shutdown_lock = threading.Lock()
atexit.register(cls.on_node_executor_stop)
signal.signal(signal.SIGTERM, lambda _, __: cls.on_node_executor_sigterm())
@classmethod
def on_node_executor_stop(cls):
    if not cls.shutdown_lock.acquire(blocking=False):
        return
    logger.info(f'[on_node_executor_stop {cls.pid}] ⏳ Releasing locks...')
    cls.creds_manager.release_all_locks()
    logger.info(f'[on_node_executor_stop {cls.pid}] ⏳ Disconnecting Redis...')
    redis.disconnect()
    logger.info(f'[on_node_executor_stop {cls.pid}] ⏳ Disconnecting DB manager...')
    close_service_client(cls.db_client)
    logger.info(f'[on_node_executor_stop {cls.pid}] ✅ Finished cleanup')
not cls.shutdown_lock.acquire(blocking=False)
return
return
@classmethod
@time_measured
def _on_node_execution(cls, q: ExecutionQueue[NodeExecutionEntry], node_exec: NodeExecutionEntry, log_metadata: LogMetadata, stats: dict[str, Any] | None=None):
    try:
        log_metadata.info(f'Start node execution {node_exec.node_exec_id}')
        for execution in execute_node(cls.db_client, cls.creds_manager, node_exec, stats):
            q.add(execution)
        log_metadata.info(f'Finished node execution {node_exec.node_exec_id}')
    except Exception as e:
        log_metadata.exception(f'Failed node execution {node_exec.node_exec_id}: {e}')
try:
    log_metadata.info(f'Start node execution {node_exec.node_exec_id}')
    for execution in execute_node(cls.db_client, cls.creds_manager, node_exec, stats):
        q.add(execution)
    log_metadata.info(f'Finished node execution {node_exec.node_exec_id}')
except Exception as e:
    log_metadata.exception(f'Failed node execution {node_exec.node_exec_id}: {e}')
log_metadata.info(f'Start node execution {node_exec.node_exec_id}')
execution
execute_node(cls.db_client, cls.creds_manager, node_exec, stats)
q.add(execution)
log_metadata.info(f'Finished node execution {node_exec.node_exec_id}')
log_metadata.exception(f'Failed node execution {node_exec.node_exec_id}: {e}')
@classmethod
def on_graph_executor_start(cls):
    configure_logging()
    set_service_name('GraphExecutor')
    cls.db_client = get_db_client()
    cls.pool_size = settings.config.num_node_workers
    cls.pid = os.getpid()
    cls._init_node_executor_pool()
    logger.info(f'Graph executor {cls.pid} started with {cls.pool_size} node workers')
    atexit.register(cls.on_graph_executor_stop)
configure_logging()
set_service_name('GraphExecutor')
cls.db_client = get_db_client()
cls.pool_size = settings.config.num_node_workers
cls.pid = os.getpid()
cls._init_node_executor_pool()
logger.info(f'Graph executor {cls.pid} started with {cls.pool_size} node workers')
atexit.register(cls.on_graph_executor_stop)
@classmethod
def on_graph_executor_stop(cls):
    prefix = f'[on_graph_executor_stop {cls.pid}]'
    logger.info(f'{prefix} ⏳ Terminating node executor pool...')
    cls.executor.terminate()
    logger.info(f'{prefix} ⏳ Disconnecting DB manager...')
    close_service_client(cls.db_client)
    logger.info(f'{prefix} ✅ Finished cleanup')
prefix = f'[on_graph_executor_stop {cls.pid}]'
logger.info(f'{prefix} ⏳ Terminating node executor pool...')
cls.executor.terminate()
logger.info(f'{prefix} ⏳ Disconnecting DB manager...')
close_service_client(cls.db_client)
logger.info(f'{prefix} ✅ Finished cleanup')
@classmethod
def _init_node_executor_pool(cls):
    cls.executor = Pool(processes=cls.pool_size, initializer=cls.on_node_executor_start)
cls.executor = Pool(processes=cls.pool_size, initializer=cls.on_node_executor_start)
@classmethod
@error_logged
def on_graph_execution(cls, graph_exec: GraphExecutionEntry, cancel: threading.Event):
    log_metadata = LogMetadata(user_id=graph_exec.user_id, graph_eid=graph_exec.graph_exec_id, graph_id=graph_exec.graph_id, node_id='*', node_eid='*', block_name='-')
    (timing_info, (exec_stats, error)) = cls._on_graph_execution(graph_exec, cancel, log_metadata)
    exec_stats['walltime'] = timing_info.wall_time
    exec_stats['cputime'] = timing_info.cpu_time
    exec_stats['error'] = str(error) if error else None
    result = cls.db_client.update_graph_execution_stats(graph_exec_id=graph_exec.graph_exec_id, stats=exec_stats)
    cls.db_client.send_execution_update(result)
log_metadata = LogMetadata(user_id=graph_exec.user_id, graph_eid=graph_exec.graph_exec_id, graph_id=graph_exec.graph_id, node_id='*', node_eid='*', block_name='-')
(timing_info, (exec_stats, error)) = cls._on_graph_execution(graph_exec, cancel, log_metadata)
exec_stats['walltime'] = timing_info.wall_time
exec_stats['cputime'] = timing_info.cpu_time
exec_stats['error'] = str(error) if error else None
result = cls.db_client.update_graph_execution_stats(graph_exec_id=graph_exec.graph_exec_id, stats=exec_stats)
cls.db_client.send_execution_update(result)
@classmethod
@time_measured
def _on_graph_execution(cls, graph_exec: GraphExecutionEntry, cancel: threading.Event, log_metadata: LogMetadata) -> tuple[dict[str, Any], Exception | None]:
    """
        Returns:
            The execution statistics of the graph execution.
            The error that occurred during the execution.
        """
    log_metadata.info(f'Start graph execution {graph_exec.graph_exec_id}')
    exec_stats = {'nodes_walltime': 0, 'nodes_cputime': 0, 'node_count': 0}
    error = None
    finished = False

    def cancel_handler():
        while not cancel.is_set():
            cancel.wait(1)
        if finished:
            return
        cls.executor.terminate()
        log_metadata.info(f'Terminated graph execution {graph_exec.graph_exec_id}')
        cls._init_node_executor_pool()
    cancel_thread = threading.Thread(target=cancel_handler)
    cancel_thread.start()
    try:
        queue = ExecutionQueue[NodeExecutionEntry]()
        for node_exec in graph_exec.start_node_execs:
            queue.add(node_exec)
        running_executions: dict[str, AsyncResult] = {}

        def make_exec_callback(exec_data: NodeExecutionEntry):
            node_id = exec_data.node_id

            def callback(result: object):
                running_executions.pop(node_id)
                nonlocal exec_stats
                if isinstance(result, dict):
                    exec_stats['node_count'] += 1
                    exec_stats['nodes_cputime'] += result.get('cputime', 0)
                    exec_stats['nodes_walltime'] += result.get('walltime', 0)
            return callback
        while not queue.empty():
            if cancel.is_set():
                error = RuntimeError('Execution is cancelled')
                return (exec_stats, error)
            exec_data = queue.get()
            execution = running_executions.get(exec_data.node_id)
            if execution and (not execution.ready()):
                execution.wait()
            log_metadata.debug(f'Dispatching node execution {exec_data.node_exec_id} for node {exec_data.node_id}')
            running_executions[exec_data.node_id] = cls.executor.apply_async(cls.on_node_execution, (queue, exec_data), callback=make_exec_callback(exec_data))
            while queue.empty() and running_executions:
                log_metadata.debug(f'Queue empty; running nodes: {list(running_executions.keys())}')
                for (node_id, execution) in list(running_executions.items()):
                    if cancel.is_set():
                        error = RuntimeError('Execution is cancelled')
                        return (exec_stats, error)
                    if not queue.empty():
                        break
                    log_metadata.debug(f'Waiting on execution of node {node_id}')
                    execution.wait(3)
        log_metadata.info(f'Finished graph execution {graph_exec.graph_exec_id}')
    except Exception as e:
        log_metadata.exception(f'Failed graph execution {graph_exec.graph_exec_id}: {e}')
        error = e
    finally:
        if not cancel.is_set():
            finished = True
            cancel.set()
        cancel_thread.join()
        return (exec_stats, error)
'\n        Returns:\n            The execution statistics of the graph execution.\n            The error that occurred during the execution.\n        '
log_metadata.info(f'Start graph execution {graph_exec.graph_exec_id}')
exec_stats = {'nodes_walltime': 0, 'nodes_cputime': 0, 'node_count': 0}
error = None
finished = False
def cancel_handler():
    while not cancel.is_set():
        cancel.wait(1)
    if finished:
        return
    cls.executor.terminate()
    log_metadata.info(f'Terminated graph execution {graph_exec.graph_exec_id}')
    cls._init_node_executor_pool()
not cancel.is_set()
cancel.wait(1)
finished
return
node_exec
graph_exec.start_node_execs
queue.add(node_exec)
running_executions: dict[str, AsyncResult] = {}
def make_exec_callback(exec_data: NodeExecutionEntry):
    node_id = exec_data.node_id

    def callback(result: object):
        running_executions.pop(node_id)
        nonlocal exec_stats
        if isinstance(result, dict):
            exec_stats['node_count'] += 1
            exec_stats['nodes_cputime'] += result.get('cputime', 0)
            exec_stats['nodes_walltime'] += result.get('walltime', 0)
    return callback
node_id = exec_data.node_id
def callback(result: object):
    running_executions.pop(node_id)
    nonlocal exec_stats
    if isinstance(result, dict):
        exec_stats['node_count'] += 1
        exec_stats['nodes_cputime'] += result.get('cputime', 0)
        exec_stats['nodes_walltime'] += result.get('walltime', 0)
running_executions.pop(node_id)
nonlocal exec_stats
isinstance(result, dict)
exec_stats['node_count'] += 1
exec_stats['nodes_cputime'] += result.get('cputime', 0)
exec_stats['nodes_walltime'] += result.get('walltime', 0)
return callback
not queue.empty()
cancel.is_set()
log_metadata.info(f'Finished graph execution {graph_exec.graph_exec_id}')
log_metadata.exception(f'Failed graph execution {graph_exec.graph_exec_id}: {e}')
error = e
not cancel.is_set()
error = RuntimeError('Execution is cancelled')
return (exec_stats, error)
execution.wait()
log_metadata.debug(f'Dispatching node execution {exec_data.node_exec_id} for node {exec_data.node_id}')
running_executions[exec_data.node_id] = cls.executor.apply_async(cls.on_node_execution, (queue, exec_data), callback=make_exec_callback(exec_data))
queue.empty() and running_executions
log_metadata.debug(f'Queue empty; running nodes: {list(running_executions.keys())}')
(node_id, execution)
list(running_executions.items())
cancel.is_set()
error = RuntimeError('Execution is cancelled')
return (exec_stats, error)
break
log_metadata.debug(f'Waiting on execution of node {node_id}')
execution.wait(3)
finished = True
cancel.set()
cancel_thread.join()
return (exec_stats, error)
class ExecutionManager(AppService):

    def __init__(self):
        super().__init__()
        self.use_redis = True
        self.use_supabase = True
        self.pool_size = settings.config.num_graph_workers
        self.queue = ExecutionQueue[GraphExecutionEntry]()
        self.active_graph_runs: dict[str, tuple[Future, threading.Event]] = {}

    @classmethod
    def get_port(cls) -> int:
        return settings.config.execution_manager_port

    def run_service(self):
        from backend.integrations.credentials_store import IntegrationCredentialsStore
        self.credentials_store = IntegrationCredentialsStore()
        self.executor = ProcessPoolExecutor(max_workers=self.pool_size, initializer=Executor.on_graph_executor_start)
        sync_manager = multiprocessing.Manager()
        logger.info(f'[{self.service_name}] Started with max-{self.pool_size} graph workers')
        while True:
            graph_exec_data = self.queue.get()
            graph_exec_id = graph_exec_data.graph_exec_id
            logger.debug(f'[ExecutionManager] Dispatching graph execution {graph_exec_id}')
            cancel_event = sync_manager.Event()
            future = self.executor.submit(Executor.on_graph_execution, graph_exec_data, cancel_event)
            self.active_graph_runs[graph_exec_id] = (future, cancel_event)
            future.add_done_callback(lambda _: self.active_graph_runs.pop(graph_exec_id, None))

    def cleanup(self):
        logger.info(f'[{__class__.__name__}] ⏳ Shutting down graph executor pool...')
        self.executor.shutdown(cancel_futures=True)
        super().cleanup()

    @property
    def db_client(self) -> 'DatabaseManager':
        return get_db_client()

    @expose
    def add_execution(self, graph_id: str, data: BlockInput, user_id: str, graph_version: int | None=None) -> GraphExecutionEntry:
        graph: GraphModel | None = self.db_client.get_graph(graph_id=graph_id, user_id=user_id, version=graph_version)
        if not graph:
            raise ValueError(f'Graph #{graph_id} not found.')
        graph.validate_graph(for_run=True)
        self._validate_node_input_credentials(graph, user_id)
        nodes_input = []
        for node in graph.starting_nodes:
            input_data = {}
            block = get_block(node.block_id)
            if not block or block.block_type == BlockType.NOTE:
                continue
            if block.block_type == BlockType.INPUT:
                name = node.input_default.get('name')
                if name and name in data:
                    input_data = {'value': data[name]}
            webhook_payload_key = f'webhook_{node.webhook_id}_payload'
            if block.block_type in (BlockType.WEBHOOK, BlockType.WEBHOOK_MANUAL) and node.webhook_id:
                if webhook_payload_key not in data:
                    raise ValueError(f'Node {block.name} #{node.id} webhook payload is missing')
                input_data = {'payload': data[webhook_payload_key]}
            (input_data, error) = validate_exec(node, input_data)
            if input_data is None:
                raise ValueError(error)
            else:
                nodes_input.append((node.id, input_data))
        (graph_exec_id, node_execs) = self.db_client.create_graph_execution(graph_id=graph_id, graph_version=graph.version, nodes_input=nodes_input, user_id=user_id)
        starting_node_execs = []
        for node_exec in node_execs:
            starting_node_execs.append(NodeExecutionEntry(user_id=user_id, graph_exec_id=node_exec.graph_exec_id, graph_id=node_exec.graph_id, node_exec_id=node_exec.node_exec_id, node_id=node_exec.node_id, data=node_exec.input_data))
            exec_update = self.db_client.update_execution_status(node_exec.node_exec_id, ExecutionStatus.QUEUED, node_exec.input_data)
            self.db_client.send_execution_update(exec_update)
        graph_exec = GraphExecutionEntry(user_id=user_id, graph_id=graph_id, graph_exec_id=graph_exec_id, start_node_execs=starting_node_execs)
        self.queue.add(graph_exec)
        return graph_exec

    @expose
    def cancel_execution(self, graph_exec_id: str) -> None:
        """
        Mechanism:
        1. Set the cancel event
        2. Graph executor's cancel handler thread detects the event, terminates workers,
           reinitializes worker pool, and returns.
        3. Update execution statuses in DB and set `error` outputs to `"TERMINATED"`.
        """
        if graph_exec_id not in self.active_graph_runs:
            raise Exception(f'Graph execution #{graph_exec_id} not active/running: possibly already completed/cancelled.')
        (future, cancel_event) = self.active_graph_runs[graph_exec_id]
        if cancel_event.is_set():
            return
        cancel_event.set()
        future.result()
        node_execs = self.db_client.get_execution_results(graph_exec_id)
        for node_exec in node_execs:
            if node_exec.status not in (ExecutionStatus.COMPLETED, ExecutionStatus.FAILED):
                self.db_client.upsert_execution_output(node_exec.node_exec_id, 'error', 'TERMINATED')
                exec_update = self.db_client.update_execution_status(node_exec.node_exec_id, ExecutionStatus.FAILED)
                self.db_client.send_execution_update(exec_update)

    def _validate_node_input_credentials(self, graph: GraphModel, user_id: str):
        """Checks all credentials for all nodes of the graph"""
        for node in graph.nodes:
            block = get_block(node.block_id)
            if not block:
                raise ValueError(f'Unknown block {node.block_id} for node #{node.id}')
            model_fields = cast(type[BaseModel], block.input_schema).model_fields
            if CREDENTIALS_FIELD_NAME not in model_fields:
                continue
            field = model_fields[CREDENTIALS_FIELD_NAME]
            credentials_meta_type = cast(CredentialsMetaInput, field.annotation)
            credentials_meta = credentials_meta_type.model_validate(node.input_default[CREDENTIALS_FIELD_NAME])
            credentials = self.credentials_store.get_creds_by_id(user_id, credentials_meta.id)
            if not credentials:
                raise ValueError(f'Unknown credentials #{credentials_meta.id} for node #{node.id}')
            if credentials.provider != credentials_meta.provider or credentials.type != credentials_meta.type:
                logger.warning(f'Invalid credentials #{credentials.id} for node #{node.id}: type/provider mismatch: {credentials_meta.type}<>{credentials.type};{credentials_meta.provider}<>{credentials.provider}')
                raise ValueError(f'Invalid credentials #{credentials.id} for node #{node.id}: type/provider mismatch')
def __init__(self):
    super().__init__()
    self.use_redis = True
    self.use_supabase = True
    self.pool_size = settings.config.num_graph_workers
    self.queue = ExecutionQueue[GraphExecutionEntry]()
    self.active_graph_runs: dict[str, tuple[Future, threading.Event]] = {}
super().__init__()
self.use_redis = True
self.use_supabase = True
self.pool_size = settings.config.num_graph_workers
self.queue = ExecutionQueue[GraphExecutionEntry]()
self.active_graph_runs: dict[str, tuple[Future, threading.Event]] = {}
@classmethod
def get_port(cls) -> int:
    return settings.config.execution_manager_port
return settings.config.execution_manager_port
def run_service(self):
    from backend.integrations.credentials_store import IntegrationCredentialsStore
    self.credentials_store = IntegrationCredentialsStore()
    self.executor = ProcessPoolExecutor(max_workers=self.pool_size, initializer=Executor.on_graph_executor_start)
    sync_manager = multiprocessing.Manager()
    logger.info(f'[{self.service_name}] Started with max-{self.pool_size} graph workers')
    while True:
        graph_exec_data = self.queue.get()
        graph_exec_id = graph_exec_data.graph_exec_id
        logger.debug(f'[ExecutionManager] Dispatching graph execution {graph_exec_id}')
        cancel_event = sync_manager.Event()
        future = self.executor.submit(Executor.on_graph_execution, graph_exec_data, cancel_event)
        self.active_graph_runs[graph_exec_id] = (future, cancel_event)
        future.add_done_callback(lambda _: self.active_graph_runs.pop(graph_exec_id, None))
from backend.integrations.credentials_store import IntegrationCredentialsStore
self.credentials_store = IntegrationCredentialsStore()
self.executor = ProcessPoolExecutor(max_workers=self.pool_size, initializer=Executor.on_graph_executor_start)
sync_manager = multiprocessing.Manager()
logger.info(f'[{self.service_name}] Started with max-{self.pool_size} graph workers')
True
graph_exec_data = self.queue.get()
graph_exec_id = graph_exec_data.graph_exec_id
logger.debug(f'[ExecutionManager] Dispatching graph execution {graph_exec_id}')
cancel_event = sync_manager.Event()
future = self.executor.submit(Executor.on_graph_execution, graph_exec_data, cancel_event)
self.active_graph_runs[graph_exec_id] = (future, cancel_event)
future.add_done_callback(lambda _: self.active_graph_runs.pop(graph_exec_id, None))
def cleanup(self):
    logger.info(f'[{__class__.__name__}] ⏳ Shutting down graph executor pool...')
    self.executor.shutdown(cancel_futures=True)
    super().cleanup()
logger.info(f'[{__class__.__name__}] ⏳ Shutting down graph executor pool...')
self.executor.shutdown()
super().cleanup()
@property
def db_client(self) -> 'DatabaseManager':
    return get_db_client()
return get_db_client()
@expose
def add_execution(self, graph_id: str, data: BlockInput, user_id: str, graph_version: int | None=None) -> GraphExecutionEntry:
    graph: GraphModel | None = self.db_client.get_graph(graph_id=graph_id, user_id=user_id, version=graph_version)
    if not graph:
        raise ValueError(f'Graph #{graph_id} not found.')
    graph.validate_graph(for_run=True)
    self._validate_node_input_credentials(graph, user_id)
    nodes_input = []
    for node in graph.starting_nodes:
        input_data = {}
        block = get_block(node.block_id)
        if not block or block.block_type == BlockType.NOTE:
            continue
        if block.block_type == BlockType.INPUT:
            name = node.input_default.get('name')
            if name and name in data:
                input_data = {'value': data[name]}
        webhook_payload_key = f'webhook_{node.webhook_id}_payload'
        if block.block_type in (BlockType.WEBHOOK, BlockType.WEBHOOK_MANUAL) and node.webhook_id:
            if webhook_payload_key not in data:
                raise ValueError(f'Node {block.name} #{node.id} webhook payload is missing')
            input_data = {'payload': data[webhook_payload_key]}
        (input_data, error) = validate_exec(node, input_data)
        if input_data is None:
            raise ValueError(error)
        else:
            nodes_input.append((node.id, input_data))
    (graph_exec_id, node_execs) = self.db_client.create_graph_execution(graph_id=graph_id, graph_version=graph.version, nodes_input=nodes_input, user_id=user_id)
    starting_node_execs = []
    for node_exec in node_execs:
        starting_node_execs.append(NodeExecutionEntry(user_id=user_id, graph_exec_id=node_exec.graph_exec_id, graph_id=node_exec.graph_id, node_exec_id=node_exec.node_exec_id, node_id=node_exec.node_id, data=node_exec.input_data))
        exec_update = self.db_client.update_execution_status(node_exec.node_exec_id, ExecutionStatus.QUEUED, node_exec.input_data)
        self.db_client.send_execution_update(exec_update)
    graph_exec = GraphExecutionEntry(user_id=user_id, graph_id=graph_id, graph_exec_id=graph_exec_id, start_node_execs=starting_node_execs)
    self.queue.add(graph_exec)
    return graph_exec
graph: GraphModel | None = self.db_client.get_graph(graph_id=graph_id, user_id=user_id, version=graph_version)
not graph
raise ValueError(f'Graph #{graph_id} not found.')
graph.validate_graph()
self._validate_node_input_credentials(graph, user_id)
nodes_input = []
node
graph.starting_nodes
input_data = {}
block = get_block(node.block_id)
not block or block.block_type == BlockType.NOTE
(graph_exec_id, node_execs) = self.db_client.create_graph_execution(graph_id=graph_id, graph_version=graph.version, nodes_input=nodes_input, user_id=user_id)
starting_node_execs = []
continue
block.block_type Eq BlockType.INPUT
name = node.input_default.get('name')
name and name in data
webhook_payload_key = f'webhook_{node.webhook_id}_payload'
block.block_type in (BlockType.WEBHOOK, BlockType.WEBHOOK_MANUAL) and node.webhook_id
input_data = {'value': data[name]}
webhook_payload_key NotIn data
(input_data, error) = validate_exec(node, input_data)
input_data Is None
raise ValueError(f'Node {block.name} #{node.id} webhook payload is missing')
input_data = {'payload': data[webhook_payload_key]}
raise ValueError(error)
nodes_input.append((node.id, input_data))
node_exec
node_execs
starting_node_execs.append(NodeExecutionEntry())
exec_update = self.db_client.update_execution_status(node_exec.node_exec_id, ExecutionStatus.QUEUED, node_exec.input_data)
self.db_client.send_execution_update(exec_update)
graph_exec = GraphExecutionEntry(user_id=user_id, graph_id=graph_id, graph_exec_id=graph_exec_id, start_node_execs=starting_node_execs)
self.queue.add(graph_exec)
return graph_exec
@expose
def cancel_execution(self, graph_exec_id: str) -> None:
    """
        Mechanism:
        1. Set the cancel event
        2. Graph executor's cancel handler thread detects the event, terminates workers,
           reinitializes worker pool, and returns.
        3. Update execution statuses in DB and set `error` outputs to `"TERMINATED"`.
        """
    if graph_exec_id not in self.active_graph_runs:
        raise Exception(f'Graph execution #{graph_exec_id} not active/running: possibly already completed/cancelled.')
    (future, cancel_event) = self.active_graph_runs[graph_exec_id]
    if cancel_event.is_set():
        return
    cancel_event.set()
    future.result()
    node_execs = self.db_client.get_execution_results(graph_exec_id)
    for node_exec in node_execs:
        if node_exec.status not in (ExecutionStatus.COMPLETED, ExecutionStatus.FAILED):
            self.db_client.upsert_execution_output(node_exec.node_exec_id, 'error', 'TERMINATED')
            exec_update = self.db_client.update_execution_status(node_exec.node_exec_id, ExecutionStatus.FAILED)
            self.db_client.send_execution_update(exec_update)
'\n        Mechanism:\n        1. Set the cancel event\n        2. Graph executor\'s cancel handler thread detects the event, terminates workers,\n           reinitializes worker pool, and returns.\n        3. Update execution statuses in DB and set `error` outputs to `"TERMINATED"`.\n        '
graph_exec_id NotIn self.active_graph_runs
raise Exception(f'Graph execution #{graph_exec_id} not active/running: possibly already completed/cancelled.')
(future, cancel_event) = self.active_graph_runs[graph_exec_id]
cancel_event.is_set()
return
node_exec
node_execs
node_exec.status NotIn (ExecutionStatus.COMPLETED, ExecutionStatus.FAILED)
def _validate_node_input_credentials(self, graph: GraphModel, user_id: str):
    """Checks all credentials for all nodes of the graph"""
    for node in graph.nodes:
        block = get_block(node.block_id)
        if not block:
            raise ValueError(f'Unknown block {node.block_id} for node #{node.id}')
        model_fields = cast(type[BaseModel], block.input_schema).model_fields
        if CREDENTIALS_FIELD_NAME not in model_fields:
            continue
        field = model_fields[CREDENTIALS_FIELD_NAME]
        credentials_meta_type = cast(CredentialsMetaInput, field.annotation)
        credentials_meta = credentials_meta_type.model_validate(node.input_default[CREDENTIALS_FIELD_NAME])
        credentials = self.credentials_store.get_creds_by_id(user_id, credentials_meta.id)
        if not credentials:
            raise ValueError(f'Unknown credentials #{credentials_meta.id} for node #{node.id}')
        if credentials.provider != credentials_meta.provider or credentials.type != credentials_meta.type:
            logger.warning(f'Invalid credentials #{credentials.id} for node #{node.id}: type/provider mismatch: {credentials_meta.type}<>{credentials.type};{credentials_meta.provider}<>{credentials.provider}')
            raise ValueError(f'Invalid credentials #{credentials.id} for node #{node.id}: type/provider mismatch')
'Checks all credentials for all nodes of the graph'
self.db_client.upsert_execution_output(node_exec.node_exec_id, 'error', 'TERMINATED')
exec_update = self.db_client.update_execution_status(node_exec.node_exec_id, ExecutionStatus.FAILED)
self.db_client.send_execution_update(exec_update)
node
graph.nodes
block = get_block(node.block_id)
not block
@thread_cached
def get_db_client() -> 'DatabaseManager':
    from backend.executor import DatabaseManager
    return get_service_client(DatabaseManager)
from backend.executor import DatabaseManager
return get_service_client(DatabaseManager)
raise ValueError(f'Unknown block {node.block_id} for node #{node.id}')
model_fields = cast(type[BaseModel], block.input_schema).model_fields
CREDENTIALS_FIELD_NAME NotIn model_fields
continue
field = model_fields[CREDENTIALS_FIELD_NAME]
credentials_meta_type = cast(CredentialsMetaInput, field.annotation)
credentials_meta = credentials_meta_type.model_validate(node.input_default[CREDENTIALS_FIELD_NAME])
credentials = self.credentials_store.get_creds_by_id(user_id, credentials_meta.id)
not credentials
raise ValueError(f'Unknown credentials #{credentials_meta.id} for node #{node.id}')
credentials.provider != credentials_meta.provider or credentials.type != credentials_meta.type
logger.warning(f'Invalid credentials #{credentials.id} for node #{node.id}: type/provider mismatch: {credentials_meta.type}<>{credentials.type};{credentials_meta.provider}<>{credentials.provider}')
raise ValueError(f'Invalid credentials #{credentials.id} for node #{node.id}: type/provider mismatch')
@contextmanager
def synchronized(key: str, timeout: int=60):
    lock: RedisLock = redis.get_redis().lock(f'lock:{key}', timeout=timeout)
    try:
        lock.acquire()
        yield
    finally:
        if lock.locked():
            lock.release()
lock: RedisLock = redis.get_redis().lock(f'lock:{key}', timeout=timeout)
try:
    lock.acquire()
    yield
finally:
    if lock.locked():
        lock.release()
lock.acquire()
(yield)
lock.locked()
lock.release()
def llprint(message: str):
    """
    Low-level print/log helper function for use in signal handlers.
    Regular log/print statements are not allowed in signal handlers.
    """
    if logger.getEffectiveLevel() == logging.DEBUG:
        os.write(sys.stdout.fileno(), (message + '\n').encode())
'\n    Low-level print/log helper function for use in signal handlers.\n    Regular log/print statements are not allowed in signal handlers.\n    '
logger.getEffectiveLevel() Eq logging.DEBUG
os.write(sys.stdout.fileno(), (message + '\n').encode())