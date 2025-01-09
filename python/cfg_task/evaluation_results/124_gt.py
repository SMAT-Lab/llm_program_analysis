import hashlib
import hmac
import logging
import requests
from fastapi import HTTPException, Request
from strenum import StrEnum
from backend.data import integrations
from backend.data.model import Credentials
from backend.integrations.providers import ProviderName
from ._base import BaseWebhooksManager
logger = logging.getLogger(__name__)
class GithubWebhookType(StrEnum):
    REPO = 'repo'
REPO = 'repo'
class GithubWebhooksManager(BaseWebhooksManager):
    PROVIDER_NAME = ProviderName.GITHUB
    WebhookType = GithubWebhookType
    GITHUB_API_URL = 'https://api.github.com'
    GITHUB_API_DEFAULT_HEADERS = {'Accept': 'application/vnd.github.v3+json'}

    @classmethod
    async def validate_payload(cls, webhook: integrations.Webhook, request: Request) -> tuple[dict, str]:
        if not (event_type := request.headers.get('X-GitHub-Event')):
            raise HTTPException(status_code=400, detail='X-GitHub-Event header is missing!')
        if not (signature_header := request.headers.get('X-Hub-Signature-256')):
            raise HTTPException(status_code=403, detail='X-Hub-Signature-256 header is missing!')
        payload_body = await request.body()
        hash_object = hmac.new(webhook.secret.encode('utf-8'), msg=payload_body, digestmod=hashlib.sha256)
        expected_signature = 'sha256=' + hash_object.hexdigest()
        if not hmac.compare_digest(expected_signature, signature_header):
            raise HTTPException(status_code=403, detail="Request signatures didn't match!")
        payload = await request.json()
        if (action := payload.get('action')):
            event_type += f'.{action}'
        return (payload, event_type)

    async def trigger_ping(self, webhook: integrations.Webhook, credentials: Credentials | None) -> None:
        if not credentials:
            raise ValueError('Credentials are required but were not passed')
        headers = {**self.GITHUB_API_DEFAULT_HEADERS, 'Authorization': credentials.bearer()}
        (repo, github_hook_id) = (webhook.resource, webhook.provider_webhook_id)
        ping_url = f'{self.GITHUB_API_URL}/repos/{repo}/hooks/{github_hook_id}/pings'
        response = requests.post(ping_url, headers=headers)
        if response.status_code != 204:
            error_msg = extract_github_error_msg(response)
            raise ValueError(f'Failed to ping GitHub webhook: {error_msg}')

    async def _register_webhook(self, credentials: Credentials, webhook_type: GithubWebhookType, resource: str, events: list[str], ingress_url: str, secret: str) -> tuple[str, dict]:
        if webhook_type == self.WebhookType.REPO and resource.count('/') > 1:
            raise ValueError("Invalid repo format: expected 'owner/repo'")
        github_events = list({event.split('.')[0] for event in events})
        headers = {**self.GITHUB_API_DEFAULT_HEADERS, 'Authorization': credentials.bearer()}
        webhook_data = {'name': 'web', 'active': True, 'events': github_events, 'config': {'url': ingress_url, 'content_type': 'json', 'insecure_ssl': '0', 'secret': secret}}
        response = requests.post(f'{self.GITHUB_API_URL}/repos/{resource}/hooks', headers=headers, json=webhook_data)
        if response.status_code != 201:
            error_msg = extract_github_error_msg(response)
            if 'not found' in error_msg.lower():
                error_msg = f"{error_msg} (Make sure the GitHub account or API key has 'repo' or webhook create permissions to '{resource}')"
            raise ValueError(f'Failed to create GitHub webhook: {error_msg}')
        webhook_id = response.json()['id']
        config = response.json()['config']
        return (str(webhook_id), config)

    async def _deregister_webhook(self, webhook: integrations.Webhook, credentials: Credentials) -> None:
        webhook_type = self.WebhookType(webhook.webhook_type)
        if webhook.credentials_id != credentials.id:
            raise ValueError(f'Webhook #{webhook.id} does not belong to credentials {credentials.id}')
        headers = {**self.GITHUB_API_DEFAULT_HEADERS, 'Authorization': credentials.bearer()}
        if webhook_type == self.WebhookType.REPO:
            repo = webhook.resource
            delete_url = f'{self.GITHUB_API_URL}/repos/{repo}/hooks/{webhook.provider_webhook_id}'
        else:
            raise NotImplementedError(f"Unsupported webhook type '{webhook.webhook_type}'")
        response = requests.delete(delete_url, headers=headers)
        if response.status_code not in [204, 404]:
            error_msg = extract_github_error_msg(response)
            raise ValueError(f'Failed to delete GitHub webhook: {error_msg}')
