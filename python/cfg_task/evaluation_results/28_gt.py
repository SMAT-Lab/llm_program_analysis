from enum import Enum
from typing import Any, Optional
from pydantic import BaseModel
from backend.data.block import BlockInput
class BlockCostType(str, Enum):
    RUN = 'run'
    BYTE = 'byte'
    SECOND = 'second'
    DOLLAR = 'dollar'
RUN = 'run'
BYTE = 'byte'
SECOND = 'second'
DOLLAR = 'dollar'
class BlockCost(BaseModel):
    cost_amount: int
    cost_filter: BlockInput
    cost_type: BlockCostType

    def __init__(self, cost_amount: int, cost_type: BlockCostType=BlockCostType.RUN, cost_filter: Optional[BlockInput]=None, **data: Any) -> None:
        super().__init__(cost_amount=cost_amount, cost_filter=cost_filter or {}, cost_type=cost_type, **data)
cost_amount: int
cost_filter: BlockInput
cost_type: BlockCostType
def __init__(self, cost_amount: int, cost_type: BlockCostType=BlockCostType.RUN, cost_filter: Optional[BlockInput]=None, **data: Any) -> None:
    super().__init__(cost_amount=cost_amount, cost_filter=cost_filter or {}, cost_type=cost_type, **data)
super().__init__()