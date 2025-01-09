import asyncio
import builtins
import logging
import os
import threading
import time
import typing
from abc import ABC, abstractmethod
from enum import Enum
from types import NoneType, UnionType
from typing import Annotated, Any, Awaitable, Callable, Coroutine, Dict, FrozenSet, Iterator, List, Set, Tuple, Type, TypeVar, Union, cast, get_args, get_origin
import Pyro5.api
from pydantic import BaseModel
from Pyro5 import api as pyro
from Pyro5 import config as pyro_config
from backend.data import db, redis
from backend.util.process import AppProcess
from backend.util.retry import conn_retry
from backend.util.settings import Config, Secrets
logger = logging.getLogger(__name__)
T = TypeVar('T')
C = TypeVar('C', bound=Callable)
config = Config()
pyro_host = config.pyro_host
pyro_config.MAX_RETRIES = config.pyro_client_comm_retry
pyro_config.COMMTIMEOUT = config.pyro_client_comm_timeout
def expose(func: C) -> C:
    """
    Decorator to mark a method or class to be exposed for remote calls.

    ## ⚠️ Gotcha
    Aside from "simple" types, only Pydantic models are passed unscathed *if annotated*.
    Any other passed or returned class objects are converted to dictionaries by Pyro.
    """

    def wrapper(*args, **kwargs):
        try:
            return func(*args, **kwargs)
        except Exception as e:
            msg = f'Error in {func.__name__}: {e.__str__()}'
            logger.exception(msg)
            raise
    register_pydantic_serializers(func)
    return pyro.expose(wrapper)
'\n    Decorator to mark a method or class to be exposed for remote calls.\n\n    ## ⚠️ Gotcha\n    Aside from "simple" types, only Pydantic models are passed unscathed *if annotated*.\n    Any other passed or returned class objects are converted to dictionaries by Pyro.\n    '
def wrapper(*args, **kwargs):
    try:
        return func(*args, **kwargs)
    except Exception as e:
        msg = f'Error in {func.__name__}: {e.__str__()}'
        logger.exception(msg)
        raise
try:
    return func(*args, **kwargs)
except Exception as e:
    msg = f'Error in {func.__name__}: {e.__str__()}'
    logger.exception(msg)
    raise
return func(*args, **kwargs)
msg = f'Error in {func.__name__}: {e.__str__()}'
logger.exception(msg)
raise
register_pydantic_serializers(func)
return pyro.expose(wrapper)
def register_pydantic_serializers(func: Callable):
    """Register custom serializers and deserializers for annotated Pydantic models"""
    for (name, annotation) in func.__annotations__.items():
        try:
            pydantic_types = _pydantic_models_from_type_annotation(annotation)
        except Exception as e:
            raise TypeError(f'Error while exposing {func.__name__}: {e.__str__()}')
        for model in pydantic_types:
            logger.debug(f"Registering Pyro (de)serializers for {func.__name__} annotation '{name}': {model.__qualname__}")
            pyro.register_class_to_dict(model, _make_custom_serializer(model))
            pyro.register_dict_to_class(model.__qualname__, _make_custom_deserializer(model))
'Register custom serializers and deserializers for annotated Pydantic models'
(name, annotation)
func.__annotations__.items()
try:
    pydantic_types = _pydantic_models_from_type_annotation(annotation)
except Exception as e:
    raise TypeError(f'Error while exposing {func.__name__}: {e.__str__()}')
pydantic_types = _pydantic_models_from_type_annotation(annotation)
raise TypeError(f'Error while exposing {func.__name__}: {e.__str__()}')
def _make_custom_serializer(model: Type[BaseModel]):

    def custom_class_to_dict(obj):
        data = {'__class__': obj.__class__.__qualname__, **obj.model_dump()}
        logger.debug(f'Serializing {obj.__class__.__qualname__} with data: {data}')
        return data
    return custom_class_to_dict
def custom_class_to_dict(obj):
    data = {'__class__': obj.__class__.__qualname__, **obj.model_dump()}
    logger.debug(f'Serializing {obj.__class__.__qualname__} with data: {data}')
    return data
