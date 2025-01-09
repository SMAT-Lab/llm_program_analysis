import logging
from contextlib import contextmanager
from datetime import datetime
from typing import TYPE_CHECKING
from autogpt_libs.utils.synchronize import RedisKeyedMutex
from redis.lock import Lock as RedisLock
from backend.data import redis
from backend.data.model import Credentials
from backend.integrations.credentials_store import IntegrationCredentialsStore
from backend.integrations.oauth import HANDLERS_BY_NAME
from backend.util.exceptions import MissingConfigError
from backend.util.settings import Settings
TYPE_CHECKING
def exists(self, user_id: str, credentials_id: str) -> bool:
    return self.store.get_creds_by_id(user_id, credentials_id) is not None
return self.store.get_creds_by_id(user_id, credentials_id) is not None
def get(self, user_id: str, credentials_id: str, lock: bool=True) -> Credentials | None:
    credentials = self.store.get_creds_by_id(user_id, credentials_id)
    if not credentials:
        return None
    if credentials.type == 'oauth2' and credentials.access_token_expires_at:
        logger.debug(f'Credentials #{credentials.id} expire at {datetime.fromtimestamp(credentials.access_token_expires_at)}; current time is {datetime.now()}')
        with self._locked(user_id, credentials_id, 'refresh'):
            oauth_handler = _get_provider_oauth_handler(credentials.provider)
            if oauth_handler.needs_refresh(credentials):
                logger.debug(f"Refreshing '{credentials.provider}' credentials #{credentials.id}")
                _lock = None
                if lock:
                    _lock = self._acquire_lock(user_id, credentials_id)
                fresh_credentials = oauth_handler.refresh_tokens(credentials)
                self.store.update_creds(user_id, fresh_credentials)
                if _lock and _lock.locked():
                    _lock.release()
                credentials = fresh_credentials
    else:
        logger.debug(f'Credentials #{credentials.id} never expire')
    return credentials
credentials = self.store.get_creds_by_id(user_id, credentials_id)
not credentials
def acquire(self, user_id: str, credentials_id: str) -> tuple[Credentials, RedisLock]:
    """
        ⚠️ WARNING: this locks credentials system-wide and blocks both acquiring
        and updating them elsewhere until the lock is released.
        See the class docstring for more info.
        """
    with self._locked(user_id, credentials_id, '!time_sensitive'):
        lock = self._acquire_lock(user_id, credentials_id)
    credentials = self.get(user_id, credentials_id, lock=False)
    if not credentials:
        raise ValueError(f'Credentials #{credentials_id} for user #{user_id} not found')
    return (credentials, lock)
'\n        ⚠️ WARNING: this locks credentials system-wide and blocks both acquiring\n        and updating them elsewhere until the lock is released.\n        See the class docstring for more info.\n        '
with self._locked(user_id, credentials_id, '!time_sensitive'):
    lock = self._acquire_lock(user_id, credentials_id)
lock = self._acquire_lock(user_id, credentials_id)
credentials = self.get(user_id, credentials_id, lock=False)
not credentials
def update(self, user_id: str, updated: Credentials) -> None:
    with self._locked(user_id, updated.id):
        self.store.update_creds(user_id, updated)
with self._locked(user_id, updated.id):
    self.store.update_creds(user_id, updated)
self.store.update_creds(user_id, updated)
def delete(self, user_id: str, credentials_id: str) -> None:
    with self._locked(user_id, credentials_id):
        self.store.delete_creds_by_id(user_id, credentials_id)
with self._locked(user_id, credentials_id):
    self.store.delete_creds_by_id(user_id, credentials_id)
self.store.delete_creds_by_id(user_id, credentials_id)
def _acquire_lock(self, user_id: str, credentials_id: str, *args: str) -> RedisLock:
    key = (f'user:{user_id}', f'credentials:{credentials_id}', *args)
    return self._locks.acquire(key)
key = (f'user:{user_id}', f'credentials:{credentials_id}', *args)
return self._locks.acquire(key)
@contextmanager
def _locked(self, user_id: str, credentials_id: str, *args: str):
    lock = self._acquire_lock(user_id, credentials_id, *args)
    try:
        yield
    finally:
        if lock.locked():
            lock.release()
lock = self._acquire_lock(user_id, credentials_id, *args)
try:
    yield
finally:
    if lock.locked():
        lock.release()
