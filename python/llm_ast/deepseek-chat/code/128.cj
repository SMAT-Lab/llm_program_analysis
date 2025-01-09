class BaseOAuthHandler(ABC):
    PROVIDER_NAME: ClassVar[ProviderName]
    DEFAULT_SCOPES: ClassVar[list[str]] = []