data = {'__class__': obj.__class__.__qualname__, **obj.model_dump()}
logger.debug(f'Serializing {obj.__class__.__qualname__} with data: {data}')
return data
model
pydantic_types
logger.debug(f"Registering Pyro (de)serializers for {func.__name__} annotation '{name}': {model.__qualname__}")
pyro.register_class_to_dict(model, _make_custom_serializer(model))
pyro.register_dict_to_class(model.__qualname__, _make_custom_deserializer(model))
return custom_class_to_dict
def _make_custom_deserializer(model: Type[BaseModel]):

    def custom_dict_to_class(qualname, data: dict):
        logger.debug(f'Deserializing {model.__qualname__} from data: {data}')
        return model(**data)
    return custom_dict_to_class
def custom_dict_to_class(qualname, data: dict):
    logger.debug(f'Deserializing {model.__qualname__} from data: {data}')
    return model(**data)
logger.debug(f'Deserializing {model.__qualname__} from data: {data}')
return model(**data)
return custom_dict_to_class
class AppService(AppProcess, ABC):
    shared_event_loop: asyncio.AbstractEventLoop
    use_db: bool = False
    use_redis: bool = False
    use_supabase: bool = False

    def __init__(self):
        self.uri = None

    @classmethod
    @abstractmethod
    def get_port(cls) -> int:
        pass

    @classmethod
    def get_host(cls) -> str:
        return os.environ.get(f'{cls.service_name.upper()}_HOST', config.pyro_host)

    def run_service(self) -> None:
        while True:
            time.sleep(10)

    def __run_async(self, coro: Coroutine[Any, Any, T]):
        return asyncio.run_coroutine_threadsafe(coro, self.shared_event_loop)

    def run_and_wait(self, coro: Coroutine[Any, Any, T]) -> T:
        future = self.__run_async(coro)
        return future.result()

    def run(self):
        self.shared_event_loop = asyncio.get_event_loop()
        if self.use_db:
            self.shared_event_loop.run_until_complete(db.connect())
        if self.use_redis:
            redis.connect()
        if self.use_supabase:
            from supabase import create_client
            secrets = Secrets()
            self.supabase = create_client(secrets.supabase_url, secrets.supabase_service_role_key)
        async_thread = threading.Thread(target=self.__start_async_loop)
        async_thread.daemon = True
        async_thread.start()
        daemon_thread = threading.Thread(target=self.__start_pyro)
        daemon_thread.daemon = True
        daemon_thread.start()
        self.run_service()

    def cleanup(self):
        if self.use_db:
            logger.info(f'[{self.__class__.__name__}] ⏳ Disconnecting DB...')
            self.run_and_wait(db.disconnect())
        if self.use_redis:
            logger.info(f'[{self.__class__.__name__}] ⏳ Disconnecting Redis...')
            redis.disconnect()

    @conn_retry('Pyro', 'Starting Pyro Service')
    def __start_pyro(self):
        maximum_connection_thread_count = max(Pyro5.config.THREADPOOL_SIZE, config.num_node_workers * config.num_graph_workers)
        Pyro5.config.THREADPOOL_SIZE = maximum_connection_thread_count
        daemon = Pyro5.api.Daemon(host=config.pyro_host, port=self.get_port())
        self.uri = daemon.register(self, objectId=self.service_name)
        logger.info(f'[{self.service_name}] Connected to Pyro; URI = {self.uri}')
        daemon.requestLoop()

    def __start_async_loop(self):
        self.shared_event_loop.run_forever()
shared_event_loop: asyncio.AbstractEventLoop
use_db: bool = False
use_redis: bool = False
use_supabase: bool = False
def __init__(self):
    self.uri = None
self.uri = None
@classmethod
@abstractmethod
def get_port(cls) -> int:
    pass
pass
@classmethod
def get_host(cls) -> str:
    return os.environ.get(f'{cls.service_name.upper()}_HOST', config.pyro_host)
return os.environ.get(f'{cls.service_name.upper()}_HOST', config.pyro_host)
def run_service(self) -> None:
    while True:
        time.sleep(10)
True
time.sleep(10)
def __run_async(self, coro: Coroutine[Any, Any, T]):
    return asyncio.run_coroutine_threadsafe(coro, self.shared_event_loop)
return asyncio.run_coroutine_threadsafe(coro, self.shared_event_loop)
def run_and_wait(self, coro: Coroutine[Any, Any, T]) -> T:
    future = self.__run_async(coro)
    return future.result()