(yield)
lock.locked()
from backend.integrations.oauth import BaseOAuthHandler
return None
raise ValueError(f'Credentials #{credentials_id} for user #{user_id} not found')
lock.release()
logger = logging.getLogger(__name__)
settings = Settings()
class IntegrationCredentialsManager:
    """
    Handles the lifecycle of integration credentials.
    - Automatically refreshes requested credentials if needed.
    - Uses locking mechanisms to ensure system-wide consistency and
      prevent invalidation of in-use tokens.

    ### ⚠️ Gotcha
    With `acquire(..)`, credentials can only be in use in one place at a time (e.g. one
    block execution).

    ### Locking mechanism
    - Because *getting* credentials can result in a refresh (= *invalidation* +
      *replacement*) of the stored credentials, *getting* is an operation that
      potentially requires read/write access.
    - Checking whether a token has to be refreshed is subject to an additional `refresh`
      scoped lock to prevent unnecessary sequential refreshes when multiple executions
      try to access the same credentials simultaneously.
    - We MUST lock credentials while in use to prevent them from being invalidated while
      they are in use, e.g. because they are being refreshed by a different part
      of the system.
    - The `!time_sensitive` lock in `acquire(..)` is part of a two-tier locking
      mechanism in which *updating* gets priority over *getting* credentials.
      This is to prevent a long queue of waiting *get* requests from blocking essential
      credential refreshes or user-initiated updates.

    It is possible to implement a reader/writer locking system where either multiple
    readers or a single writer can have simultaneous access, but this would add a lot of
    complexity to the mechanism. I don't expect the current ("simple") mechanism to
    cause so much latency that it's worth implementing.
    """

    def __init__(self):
        redis_conn = redis.get_redis()
        self._locks = RedisKeyedMutex(redis_conn)
        self.store = IntegrationCredentialsStore()

    def create(self, user_id: str, credentials: Credentials) -> None:
        return self.store.add_creds(user_id, credentials)

    def exists(self, user_id: str, credentials_id: str) -> bool:
        return self.store.get_creds_by_id(user_id, credentials_id) is not None

    def get(self, user_id: str, credentials_id: str, lock: bool=True) -> Credentials | None:
        credentials = self.store.get_creds_by_id(user_id, credentials_id)
        if not credentials:
            return None
        if credentials.type == 'oauth2' and credentials.access_token_expires_at:
            logger.debug(f'Credentials #{credentials.id} expire at {datetime.fromtimestamp(credentials.access_token_expires_at)}; current time is {datetime.now()}')
            with self._locked(user_id, credentials_id, 'refresh'):
                oauth_handler = _get_provider_oauth_handler(credentials.provider)
                if oauth_handler.needs_refresh(credentials):
                    logger.debug(f"Refreshing '{credentials.provider}' credentials #{credentials.id}")
                    _lock = None
                    if lock:
                        _lock = self._acquire_lock(user_id, credentials_id)
                    fresh_credentials = oauth_handler.refresh_tokens(credentials)
                    self.store.update_creds(user_id, fresh_credentials)
                    if _lock and _lock.locked():
                        _lock.release()
                    credentials = fresh_credentials
        else:
            logger.debug(f'Credentials #{credentials.id} never expire')
        return credentials

    def acquire(self, user_id: str, credentials_id: str) -> tuple[Credentials, RedisLock]:
        """
        ⚠️ WARNING: this locks credentials system-wide and blocks both acquiring
        and updating them elsewhere until the lock is released.
        See the class docstring for more info.
        """
        with self._locked(user_id, credentials_id, '!time_sensitive'):
            lock = self._acquire_lock(user_id, credentials_id)
        credentials = self.get(user_id, credentials_id, lock=False)
        if not credentials:
            raise ValueError(f'Credentials #{credentials_id} for user #{user_id} not found')
        return (credentials, lock)

    def update(self, user_id: str, updated: Credentials) -> None:
        with self._locked(user_id, updated.id):
            self.store.update_creds(user_id, updated)

    def delete(self, user_id: str, credentials_id: str) -> None:
        with self._locked(user_id, credentials_id):
            self.store.delete_creds_by_id(user_id, credentials_id)

    def _acquire_lock(self, user_id: str, credentials_id: str, *args: str) -> RedisLock:
        key = (f'user:{user_id}', f'credentials:{credentials_id}', *args)
        return self._locks.acquire(key)

    @contextmanager
    def _locked(self, user_id: str, credentials_id: str, *args: str):
        lock = self._acquire_lock(user_id, credentials_id, *args)
        try:
            yield
        finally:
            if lock.locked():
                lock.release()

    def release_all_locks(self):
        """Call this on process termination to ensure all locks are released"""
        self._locks.release_all_locks()
        self.store.locks.release_all_locks()
