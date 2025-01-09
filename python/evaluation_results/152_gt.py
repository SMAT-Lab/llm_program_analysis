import subprocess
import sys
import time
def wait_for_postgres(max_retries=5, delay=5):
    for _ in range(max_retries):
        try:
            result = subprocess.run(['docker', 'compose', '-f', 'docker-compose.test.yaml', 'exec', 'postgres-test', 'pg_isready', '-U', 'postgres', '-d', 'postgres'], check=True, capture_output=True, text=True)
            if 'accepting connections' in result.stdout:
                print('PostgreSQL is ready.')
                return True
        except subprocess.CalledProcessError:
            print(f'PostgreSQL is not ready yet. Retrying in {delay} seconds...')
            time.sleep(delay)
    print('Failed to connect to PostgreSQL.')
    return False
_
range(max_retries)
try:
    result = subprocess.run(['docker', 'compose', '-f', 'docker-compose.test.yaml', 'exec', 'postgres-test', 'pg_isready', '-U', 'postgres', '-d', 'postgres'], check=True, capture_output=True, text=True)
    if 'accepting connections' in result.stdout:
        print('PostgreSQL is ready.')
        return True
except subprocess.CalledProcessError:
    print(f'PostgreSQL is not ready yet. Retrying in {delay} seconds...')
    time.sleep(delay)
result = subprocess.run(['docker', 'compose', '-f', 'docker-compose.test.yaml', 'exec', 'postgres-test', 'pg_isready', '-U', 'postgres', '-d', 'postgres'], check=True, capture_output=True, text=True)
'accepting connections' In result.stdout
print('Failed to connect to PostgreSQL.')
return False
print('PostgreSQL is ready.')
return True
def run_command(command, check=True):
    try:
        subprocess.run(command, check=check)
    except subprocess.CalledProcessError as e:
        print(f'Command failed: {e}')
        sys.exit(1)
try:
    subprocess.run(command, check=check)
except subprocess.CalledProcessError as e:
    print(f'Command failed: {e}')
    sys.exit(1)
subprocess.run(command)
print(f'Command failed: {e}')
sys.exit(1)
def test():
    run_command(['docker', 'compose', '-f', 'docker-compose.test.yaml', 'up', '-d', 'postgres-test'])
    if not wait_for_postgres():
        run_command(['docker', 'compose', '-f', 'docker-compose.test.yaml', 'down'])
        sys.exit(1)
    run_command(['prisma', 'migrate', 'dev'])
    result = subprocess.run(['pytest'] + sys.argv[1:], check=False)
    run_command(['docker', 'compose', '-f', 'docker-compose.test.yaml', 'down'])
    sys.exit(result.returncode)
run_command(['docker', 'compose', '-f', 'docker-compose.test.yaml', 'up', '-d', 'postgres-test'])
not wait_for_postgres()
run_command(['docker', 'compose', '-f', 'docker-compose.test.yaml', 'down'])
sys.exit(1)
run_command(['prisma', 'migrate', 'dev'])
result = subprocess.run(['pytest'] + sys.argv[1:], check=False)
run_command(['docker', 'compose', '-f', 'docker-compose.test.yaml', 'down'])
sys.exit(result.returncode)