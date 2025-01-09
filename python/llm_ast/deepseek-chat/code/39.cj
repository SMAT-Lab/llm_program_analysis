import asyncio
from typing import Literal

import aiohttp
import discord
from pydantic import SecretStr

from backend.data.block import Block, BlockCategory, BlockOutput, BlockSchema
from backend.data.model import (
    APIKeyCredentials,
    CredentialsField,
    CredentialsMetaInput,
    SchemaField,
)
from backend.integrations.providers import ProviderName

DiscordCredentials = CredentialsMetaInput[
    Literal[ProviderName.DISCORD], Literal["api_key"]
]

def DiscordCredentialsField() -> DiscordCredentials:
    return CredentialsField(description="Discord bot token")

TEST_CREDENTIALS = APIKeyCredentials(
    id="01234567-89ab-cdef-0123-456789abcdef",
    provider="discord",
    api_key=SecretStr("test_api_key"),
    title="Mock Discord API key",
    expires_at=None,
)

TEST_CREDENTIALS_INPUT = {
    "provider": TEST_CREDENTIALS.provider,
    "id": TEST_CREDENTIALS.id,
    "type": TEST_CREDENTIALS.type,
    "title": TEST_CREDENTIALS.type,
}