'\n    Handles the lifecycle of integration credentials.\n    - Automatically refreshes requested credentials if needed.\n    - Uses locking mechanisms to ensure system-wide consistency and\n      prevent invalidation of in-use tokens.\n\n    ### ⚠️ Gotcha\n    With `acquire(..)`, credentials can only be in use in one place at a time (e.g. one\n    block execution).\n\n    ### Locking mechanism\n    - Because *getting* credentials can result in a refresh (= *invalidation* +\n      *replacement*) of the stored credentials, *getting* is an operation that\n      potentially requires read/write access.\n    - Checking whether a token has to be refreshed is subject to an additional `refresh`\n      scoped lock to prevent unnecessary sequential refreshes when multiple executions\n      try to access the same credentials simultaneously.\n    - We MUST lock credentials while in use to prevent them from being invalidated while\n      they are in use, e.g. because they are being refreshed by a different part\n      of the system.\n    - The `!time_sensitive` lock in `acquire(..)` is part of a two-tier locking\n      mechanism in which *updating* gets priority over *getting* credentials.\n      This is to prevent a long queue of waiting *get* requests from blocking essential\n      credential refreshes or user-initiated updates.\n\n    It is possible to implement a reader/writer locking system where either multiple\n    readers or a single writer can have simultaneous access, but this would add a lot of\n    complexity to the mechanism. I don\'t expect the current ("simple") mechanism to\n    cause so much latency that it\'s worth implementing.\n    '
def __init__(self):
    redis_conn = redis.get_redis()
    self._locks = RedisKeyedMutex(redis_conn)
    self.store = IntegrationCredentialsStore()
redis_conn = redis.get_redis()
self._locks = RedisKeyedMutex(redis_conn)
self.store = IntegrationCredentialsStore()
def create(self, user_id: str, credentials: Credentials) -> None:
    return self.store.add_creds(user_id, credentials)
return self.store.add_creds(user_id, credentials)
logger.debug(f'Credentials #{credentials.id} expire at {datetime.fromtimestamp(credentials.access_token_expires_at)}; current time is {datetime.now()}')
with self._locked(user_id, credentials_id, 'refresh'):
    oauth_handler = _get_provider_oauth_handler(credentials.provider)
    if oauth_handler.needs_refresh(credentials):
        logger.debug(f"Refreshing '{credentials.provider}' credentials #{credentials.id}")
        _lock = None
        if lock:
            _lock = self._acquire_lock(user_id, credentials_id)
        fresh_credentials = oauth_handler.refresh_tokens(credentials)
        self.store.update_creds(user_id, fresh_credentials)
        if _lock and _lock.locked():
            _lock.release()
        credentials = fresh_credentials
oauth_handler = _get_provider_oauth_handler(credentials.provider)
oauth_handler.needs_refresh(credentials)
logger.debug(f'Credentials #{credentials.id} never expire')
return (credentials, lock)
def release_all_locks(self):
    """Call this on process termination to ensure all locks are released"""
    self._locks.release_all_locks()
    self.store.locks.release_all_locks()
'Call this on process termination to ensure all locks are released'
self._locks.release_all_locks()
self.store.locks.release_all_locks()
def _get_provider_oauth_handler(provider_name: str) -> 'BaseOAuthHandler':
    if provider_name not in HANDLERS_BY_NAME:
        raise KeyError(f"Unknown provider '{provider_name}'")
    client_id = getattr(settings.secrets, f'{provider_name}_client_id')
    client_secret = getattr(settings.secrets, f'{provider_name}_client_secret')
    if not (client_id and client_secret):
        raise MissingConfigError(f"Integration with provider '{provider_name}' is not configured")
    handler_class = HANDLERS_BY_NAME[provider_name]
    frontend_base_url = settings.config.frontend_base_url or settings.config.platform_base_url
    return handler_class(client_id=client_id, client_secret=client_secret, redirect_uri=f'{frontend_base_url}/auth/integrations/oauth_callback')
provider_name NotIn HANDLERS_BY_NAME
logger.debug(f"Refreshing '{credentials.provider}' credentials #{credentials.id}")
_lock = None
lock
raise KeyError(f"Unknown provider '{provider_name}'")
_lock = self._acquire_lock(user_id, credentials_id)
client_id = getattr(settings.secrets, f'{provider_name}_client_id')
client_secret = getattr(settings.secrets, f'{provider_name}_client_secret')
not (client_id and client_secret)
fresh_credentials = oauth_handler.refresh_tokens(credentials)
self.store.update_creds(user_id, fresh_credentials)
_lock and _lock.locked()
raise MissingConfigError(f"Integration with provider '{provider_name}' is not configured")
_lock.release()
handler_class = HANDLERS_BY_NAME[provider_name]
frontend_base_url = settings.config.frontend_base_url or settings.config.platform_base_url
return handler_class(client_id=client_id, client_secret=client_secret, redirect_uri=f'{frontend_base_url}/auth/integrations/oauth_callback')
credentials = fresh_credentials
return credentials