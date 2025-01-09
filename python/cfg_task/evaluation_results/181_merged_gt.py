import logging
import secrets
from abc import ABC, abstractmethod
from typing import ClassVar, Generic, Optional, TypeVar
from uuid import uuid4
from fastapi import Request
from strenum import StrEnum
from backend.data import integrations
from backend.data.model import Credentials
from backend.integrations.providers import ProviderName
from backend.integrations.webhooks.utils import webhook_ingress_url
from backend.util.exceptions import MissingConfigError
from backend.util.settings import Config
logger = logging.getLogger(__name__)
app_config = Config()
WT = TypeVar('WT', bound=StrEnum)
class BaseWebhooksManager(ABC, Generic[WT]):
    PROVIDER_NAME: ClassVar[ProviderName]
    WebhookType: WT

    async def get_suitable_auto_webhook(self, user_id: str, credentials: Credentials, webhook_type: WT, resource: str, events: list[str]) -> integrations.Webhook:
        if not app_config.platform_base_url:
            raise MissingConfigError('PLATFORM_BASE_URL must be set to use Webhook functionality')
        if (webhook := (await integrations.find_webhook_by_credentials_and_props(credentials.id, webhook_type, resource, events))):
            return webhook
        return await self._create_webhook(user_id, webhook_type, events, resource, credentials)

    async def get_manual_webhook(self, user_id: str, graph_id: str, webhook_type: WT, events: list[str]):
        if (current_webhook := (await integrations.find_webhook_by_graph_and_props(graph_id, self.PROVIDER_NAME, webhook_type, events))):
            return current_webhook
        return await self._create_webhook(user_id, webhook_type, events, register=False)

    async def prune_webhook_if_dangling(self, webhook_id: str, credentials: Optional[Credentials]) -> bool:
        webhook = await integrations.get_webhook(webhook_id)
        if webhook.attached_nodes is None:
            raise ValueError('Error retrieving webhook including attached nodes')
        if webhook.attached_nodes:
            return False
        if credentials:
            await self._deregister_webhook(webhook, credentials)
        await integrations.delete_webhook(webhook.id)
        return True

    @classmethod
    @abstractmethod
    async def validate_payload(cls, webhook: integrations.Webhook, request: Request) -> tuple[dict, str]:
        """
        Validates an incoming webhook request and returns its payload and type.

        Params:
            webhook: Object representing the configured webhook and its properties in our system.
            request: Incoming FastAPI `Request`

        Returns:
            dict: The validated payload
            str: The event type associated with the payload
        """

    async def trigger_ping(self, webhook: integrations.Webhook, credentials: Credentials | None) -> None:
        """
        Triggers a ping to the given webhook.

        Raises:
            NotImplementedError: if the provider doesn't support pinging
        """
        raise NotImplementedError(f"{self.__class__.__name__} doesn't support pinging")

    @abstractmethod
    async def _register_webhook(self, credentials: Credentials, webhook_type: WT, resource: str, events: list[str], ingress_url: str, secret: str) -> tuple[str, dict]:
        """
        Registers a new webhook with the provider.

        Params:
            credentials: The credentials with which to create the webhook
            webhook_type: The provider-specific webhook type to create
            resource: The resource to receive events for
            events: The events to subscribe to
            ingress_url: The ingress URL for webhook payloads
            secret: Secret used to verify webhook payloads

        Returns:
            str: Webhook ID assigned by the provider
            config: Provider-specific configuration for the webhook
        """
        ...

    @abstractmethod
    async def _deregister_webhook(self, webhook: integrations.Webhook, credentials: Credentials) -> None:
        ...

    async def _create_webhook(self, user_id: str, webhook_type: WT, events: list[str], resource: str='', credentials: Optional[Credentials]=None, register: bool=True) -> integrations.Webhook:
        if not app_config.platform_base_url:
            raise MissingConfigError('PLATFORM_BASE_URL must be set to use Webhook functionality')
        id = str(uuid4())
        secret = secrets.token_hex(32)
        provider_name = self.PROVIDER_NAME
        ingress_url = webhook_ingress_url(provider_name=provider_name, webhook_id=id)
        if register:
            if not credentials:
                raise TypeError('credentials are required if register = True')
            (provider_webhook_id, config) = await self._register_webhook(credentials, webhook_type, resource, events, ingress_url, secret)
        else:
            (provider_webhook_id, config) = ('', {})
        return await integrations.create_webhook(integrations.Webhook(id=id, user_id=user_id, provider=provider_name, credentials_id=credentials.id if credentials else '', webhook_type=webhook_type, resource=resource, events=events, provider_webhook_id=provider_webhook_id, config=config, secret=secret))
PROVIDER_NAME: ClassVar[ProviderName]
WebhookType: WT
async def get_suitable_auto_webhook(self, user_id: str, credentials: Credentials, webhook_type: WT, resource: str, events: list[str]) -> integrations.Webhook:
    if not app_config.platform_base_url:
        raise MissingConfigError('PLATFORM_BASE_URL must be set to use Webhook functionality')
    if (webhook := (await integrations.find_webhook_by_credentials_and_props(credentials.id, webhook_type, resource, events))):
        return webhook
    return await self._create_webhook(user_id, webhook_type, events, resource, credentials)
not app_config.platform_base_url
async def get_manual_webhook(self, user_id: str, graph_id: str, webhook_type: WT, events: list[str]):
    if (current_webhook := (await integrations.find_webhook_by_graph_and_props(graph_id, self.PROVIDER_NAME, webhook_type, events))):
        return current_webhook
    return await self._create_webhook(user_id, webhook_type, events, register=False)