PROVIDER_NAME = ProviderName.GITHUB
WebhookType = GithubWebhookType
GITHUB_API_URL = 'https://api.github.com'
GITHUB_API_DEFAULT_HEADERS = {'Accept': 'application/vnd.github.v3+json'}
@classmethod
async def validate_payload(cls, webhook: integrations.Webhook, request: Request) -> tuple[dict, str]:
    if not (event_type := request.headers.get('X-GitHub-Event')):
        raise HTTPException(status_code=400, detail='X-GitHub-Event header is missing!')
    if not (signature_header := request.headers.get('X-Hub-Signature-256')):
        raise HTTPException(status_code=403, detail='X-Hub-Signature-256 header is missing!')
    payload_body = await request.body()
    hash_object = hmac.new(webhook.secret.encode('utf-8'), msg=payload_body, digestmod=hashlib.sha256)
    expected_signature = 'sha256=' + hash_object.hexdigest()
    if not hmac.compare_digest(expected_signature, signature_header):
        raise HTTPException(status_code=403, detail="Request signatures didn't match!")
    payload = await request.json()
    if (action := payload.get('action')):
        event_type += f'.{action}'
    return (payload, event_type)
not (event_type := request.headers.get('X-GitHub-Event'))
async def trigger_ping(self, webhook: integrations.Webhook, credentials: Credentials | None) -> None:
    if not credentials:
        raise ValueError('Credentials are required but were not passed')
    headers = {**self.GITHUB_API_DEFAULT_HEADERS, 'Authorization': credentials.bearer()}
    (repo, github_hook_id) = (webhook.resource, webhook.provider_webhook_id)
    ping_url = f'{self.GITHUB_API_URL}/repos/{repo}/hooks/{github_hook_id}/pings'
    response = requests.post(ping_url, headers=headers)
    if response.status_code != 204:
        error_msg = extract_github_error_msg(response)
        raise ValueError(f'Failed to ping GitHub webhook: {error_msg}')
not credentials
async def _deregister_webhook(self, webhook: integrations.Webhook, credentials: Credentials) -> None:
    webhook_type = self.WebhookType(webhook.webhook_type)
    if webhook.credentials_id != credentials.id:
        raise ValueError(f'Webhook #{webhook.id} does not belong to credentials {credentials.id}')
    headers = {**self.GITHUB_API_DEFAULT_HEADERS, 'Authorization': credentials.bearer()}
    if webhook_type == self.WebhookType.REPO:
        repo = webhook.resource
        delete_url = f'{self.GITHUB_API_URL}/repos/{repo}/hooks/{webhook.provider_webhook_id}'
    else:
        raise NotImplementedError(f"Unsupported webhook type '{webhook.webhook_type}'")
    response = requests.delete(delete_url, headers=headers)
    if response.status_code not in [204, 404]:
        error_msg = extract_github_error_msg(response)
        raise ValueError(f'Failed to delete GitHub webhook: {error_msg}')
