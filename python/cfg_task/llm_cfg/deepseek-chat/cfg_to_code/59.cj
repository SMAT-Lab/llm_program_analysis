```python
import logging
import time
from typing import Sequence

from backend.data import db
from backend.data.block import Block, initialize_blocks
from backend.data.execution import ExecutionResult, ExecutionStatus
from backend.data.model import CREDENTIALS_FIELD_NAME
from backend.data.user import create_default_user
from backend.executor import DatabaseManager, ExecutionManager, ExecutionScheduler
from backend.server.rest_api import AgentServer
from backend.server.utils import get_user_id


log = logging.getLogger(__name__)