import json
import os
import requests
import sys
import time
from typing import Dict, List, Tuple
CHECK_INTERVAL = 30
def get_environment_variables() -> Tuple[str, str, str, str, str]:
    """Retrieve and return necessary environment variables."""
    try:
        with open(os.environ['GITHUB_EVENT_PATH']) as f:
            event = json.load(f)
        if 'pull_request' in event:
            sha = event['pull_request']['head']['sha']
        else:
            sha = os.environ['GITHUB_SHA']
        return (os.environ['GITHUB_API_URL'], os.environ['GITHUB_REPOSITORY'], sha, os.environ['GITHUB_TOKEN'], os.environ['GITHUB_RUN_ID'])
    except KeyError as e:
        print(f'Error: Missing required environment variable or event data: {e}')
        sys.exit(1)
'Retrieve and return necessary environment variables.'
try:
    with open(os.environ['GITHUB_EVENT_PATH']) as f:
        event = json.load(f)
    if 'pull_request' in event:
        sha = event['pull_request']['head']['sha']
    else:
        sha = os.environ['GITHUB_SHA']
    return (os.environ['GITHUB_API_URL'], os.environ['GITHUB_REPOSITORY'], sha, os.environ['GITHUB_TOKEN'], os.environ['GITHUB_RUN_ID'])
except KeyError as e:
    print(f'Error: Missing required environment variable or event data: {e}')
    sys.exit(1)
with open(os.environ['GITHUB_EVENT_PATH']) as f:
    event = json.load(f)
event = json.load(f)
'pull_request' In event
sha = event['pull_request']['head']['sha']
sha = os.environ['GITHUB_SHA']
return (os.environ['GITHUB_API_URL'], os.environ['GITHUB_REPOSITORY'], sha, os.environ['GITHUB_TOKEN'], os.environ['GITHUB_RUN_ID'])
print(f'Error: Missing required environment variable or event data: {e}')
sys.exit(1)
def make_api_request(url: str, headers: Dict[str, str]) -> Dict:
    """Make an API request and return the JSON response."""
    try:
        print('Making API request to:', url)
        response = requests.get(url, headers=headers, timeout=10)
        response.raise_for_status()
        return response.json()
    except requests.RequestException as e:
        print(f'Error: API request failed. {e}')
        sys.exit(1)
'Make an API request and return the JSON response.'
try:
    print('Making API request to:', url)
    response = requests.get(url, headers=headers, timeout=10)
    response.raise_for_status()
    return response.json()
except requests.RequestException as e:
    print(f'Error: API request failed. {e}')
    sys.exit(1)
print('Making API request to:', url)
response = requests.get(url, headers=headers, timeout=10)
response.raise_for_status()
return response.json()
print(f'Error: API request failed. {e}')
sys.exit(1)
def process_check_runs(check_runs: List[Dict]) -> Tuple[bool, bool]:
    """Process check runs and return their status."""
    runs_in_progress = False
    all_others_passed = True
    for run in check_runs:
        if str(run['name']) != 'Check PR Status':
            status = run['status']
            conclusion = run['conclusion']
            if status == 'completed':
                if conclusion not in ['success', 'skipped', 'neutral']:
                    all_others_passed = False
                    print(f"Check run {run['name']} (ID: {run['id']}) has conclusion: {conclusion}")
            else:
                runs_in_progress = True
                print(f"Check run {run['name']} (ID: {run['id']}) is still {status}.")
                all_others_passed = False
        else:
            print(f"Skipping check run {run['name']} (ID: {run['id']}) as it is the current run.")
    return (runs_in_progress, all_others_passed)
'Process check runs and return their status.'
runs_in_progress = False
all_others_passed = True
run
check_runs
str(run['name']) NotEq 'Check PR Status'
return (runs_in_progress, all_others_passed)
status = run['status']
conclusion = run['conclusion']
status Eq 'completed'
print(f"Skipping check run {run['name']} (ID: {run['id']}) as it is the current run.")
conclusion NotIn ['success', 'skipped', 'neutral']
runs_in_progress = True
print(f"Check run {run['name']} (ID: {run['id']}) is still {status}.")
all_others_passed = False
all_others_passed = False
print(f"Check run {run['name']} (ID: {run['id']}) has conclusion: {conclusion}")
def main():
    (api_url, repo, sha, github_token, current_run_id) = get_environment_variables()
    endpoint = f'{api_url}/repos/{repo}/commits/{sha}/check-runs'
    headers = {'Accept': 'application/vnd.github.v3+json'}
    if github_token:
        headers['Authorization'] = f'token {github_token}'
    print(f'Current run ID: {current_run_id}')
    while True:
        data = make_api_request(endpoint, headers)
        check_runs = data['check_runs']
        print('Processing check runs...')
        print(check_runs)
        (runs_in_progress, all_others_passed) = process_check_runs(check_runs)
        if not runs_in_progress:
            break
        print(f'Some check runs are still in progress. Waiting {CHECK_INTERVAL} seconds before checking again...')
        time.sleep(CHECK_INTERVAL)
    if all_others_passed:
        print('All other completed check runs have passed. This check passes.')
        sys.exit(0)
    else:
        print('Some check runs have failed or have not completed. This check fails.')
        sys.exit(1)
(api_url, repo, sha, github_token, current_run_id) = get_environment_variables()
endpoint = f'{api_url}/repos/{repo}/commits/{sha}/check-runs'
headers = {'Accept': 'application/vnd.github.v3+json'}
github_token
headers['Authorization'] = f'token {github_token}'
print(f'Current run ID: {current_run_id}')
True
data = make_api_request(endpoint, headers)
check_runs = data['check_runs']
print('Processing check runs...')
print(check_runs)
(runs_in_progress, all_others_passed) = process_check_runs(check_runs)
not runs_in_progress
all_others_passed
break
print(f'Some check runs are still in progress. Waiting {CHECK_INTERVAL} seconds before checking again...')
time.sleep(CHECK_INTERVAL)
print('All other completed check runs have passed. This check passes.')
sys.exit(0)
print('Some check runs have failed or have not completed. This check fails.')
sys.exit(1)
__name__ Eq '__main__'
main()