webhook_type = self.WebhookType(webhook.webhook_type)
webhook.credentials_id NotEq credentials.id
raise HTTPException(status_code=400, detail='X-GitHub-Event header is missing!')
raise ValueError('Credentials are required but were not passed')
raise ValueError(f'Webhook #{webhook.id} does not belong to credentials {credentials.id}')
not (signature_header := request.headers.get('X-Hub-Signature-256'))
headers = {**self.GITHUB_API_DEFAULT_HEADERS, 'Authorization': credentials.bearer()}
(repo, github_hook_id) = (webhook.resource, webhook.provider_webhook_id)
ping_url = f'{self.GITHUB_API_URL}/repos/{repo}/hooks/{github_hook_id}/pings'
response = requests.post(ping_url, headers=headers)
response.status_code NotEq 204
headers = {**self.GITHUB_API_DEFAULT_HEADERS, 'Authorization': credentials.bearer()}
webhook_type Eq self.WebhookType.REPO
raise HTTPException(status_code=403, detail='X-Hub-Signature-256 header is missing!')
error_msg = extract_github_error_msg(response)
raise ValueError(f'Failed to ping GitHub webhook: {error_msg}')
repo = webhook.resource
delete_url = f'{self.GITHUB_API_URL}/repos/{repo}/hooks/{webhook.provider_webhook_id}'
raise NotImplementedError(f"Unsupported webhook type '{webhook.webhook_type}'")
payload_body = await request.body()
hash_object = hmac.new(webhook.secret.encode('utf-8'), msg=payload_body, digestmod=hashlib.sha256)
expected_signature = 'sha256=' + hash_object.hexdigest()
not hmac.compare_digest(expected_signature, signature_header)
async def _register_webhook(self, credentials: Credentials, webhook_type: GithubWebhookType, resource: str, events: list[str], ingress_url: str, secret: str) -> tuple[str, dict]:
    if webhook_type == self.WebhookType.REPO and resource.count('/') > 1:
        raise ValueError("Invalid repo format: expected 'owner/repo'")
    github_events = list({event.split('.')[0] for event in events})
    headers = {**self.GITHUB_API_DEFAULT_HEADERS, 'Authorization': credentials.bearer()}
    webhook_data = {'name': 'web', 'active': True, 'events': github_events, 'config': {'url': ingress_url, 'content_type': 'json', 'insecure_ssl': '0', 'secret': secret}}
    response = requests.post(f'{self.GITHUB_API_URL}/repos/{resource}/hooks', headers=headers, json=webhook_data)
    if response.status_code != 201:
        error_msg = extract_github_error_msg(response)
        if 'not found' in error_msg.lower():
            error_msg = f"{error_msg} (Make sure the GitHub account or API key has 'repo' or webhook create permissions to '{resource}')"
        raise ValueError(f'Failed to create GitHub webhook: {error_msg}')
    webhook_id = response.json()['id']
    config = response.json()['config']
    return (str(webhook_id), config)
webhook_type == self.WebhookType.REPO and resource.count('/') > 1
response = requests.delete(delete_url, headers=headers)
response.status_code NotIn [204, 404]
raise HTTPException(status_code=403, detail="Request signatures didn't match!")
raise ValueError("Invalid repo format: expected 'owner/repo'")
error_msg = extract_github_error_msg(response)
raise ValueError(f'Failed to delete GitHub webhook: {error_msg}')
payload = await request.json()
(action := payload.get('action'))
github_events = list({event.split('.')[0] for event in events})
headers = {**self.GITHUB_API_DEFAULT_HEADERS, 'Authorization': credentials.bearer()}
webhook_data = {'name': 'web', 'active': True, 'events': github_events, 'config': {'url': ingress_url, 'content_type': 'json', 'insecure_ssl': '0', 'secret': secret}}
response = requests.post(f'{self.GITHUB_API_URL}/repos/{resource}/hooks', headers=headers, json=webhook_data)
response.status_code NotEq 201
def extract_github_error_msg(response: requests.Response) -> str:
    error_msgs = []
    resp = response.json()
    if resp.get('message'):
        error_msgs.append(resp['message'])
    if resp.get('errors'):
        error_msgs.extend((f"* {err.get('message', err)}" for err in resp['errors']))
    if resp.get('error'):
        if isinstance(resp['error'], dict):
            error_msgs.append(resp['error'].get('message', resp['error']))
        else:
            error_msgs.append(resp['error'])
    return '\n'.join(error_msgs)
error_msgs = []
resp = response.json()
resp.get('message')
event_type += f'.{action}'
error_msg = extract_github_error_msg(response)
'not found' In error_msg.lower()
error_msgs.append(resp['message'])
return (payload, event_type)
error_msg = f"{error_msg} (Make sure the GitHub account or API key has 'repo' or webhook create permissions to '{resource}')"
resp.get('errors')
raise ValueError(f'Failed to create GitHub webhook: {error_msg}')
error_msgs.extend((f"* {err.get('message', err)}" for err in resp['errors']))
webhook_id = response.json()['id']
config = response.json()['config']
return (str(webhook_id), config)
resp.get('error')
isinstance(resp['error'], dict)
error_msgs.append(resp['error'].get('message', resp['error']))
error_msgs.append(resp['error'])
return '\n'.join(error_msgs)