from backend.app import run_processes
from backend.server.ws_api import WebsocketServer
def main():
    """
    Run all the processes required for the AutoGPT-server WebSocket API.
    """
    run_processes(WebsocketServer())
'\n    Run all the processes required for the AutoGPT-server WebSocket API.\n    '
run_processes(WebsocketServer())
__name__ Eq '__main__'
main()