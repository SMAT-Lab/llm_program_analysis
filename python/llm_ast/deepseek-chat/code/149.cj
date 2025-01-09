class CompassWebhookType(StrEnum):
    TRANSCRIPTION = "transcription"
    TASK = "task"

class CompassWebhookManager(ManualWebhookManagerBase):
    PROVIDER_NAME = ProviderName.COMPASS
    WebhookType = CompassWebhookType

    @classmethod
    async def validate_payload(cls, webhook: integrations.Webhook, request: Request) -> tuple[dict, str]:
        payload = await request.json()
        event_type = CompassWebhookType.TRANSCRIPTION  # currently the only type
        return payload, event_type