def main():
    """
    Run all the processes required for the AutoGPT-server REST API.
    """
    run_processes(
        DatabaseManager(),
        ExecutionScheduler(),
        AgentServer(),
    )