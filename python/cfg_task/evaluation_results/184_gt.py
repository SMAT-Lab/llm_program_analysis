from typing import Dict, Set
from fastapi import WebSocket
from backend.data import execution
from backend.server.model import Methods, WsMessage
class ConnectionManager:

    def __init__(self):
        self.active_connections: Set[WebSocket] = set()
        self.subscriptions: Dict[str, Set[WebSocket]] = {}

    async def connect(self, websocket: WebSocket):
        await websocket.accept()
        self.active_connections.add(websocket)

    def disconnect(self, websocket: WebSocket):
        self.active_connections.remove(websocket)
        for subscribers in self.subscriptions.values():
            subscribers.discard(websocket)

    async def subscribe(self, graph_id: str, websocket: WebSocket):
        if graph_id not in self.subscriptions:
            self.subscriptions[graph_id] = set()
        self.subscriptions[graph_id].add(websocket)

    async def unsubscribe(self, graph_id: str, websocket: WebSocket):
        if graph_id in self.subscriptions:
            self.subscriptions[graph_id].discard(websocket)
            if not self.subscriptions[graph_id]:
                del self.subscriptions[graph_id]

    async def send_execution_result(self, result: execution.ExecutionResult):
        graph_id = result.graph_id
        if graph_id in self.subscriptions:
            message = WsMessage(method=Methods.EXECUTION_EVENT, channel=graph_id, data=result.model_dump()).model_dump_json()
            for connection in self.subscriptions[graph_id]:
                await connection.send_text(message)
def __init__(self):
    self.active_connections: Set[WebSocket] = set()
    self.subscriptions: Dict[str, Set[WebSocket]] = {}
self.active_connections: Set[WebSocket] = set()
self.subscriptions: Dict[str, Set[WebSocket]] = {}
async def connect(self, websocket: WebSocket):
    await websocket.accept()
    self.active_connections.add(websocket)
await websocket.accept()
self.active_connections.add(websocket)
def disconnect(self, websocket: WebSocket):
    self.active_connections.remove(websocket)
    for subscribers in self.subscriptions.values():
        subscribers.discard(websocket)
self.active_connections.remove(websocket)
subscribers
self.subscriptions.values()
subscribers.discard(websocket)
async def subscribe(self, graph_id: str, websocket: WebSocket):
    if graph_id not in self.subscriptions:
        self.subscriptions[graph_id] = set()
    self.subscriptions[graph_id].add(websocket)
graph_id NotIn self.subscriptions
self.subscriptions[graph_id] = set()
self.subscriptions[graph_id].add(websocket)
async def unsubscribe(self, graph_id: str, websocket: WebSocket):
    if graph_id in self.subscriptions:
        self.subscriptions[graph_id].discard(websocket)
        if not self.subscriptions[graph_id]:
            del self.subscriptions[graph_id]
graph_id In self.subscriptions
self.subscriptions[graph_id].discard(websocket)
not self.subscriptions[graph_id]
async def send_execution_result(self, result: execution.ExecutionResult):
    graph_id = result.graph_id
    if graph_id in self.subscriptions:
        message = WsMessage(method=Methods.EXECUTION_EVENT, channel=graph_id, data=result.model_dump()).model_dump_json()
        for connection in self.subscriptions[graph_id]:
            await connection.send_text(message)
graph_id = result.graph_id
graph_id In self.subscriptions
del self.subscriptions[graph_id]
message = WsMessage(method=Methods.EXECUTION_EVENT, channel=graph_id, data=result.model_dump()).model_dump_json()
connection
self.subscriptions[graph_id]
await connection.send_text(message)