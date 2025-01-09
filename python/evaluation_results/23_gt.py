import pytest
from backend.util.request import validate_url
def test_validate_url():
    with pytest.raises(ValueError):
        validate_url('localhost', [])
    with pytest.raises(ValueError):
        validate_url('192.168.1.1', [])
    with pytest.raises(ValueError):
        validate_url('127.0.0.1', [])
    with pytest.raises(ValueError):
        validate_url('0.0.0.0', [])
    assert validate_url('google.com/a?b=c', []) == 'http://google.com/a?b=c'
    assert validate_url('github.com?key=!@!@', []) == 'http://github.com?key=!@!@'
    with pytest.raises(ValueError):
        validate_url('ftp://example.com', [])
    with pytest.raises(ValueError):
        validate_url('file://example.com', [])
    assert validate_url('http://xn--exmple-cua.com', []) == 'http://xn--exmple-cua.com'
    with pytest.raises(ValueError):
        validate_url('http://exa◌mple.com', [])
    with pytest.raises(ValueError):
        validate_url('::1', [])
    with pytest.raises(ValueError):
        validate_url('http://[::1]', [])
    with pytest.raises(ValueError):
        validate_url('http://example_underscore.com', [])
    with pytest.raises(ValueError):
        validate_url('http://exa mple.com', [])
    with pytest.raises(ValueError):
        validate_url('http://', [])
    with pytest.raises(ValueError):
        validate_url('://missing-scheme', [])
    trusted = ['internal-api.company.com', '10.0.0.5']
    assert validate_url('internal-api.company.com', trusted) == 'http://internal-api.company.com'
    assert validate_url('10.0.0.5', ['10.0.0.5']) == 'http://10.0.0.5'
    assert validate_url('example.com/path%20with%20spaces', []) == 'http://example.com/path%20with%20spaces'
    assert validate_url('http://example.com\\backslash', []) == 'http://example.com/backslash'
    assert validate_url('example.com', []) == 'http://example.com'
    assert validate_url('https://secure.com', []) == 'https://secure.com'
    assert validate_url('example.com?param=äöü', []) == 'http://example.com?param=äöü'
with pytest.raises(ValueError):
    validate_url('localhost', [])
validate_url('localhost', [])
with pytest.raises(ValueError):
    validate_url('192.168.1.1', [])
validate_url('192.168.1.1', [])
with pytest.raises(ValueError):
    validate_url('127.0.0.1', [])
validate_url('127.0.0.1', [])
with pytest.raises(ValueError):
    validate_url('0.0.0.0', [])
validate_url('0.0.0.0', [])
assert validate_url('google.com/a?b=c', []) == 'http://google.com/a?b=c'
assert validate_url('github.com?key=!@!@', []) == 'http://github.com?key=!@!@'
with pytest.raises(ValueError):
    validate_url('ftp://example.com', [])
validate_url('ftp://example.com', [])
with pytest.raises(ValueError):
    validate_url('file://example.com', [])
validate_url('file://example.com', [])
assert validate_url('http://xn--exmple-cua.com', []) == 'http://xn--exmple-cua.com'
with pytest.raises(ValueError):
    validate_url('http://exa◌mple.com', [])
validate_url('http://exa◌mple.com', [])
with pytest.raises(ValueError):
    validate_url('::1', [])
validate_url('::1', [])
with pytest.raises(ValueError):
    validate_url('http://[::1]', [])
validate_url('http://[::1]', [])
with pytest.raises(ValueError):
    validate_url('http://example_underscore.com', [])
validate_url('http://example_underscore.com', [])
with pytest.raises(ValueError):
    validate_url('http://exa mple.com', [])
validate_url('http://exa mple.com', [])
with pytest.raises(ValueError):
    validate_url('http://', [])
validate_url('http://', [])
with pytest.raises(ValueError):
    validate_url('://missing-scheme', [])
validate_url('://missing-scheme', [])
trusted = ['internal-api.company.com', '10.0.0.5']
assert validate_url('internal-api.company.com', trusted) == 'http://internal-api.company.com'
assert validate_url('10.0.0.5', ['10.0.0.5']) == 'http://10.0.0.5'
assert validate_url('example.com/path%20with%20spaces', []) == 'http://example.com/path%20with%20spaces'
assert validate_url('http://example.com\\backslash', []) == 'http://example.com/backslash'
assert validate_url('example.com', []) == 'http://example.com'
assert validate_url('https://secure.com', []) == 'https://secure.com'
assert validate_url('example.com?param=äöü', []) == 'http://example.com?param=äöü'