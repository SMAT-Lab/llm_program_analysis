import json
import logging
from pathlib import Path

from pydantic import BaseModel

from backend.data.block import (
    Block,
    BlockCategory,
    BlockOutput,
    BlockSchema,
    BlockWebhookConfig,
)
from backend.data.model import SchemaField

from ._auth import (
    TEST_CREDENTIALS,
    TEST_CREDENTIALS_INPUT,
    GithubCredentialsField,
    GithubCredentialsInput,
)

logger = logging.getLogger(__name__)

#--8<--[start:GithubTriggerExample]
class GitHubTriggerBase:
    class Input(BlockSchema):
        credentials: GithubCredentialsInput = GithubCredentialsField("repo")
        repo: str = SchemaField(
            description=(
                "Repository to subscribe to.\n\n"
                "**Note:** Make sure your GitHub credentials have permissions "
                "to create webhooks on this repo."
            ),
            placeholder="{owner}/{repo}",
        )

    #--8<--[start:example-payload-field]
    payload: dict = SchemaField(hidden=True, default={})
    #--8<--[end:example-payload-field]

    class Output(BlockSchema):
        payload: dict = SchemaField(
            description="The complete webhook payload that was received from GitHub. "
            "Includes information about the affected resource (e.g. pull request), "
            "the event, and the user who triggered the event."
        )
        triggered_by_user: dict = SchemaField(
            description="Object representing the GitHub user who triggered the event"
        )
        error: str = SchemaField(
            description="Error message if the payload could not be processed"
        )

    def run(self, input_data: Input, **kwargs) -> BlockOutput:
        yield "payload", input_data.payload
        yield "triggered_by_user", input_data.payload["sender"]