future = self.__run_async(coro)
return future.result()
def run(self):
    self.shared_event_loop = asyncio.get_event_loop()
    if self.use_db:
        self.shared_event_loop.run_until_complete(db.connect())
    if self.use_redis:
        redis.connect()
    if self.use_supabase:
        from supabase import create_client
        secrets = Secrets()
        self.supabase = create_client(secrets.supabase_url, secrets.supabase_service_role_key)
    async_thread = threading.Thread(target=self.__start_async_loop)
    async_thread.daemon = True
    async_thread.start()
    daemon_thread = threading.Thread(target=self.__start_pyro)
    daemon_thread.daemon = True
    daemon_thread.start()
    self.run_service()
self.shared_event_loop = asyncio.get_event_loop()
self.use_db
self.shared_event_loop.run_until_complete(db.connect())
self.use_redis
redis.connect()
self.use_supabase
from supabase import create_client
secrets = Secrets()
self.supabase = create_client(secrets.supabase_url, secrets.supabase_service_role_key)
async_thread = threading.Thread(target=self.__start_async_loop)
async_thread.daemon = True
async_thread.start()
daemon_thread = threading.Thread(target=self.__start_pyro)
daemon_thread.daemon = True
daemon_thread.start()
self.run_service()
def cleanup(self):
    if self.use_db:
        logger.info(f'[{self.__class__.__name__}] ⏳ Disconnecting DB...')
        self.run_and_wait(db.disconnect())
    if self.use_redis:
        logger.info(f'[{self.__class__.__name__}] ⏳ Disconnecting Redis...')
        redis.disconnect()
self.use_db
logger.info(f'[{self.__class__.__name__}] ⏳ Disconnecting DB...')
self.run_and_wait(db.disconnect())
self.use_redis
logger.info(f'[{self.__class__.__name__}] ⏳ Disconnecting Redis...')
redis.disconnect()
@conn_retry('Pyro', 'Starting Pyro Service')
def __start_pyro(self):
    maximum_connection_thread_count = max(Pyro5.config.THREADPOOL_SIZE, config.num_node_workers * config.num_graph_workers)
    Pyro5.config.THREADPOOL_SIZE = maximum_connection_thread_count
    daemon = Pyro5.api.Daemon(host=config.pyro_host, port=self.get_port())
    self.uri = daemon.register(self, objectId=self.service_name)
    logger.info(f'[{self.service_name}] Connected to Pyro; URI = {self.uri}')
    daemon.requestLoop()
maximum_connection_thread_count = max(Pyro5.config.THREADPOOL_SIZE, config.num_node_workers * config.num_graph_workers)
Pyro5.config.THREADPOOL_SIZE = maximum_connection_thread_count
daemon = Pyro5.api.Daemon(host=config.pyro_host, port=self.get_port())
self.uri = daemon.register(self, objectId=self.service_name)
logger.info(f'[{self.service_name}] Connected to Pyro; URI = {self.uri}')
daemon.requestLoop()
def __start_async_loop(self):
    self.shared_event_loop.run_forever()
self.shared_event_loop.run_forever()
AS = TypeVar('AS', bound=AppService)
class PyroClient:
    proxy: Pyro5.api.Proxy
proxy: Pyro5.api.Proxy
def close_service_client(client: AppService) -> None:
    if isinstance(client, PyroClient):
        client.proxy._pyroRelease()
    else:
        raise RuntimeError(f'Client {client.__class__} is not a Pyro client.')
isinstance(client, PyroClient)
client.proxy._pyroRelease()
raise RuntimeError(f'Client {client.__class__} is not a Pyro client.')
def get_service_client(service_type: Type[AS]) -> AS:
    service_name = service_type.service_name

    class DynamicClient(PyroClient):

        @conn_retry('Pyro', f'Connecting to [{service_name}]')
        def __init__(self):
            host = os.environ.get(f'{service_name.upper()}_HOST', pyro_host)
            uri = f'PYRO:{service_type.service_name}@{host}:{service_type.get_port()}'
            logger.debug(f'Connecting to service [{service_name}]. URI = {uri}')
            self.proxy = Pyro5.api.Proxy(uri)
            self.proxy._pyroBind()
            logger.debug(f'Successfully connected to service [{service_name}]')

        def __getattr__(self, name: str) -> Callable[..., Any]:
            res = getattr(self.proxy, name)
            return res
    return cast(AS, DynamicClient())
