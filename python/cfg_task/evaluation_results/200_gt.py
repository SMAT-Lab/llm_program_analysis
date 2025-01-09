import ipaddress
import re
import socket
from typing import Callable
from urllib.parse import urlparse, urlunparse
import idna
import requests as req
from backend.util.settings import Config
BLOCKED_IP_NETWORKS = [ipaddress.ip_network('0.0.0.0/8'), ipaddress.ip_network('10.0.0.0/8'), ipaddress.ip_network('127.0.0.0/8'), ipaddress.ip_network('169.254.0.0/16'), ipaddress.ip_network('172.16.0.0/12'), ipaddress.ip_network('192.168.0.0/16'), ipaddress.ip_network('224.0.0.0/4'), ipaddress.ip_network('240.0.0.0/4')]
ALLOWED_SCHEMES = ['http', 'https']
HOSTNAME_REGEX = re.compile('^[A-Za-z0-9.-]+$')
def _canonicalize_url(url: str) -> str:
    url = url.strip().strip('/')
    if not url.startswith(('http://', 'https://')):
        url = 'http://' + url
    url = url.replace('\\', '/')
    return url
url = url.strip().strip('/')
not url.startswith(('http://', 'https://'))
url = 'http://' + url
url = url.replace('\\', '/')
return url
def _is_ip_blocked(ip: str) -> bool:
    """
    Checks if the IP address is in a blocked network.
    """
    ip_addr = ipaddress.ip_address(ip)
    return any((ip_addr in network for network in BLOCKED_IP_NETWORKS))
'\n    Checks if the IP address is in a blocked network.\n    '
ip_addr = ipaddress.ip_address(ip)
return any((ip_addr in network for network in BLOCKED_IP_NETWORKS))
def validate_url(url: str, trusted_origins: list[str]) -> str:
    """
    Validates the URL to prevent SSRF attacks by ensuring it does not point to a private
    or untrusted IP address, unless whitelisted.
    """
    url = _canonicalize_url(url)
    parsed = urlparse(url)
    if parsed.scheme not in ALLOWED_SCHEMES:
        raise ValueError(f"Scheme '{parsed.scheme}' is not allowed. Only HTTP/HTTPS are supported.")
    if not parsed.hostname:
        raise ValueError('Invalid URL: No hostname found.')
    try:
        ascii_hostname = idna.encode(parsed.hostname).decode('ascii')
    except idna.IDNAError:
        raise ValueError('Invalid hostname with unsupported characters.')
    if not HOSTNAME_REGEX.match(ascii_hostname):
        raise ValueError('Hostname contains invalid characters.')
    parsed = parsed._replace(netloc=ascii_hostname)
    url = str(urlunparse(parsed))
    if ascii_hostname in trusted_origins:
        return url
    try:
        ip_addresses = {res[4][0] for res in socket.getaddrinfo(ascii_hostname, None)}
    except socket.gaierror:
        raise ValueError(f'Unable to resolve IP address for hostname {ascii_hostname}')
    if not ip_addresses:
        raise ValueError(f'No IP addresses found for {ascii_hostname}')
    for ip in ip_addresses:
        if _is_ip_blocked(ip):
            raise ValueError(f'Access to private IP address {ip} for hostname {ascii_hostname} is not allowed.')
    return url
'\n    Validates the URL to prevent SSRF attacks by ensuring it does not point to a private\n    or untrusted IP address, unless whitelisted.\n    '
url = _canonicalize_url(url)
parsed = urlparse(url)
parsed.scheme NotIn ALLOWED_SCHEMES
raise ValueError(f"Scheme '{parsed.scheme}' is not allowed. Only HTTP/HTTPS are supported.")
not parsed.hostname
raise ValueError('Invalid URL: No hostname found.')
try:
    ascii_hostname = idna.encode(parsed.hostname).decode('ascii')
except idna.IDNAError:
    raise ValueError('Invalid hostname with unsupported characters.')
