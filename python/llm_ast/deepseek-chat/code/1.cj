from enum import Enum
from typing import Any, Dict, Literal, Optional

from pydantic import SecretStr
from requests.exceptions import RequestException

from backend.data.block import Block, BlockCategory, BlockOutput, BlockSchema
from backend.data.model import (
    APIKeyCredentials,
    CredentialsField,
    CredentialsMetaInput,
    SchemaField,
)
from backend.integrations.providers import ProviderName
from backend.util.request import requests

TEST_CREDENTIALS = APIKeyCredentials(
    id="01234567-89ab-cdef-0123-456789abcdef",
    provider="ideogram",
    api_key=SecretStr("mock-ideogram-api-key"),
    title="Mock Ideogram API key",
    expires_at=None,
)

TEST_CREDENTIALS_INPUT = {
    "provider": TEST_CREDENTIALS.provider,
    "id": TEST_CREDENTIALS.id,
    "type": TEST_CREDENTIALS.type,
    "title": TEST_CREDENTIALS.type,
}

class IdeogramModelName(str, Enum):
    V2 = "V_2"
    V1 = "V_1"
    V1_TURBO = "V_1_TURBO"
    V2_TURBO = "V_2_TURBO"

class MagicPromptOption(str, Enum):
    AUTO = "AUTO"
    ON = "ON"
    OFF = "OFF"

class StyleType(str, Enum):
    AUTO = "AUTO"
    GENERAL = "GENERAL"
    REALISTIC = "REALISTIC"
    DESIGN = "DESIGN"
    RENDER_3D = "RENDER_3D"
    ANIME = "ANIME"

class ColorPalettePreset(str, Enum):
    NONE = "NONE"
    EMBER = "EMBER"
    FRESH = "FRESH"
    JUNGLE = "JUNGLE"
    MAGIC = "MAGIC"
    MELON = "MELON"
    MOSAIC = "MOSAIC"
    PASTEL = "PASTEL"
    ULTRAMARINE = "ULTRAMARINE"

class AspectRatio(str, Enum):
    ASPECT_10_16 = "ASPECT_10_16"
    ASPECT_16_10 = "ASPECT_16_10"
    ASPECT_9_16 = "ASPECT_9_16"
    ASPECT_16_9 = "ASPECT_16_9"
    ASPECT_3_2 = "ASPECT_3_2"
    ASPECT_2_3 = "ASPECT_2_3"
    ASPECT_4_3 = "ASPECT_4_3"
    ASPECT_3_4 = "ASPECT_3_4"
    ASPECT_1_1 = "ASPECT_1_1"
    ASPECT_1_3 = "ASPECT_1_3"
    ASPECT_3_1 = "ASPECT_3_1"

class UpscaleOption(str, Enum):
    AI_UPSCALE = "AI Upscale"
    NO_UPSCALE = "No Upscale"