service_name = service_type.service_name
class DynamicClient(PyroClient):

    @conn_retry('Pyro', f'Connecting to [{service_name}]')
    def __init__(self):
        host = os.environ.get(f'{service_name.upper()}_HOST', pyro_host)
        uri = f'PYRO:{service_type.service_name}@{host}:{service_type.get_port()}'
        logger.debug(f'Connecting to service [{service_name}]. URI = {uri}')
        self.proxy = Pyro5.api.Proxy(uri)
        self.proxy._pyroBind()
        logger.debug(f'Successfully connected to service [{service_name}]')

    def __getattr__(self, name: str) -> Callable[..., Any]:
        res = getattr(self.proxy, name)
        return res
@conn_retry('Pyro', f'Connecting to [{service_name}]')
def __init__(self):
    host = os.environ.get(f'{service_name.upper()}_HOST', pyro_host)
    uri = f'PYRO:{service_type.service_name}@{host}:{service_type.get_port()}'
    logger.debug(f'Connecting to service [{service_name}]. URI = {uri}')
    self.proxy = Pyro5.api.Proxy(uri)
    self.proxy._pyroBind()
    logger.debug(f'Successfully connected to service [{service_name}]')
host = os.environ.get(f'{service_name.upper()}_HOST', pyro_host)
uri = f'PYRO:{service_type.service_name}@{host}:{service_type.get_port()}'
logger.debug(f'Connecting to service [{service_name}]. URI = {uri}')
self.proxy = Pyro5.api.Proxy(uri)
self.proxy._pyroBind()
logger.debug(f'Successfully connected to service [{service_name}]')
def __getattr__(self, name: str) -> Callable[..., Any]:
    res = getattr(self.proxy, name)
    return res
res = getattr(self.proxy, name)
return res
return cast(AS, DynamicClient())
builtin_types = [*vars(builtins).values(), NoneType, Enum]
def _pydantic_models_from_type_annotation(annotation) -> Iterator[type[BaseModel]]:
    if (origin := get_origin(annotation)) and origin is Annotated:
        annotation = get_args(annotation)[0]
    origin = get_origin(annotation)
    args = get_args(annotation)
    if origin in (Union, UnionType, list, List, tuple, Tuple, set, Set, frozenset, FrozenSet):
        for arg in args:
            yield from _pydantic_models_from_type_annotation(arg)
    elif origin in (dict, Dict):
        (key_type, value_type) = args
        yield from _pydantic_models_from_type_annotation(key_type)
        yield from _pydantic_models_from_type_annotation(value_type)
    elif origin in (Awaitable, Coroutine):
        return_type = args[-1]
        yield from _pydantic_models_from_type_annotation(return_type)
    else:
        annotype = annotation if origin is None else origin
        if annotype is not None and (not hasattr(typing, getattr(annotype, '__name__', ''))) and isinstance(annotype, type):
            if issubclass(annotype, BaseModel):
                yield annotype
            elif annotype not in builtin_types and (not issubclass(annotype, Enum)):
                raise TypeError(f'Unsupported type encountered: {annotype}')
(origin := get_origin(annotation)) and origin is Annotated
annotation = get_args(annotation)[0]
origin = get_origin(annotation)
args = get_args(annotation)
origin In (Union, UnionType, list, List, tuple, Tuple, set, Set, frozenset, FrozenSet)
origin In (dict, Dict)
arg
args
(yield from _pydantic_models_from_type_annotation(arg))
(key_type, value_type) = args
(yield from _pydantic_models_from_type_annotation(key_type))
(yield from _pydantic_models_from_type_annotation(value_type))
origin In (Awaitable, Coroutine)
return_type = args[-1]
(yield from _pydantic_models_from_type_annotation(return_type))
annotype = annotation if origin is None else origin
annotype is not None and (not hasattr(typing, getattr(annotype, '__name__', ''))) and isinstance(annotype, type)
issubclass(annotype, BaseModel)
(yield annotype)
annotype not in builtin_types and (not issubclass(annotype, Enum))
raise TypeError(f'Unsupported type encountered: {annotype}')