(current_webhook := (await integrations.find_webhook_by_graph_and_props(graph_id, self.PROVIDER_NAME, webhook_type, events)))
async def prune_webhook_if_dangling(self, webhook_id: str, credentials: Optional[Credentials]) -> bool:
    webhook = await integrations.get_webhook(webhook_id)
    if webhook.attached_nodes is None:
        raise ValueError('Error retrieving webhook including attached nodes')
    if webhook.attached_nodes:
        return False
    if credentials:
        await self._deregister_webhook(webhook, credentials)
    await integrations.delete_webhook(webhook.id)
    return True
webhook = await integrations.get_webhook(webhook_id)
webhook.attached_nodes Is None
@classmethod
@abstractmethod
async def validate_payload(cls, webhook: integrations.Webhook, request: Request) -> tuple[dict, str]:
    """
        Validates an incoming webhook request and returns its payload and type.

        Params:
            webhook: Object representing the configured webhook and its properties in our system.
            request: Incoming FastAPI `Request`

        Returns:
            dict: The validated payload
            str: The event type associated with the payload
        """
'\n        Validates an incoming webhook request and returns its payload and type.\n\n        Params:\n            webhook: Object representing the configured webhook and its properties in our system.\n            request: Incoming FastAPI `Request`\n\n        Returns:\n            dict: The validated payload\n            str: The event type associated with the payload\n        '
async def trigger_ping(self, webhook: integrations.Webhook, credentials: Credentials | None) -> None:
    """
        Triggers a ping to the given webhook.

        Raises:
            NotImplementedError: if the provider doesn't support pinging
        """
    raise NotImplementedError(f"{self.__class__.__name__} doesn't support pinging")
"\n        Triggers a ping to the given webhook.\n\n        Raises:\n            NotImplementedError: if the provider doesn't support pinging\n        "
raise NotImplementedError(f"{self.__class__.__name__} doesn't support pinging")
@abstractmethod
async def _register_webhook(self, credentials: Credentials, webhook_type: WT, resource: str, events: list[str], ingress_url: str, secret: str) -> tuple[str, dict]:
    """
        Registers a new webhook with the provider.

        Params:
            credentials: The credentials with which to create the webhook
            webhook_type: The provider-specific webhook type to create
            resource: The resource to receive events for
            events: The events to subscribe to
            ingress_url: The ingress URL for webhook payloads
            secret: Secret used to verify webhook payloads

        Returns:
            str: Webhook ID assigned by the provider
            config: Provider-specific configuration for the webhook
        """
    ...
'\n        Registers a new webhook with the provider.\n\n        Params:\n            credentials: The credentials with which to create the webhook\n            webhook_type: The provider-specific webhook type to create\n            resource: The resource to receive events for\n            events: The events to subscribe to\n            ingress_url: The ingress URL for webhook payloads\n            secret: Secret used to verify webhook payloads\n\n        Returns:\n            str: Webhook ID assigned by the provider\n            config: Provider-specific configuration for the webhook\n        '
Ellipsis
@abstractmethod
async def _deregister_webhook(self, webhook: integrations.Webhook, credentials: Credentials) -> None:
    ...
Ellipsis
async def _create_webhook(self, user_id: str, webhook_type: WT, events: list[str], resource: str='', credentials: Optional[Credentials]=None, register: bool=True) -> integrations.Webhook:
    if not app_config.platform_base_url:
        raise MissingConfigError('PLATFORM_BASE_URL must be set to use Webhook functionality')
    id = str(uuid4())
    secret = secrets.token_hex(32)
    provider_name = self.PROVIDER_NAME
    ingress_url = webhook_ingress_url(provider_name=provider_name, webhook_id=id)
    if register:
        if not credentials:
            raise TypeError('credentials are required if register = True')
        (provider_webhook_id, config) = await self._register_webhook(credentials, webhook_type, resource, events, ingress_url, secret)
    else:
        (provider_webhook_id, config) = ('', {})
    return await integrations.create_webhook(integrations.Webhook(id=id, user_id=user_id, provider=provider_name, credentials_id=credentials.id if credentials else '', webhook_type=webhook_type, resource=resource, events=events, provider_webhook_id=provider_webhook_id, config=config, secret=secret))
not app_config.platform_base_url
raise MissingConfigError('PLATFORM_BASE_URL must be set to use Webhook functionality')
return current_webhook
raise ValueError('Error retrieving webhook including attached nodes')
raise MissingConfigError('PLATFORM_BASE_URL must be set to use Webhook functionality')
(webhook := (await integrations.find_webhook_by_credentials_and_props(credentials.id, webhook_type, resource, events)))
webhook.attached_nodes
id = str(uuid4())
secret = secrets.token_hex(32)
provider_name = self.PROVIDER_NAME
ingress_url = webhook_ingress_url(provider_name=provider_name, webhook_id=id)
register
return webhook
return False
not credentials
(provider_webhook_id, config) = ('', {})
await self._deregister_webhook(webhook, credentials)
raise TypeError('credentials are required if register = True')
await integrations.delete_webhook(webhook.id)
return True
(provider_webhook_id, config) = await self._register_webhook(credentials, webhook_type, resource, events, ingress_url, secret)
return await integrations.create_webhook(integrations.Webhook(id=id, user_id=user_id, provider=provider_name, credentials_id=credentials.id if credentials else '', webhook_type=webhook_type, resource=resource, events=events, provider_webhook_id=provider_webhook_id, config=config, secret=secret))