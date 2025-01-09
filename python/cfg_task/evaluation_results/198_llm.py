from backend.util.settings import AppEnvironment, BehaveAs, Settings

settings = Settings()
def configure_logging():
    import logging

    import autogpt_libs.logging.config

    if (
        settings.config.behave_as == BehaveAs.LOCAL
        or settings.config.app_env == AppEnvironment.LOCAL
    ):
autogpt_libs.logging.config.configure_logging(force_cloud_logging=True)
autogpt_libs.logging.config.configure_logging(force_cloud_logging=False)
logging.getLogger("httpx").setLevel(logging.WARNING)