ascii_hostname = idna.encode(parsed.hostname).decode('ascii')
raise ValueError('Invalid hostname with unsupported characters.')
not HOSTNAME_REGEX.match(ascii_hostname)
raise ValueError('Hostname contains invalid characters.')
parsed = parsed._replace(netloc=ascii_hostname)
url = str(urlunparse(parsed))
ascii_hostname In trusted_origins
return url
raise ValueError(f'No IP addresses found for {ascii_hostname}')
ip
ip_addresses
_is_ip_blocked(ip)
return url
raise ValueError(f'Access to private IP address {ip} for hostname {ascii_hostname} is not allowed.')
class Requests:
    """
    A wrapper around the requests library that validates URLs before making requests.
    """

    def __init__(self, trusted_origins: list[str] | None=None, raise_for_status: bool=True, extra_url_validator: Callable[[str], str] | None=None, extra_headers: dict[str, str] | None=None):
        self.trusted_origins = []
        for url in trusted_origins or []:
            hostname = urlparse(url).hostname
            if not hostname:
                raise ValueError(f'Invalid URL: Unable to determine hostname of {url}')
            self.trusted_origins.append(hostname)
        self.raise_for_status = raise_for_status
        self.extra_url_validator = extra_url_validator
        self.extra_headers = extra_headers

    def request(self, method, url, headers=None, allow_redirects=False, *args, **kwargs) -> req.Response:
        if self.extra_headers is not None:
            headers = {**(headers or {}), **self.extra_headers}
        url = validate_url(url, self.trusted_origins)
        if self.extra_url_validator is not None:
            url = self.extra_url_validator(url)
        response = req.request(method, url, *args, headers=headers, allow_redirects=allow_redirects, **kwargs)
        if self.raise_for_status:
            response.raise_for_status()
        return response

    def get(self, url, *args, **kwargs) -> req.Response:
        return self.request('GET', url, *args, **kwargs)

    def post(self, url, *args, **kwargs) -> req.Response:
        return self.request('POST', url, *args, **kwargs)

    def put(self, url, *args, **kwargs) -> req.Response:
        return self.request('PUT', url, *args, **kwargs)

    def delete(self, url, *args, **kwargs) -> req.Response:
        return self.request('DELETE', url, *args, **kwargs)

    def head(self, url, *args, **kwargs) -> req.Response:
        return self.request('HEAD', url, *args, **kwargs)

    def options(self, url, *args, **kwargs) -> req.Response:
        return self.request('OPTIONS', url, *args, **kwargs)

    def patch(self, url, *args, **kwargs) -> req.Response:
        return self.request('PATCH', url, *args, **kwargs)
'\n    A wrapper around the requests library that validates URLs before making requests.\n    '
def __init__(self, trusted_origins: list[str] | None=None, raise_for_status: bool=True, extra_url_validator: Callable[[str], str] | None=None, extra_headers: dict[str, str] | None=None):
    self.trusted_origins = []
    for url in trusted_origins or []:
        hostname = urlparse(url).hostname
        if not hostname:
            raise ValueError(f'Invalid URL: Unable to determine hostname of {url}')
        self.trusted_origins.append(hostname)
    self.raise_for_status = raise_for_status
    self.extra_url_validator = extra_url_validator
    self.extra_headers = extra_headers
self.trusted_origins = []
url
trusted_origins or []
hostname = urlparse(url).hostname
not hostname
self.raise_for_status = raise_for_status
self.extra_url_validator = extra_url_validator
self.extra_headers = extra_headers
def request(self, method, url, headers=None, allow_redirects=False, *args, **kwargs) -> req.Response:
    if self.extra_headers is not None:
        headers = {**(headers or {}), **self.extra_headers}
    url = validate_url(url, self.trusted_origins)
    if self.extra_url_validator is not None:
        url = self.extra_url_validator(url)
    response = req.request(method, url, *args, headers=headers, allow_redirects=allow_redirects, **kwargs)
    if self.raise_for_status:
        response.raise_for_status()
    return response
self.extra_headers IsNot None
raise ValueError(f'Invalid URL: Unable to determine hostname of {url}')
self.trusted_origins.append(hostname)
headers = {**(headers or {}), **self.extra_headers}
url = validate_url(url, self.trusted_origins)
self.extra_url_validator IsNot None
url = self.extra_url_validator(url)
response = req.request(method, url, *args, headers=headers, allow_redirects=allow_redirects, **kwargs)
self.raise_for_status
response.raise_for_status()
return response
def get(self, url, *args, **kwargs) -> req.Response:
    return self.request('GET', url, *args, **kwargs)
return self.request('GET', url, *args, **kwargs)
def post(self, url, *args, **kwargs) -> req.Response:
    return self.request('POST', url, *args, **kwargs)
return self.request('POST', url, *args, **kwargs)
def put(self, url, *args, **kwargs) -> req.Response:
    return self.request('PUT', url, *args, **kwargs)
return self.request('PUT', url, *args, **kwargs)
def delete(self, url, *args, **kwargs) -> req.Response:
    return self.request('DELETE', url, *args, **kwargs)
return self.request('DELETE', url, *args, **kwargs)
def head(self, url, *args, **kwargs) -> req.Response:
    return self.request('HEAD', url, *args, **kwargs)
return self.request('HEAD', url, *args, **kwargs)
def options(self, url, *args, **kwargs) -> req.Response:
    return self.request('OPTIONS', url, *args, **kwargs)
return self.request('OPTIONS', url, *args, **kwargs)
def patch(self, url, *args, **kwargs) -> req.Response:
    return self.request('PATCH', url, *args, **kwargs)
return self.request('PATCH', url, *args, **kwargs)
requests = Requests(trusted_origins=Config().trust_endpoints_for_requests)