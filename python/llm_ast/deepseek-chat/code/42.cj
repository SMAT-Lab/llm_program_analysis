class ManualWebhookManagerBase(BaseWebhooksManager[WT]) {
    async def _register_webhook(
        self,
        credentials: Credentials,
        webhook_type: WT,
        resource: str,
        events: list[str],
        ingress_url: str,
        secret: str
    ) -> tuple[str, dict] {
        print(ingress_url)  # FIXME: pass URL to user in front end
        return "", {}
    }

    async def _deregister_webhook(
        self,
        webhook: integrations.Webhook,
        credentials: OAuth2Credentials | APIKeyCredentials
    ) -> None {
        pass
    }
}