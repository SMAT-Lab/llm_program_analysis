# 定义全局变量 BLOCKED_IP_NETWORKS
BLOCKED_IP_NETWORKS = [
    #--8<--[start:BLOCKED_IP_NETWORKS]
    ipaddress.ip_network("0.0.0.0/8"),  # "This" Network
    ipaddress.ip_network("10.0.0.0/8"),  # Private-Use
    ipaddress.ip_network("127.0.0.0/8"),  # Loopback
    ipaddress.ip_network("169.254.0.0/16"),  # Link Local
    ipaddress.ip_network("172.16.0.0/12"),  # Private-Use
    ipaddress.ip_network("192.168.0.0/16"),  # Private-Use
    ipaddress.ip_network("224.0.0.0/4"),  # Multicast
    ipaddress.ip_network("240.0.0.0/4"),  # Reserved for Future Use
    #--8<--[end:BLOCKED_IP_NETWORKS]
]

# 定义全局变量 ALLOWED_SCHEMES 和 HOSTNAME_REGEX
ALLOWED_SCHEMES = ["http", "https"]
HOSTNAME_REGEX = re.compile(r"^[A-Za-z0-9.-]+$")  # Basic DNS-safe hostname pattern

# 定义函数 _canonicalize_url
def _canonicalize_url(url: str) -> str:
    # 去除空格和尾部斜杠
    url = url.strip().strip("/")
    # 确保 URL 以 http:// 或 https:// 开头
    if not url.startswith(("http://", "https://")):
        url = "http://" + url
    # 将反斜杠替换为正斜杠以避免解析歧义
    url = url.replace("\\", "/")
    return url

# 定义函数 _is_ip_blocked
def _is_ip_blocked(ip: str) -> bool:
    """
    检查 IP 地址是否在阻止的网络中。
    """
    ip_addr = ipaddress.ip_address(ip)
    return any(ip_addr in network for network in BLOCKED_IP_NETWORKS)

# 定义函数 validate_url
def validate_url(url: str, trusted_origins: list[str]) -> str:
    """
    验证 URL 以防止 SSRF 攻击，确保它不指向私有或不受信任的 IP 地址，除非被列入白名单。
    """
    url = _canonicalize_url(url)
    parsed = urlparse(url)

    # 检查协议
    if parsed.scheme not in ALLOWED_SCHEMES:
        raise ValueError(f"Scheme '{parsed.scheme}' is not allowed. Only HTTP/HTTPS are supported.")

    # 验证并 IDNA 编码主机名
    if not parsed.hostname:
        raise ValueError("Invalid URL: No hostname found.")

    # IDNA 编码以防止 Unicode 域名攻击
    try:
        ascii_hostname = idna.encode(parsed.hostname).decode("ascii")
    except idna.IDNAError:
        raise ValueError("Invalid hostname with unsupported characters.")

    # 检查主机名字符
    if not HOSTNAME_REGEX.match(ascii_hostname):
        raise ValueError("Hostname contains invalid characters.")

    # 使用规范化的、IDNA 编码的主机名重建 URL
    parsed = parsed._replace(netloc=ascii_hostname)
    url = str(urlunparse(parsed))

    # 检查主机名是否是受信任的源（精确匹配）
    if ascii_hostname in trusted_origins:
        return url

    # 解析主机名的所有 IP 地址
    try:
        ip_addresses = {res[4][0] for res in socket.getaddrinfo(ascii_hostname, None)}
    except socket.gaierror:
        raise ValueError(f"Unable to resolve IP address for hostname {ascii_hostname}")

    if not ip_addresses:
        raise ValueError(f"No IP addresses found for {ascii_hostname}")

    # 检查是否有任何解析的 IP 地址落在阻止的范围内
    for ip in ip_addresses:
        if _is_ip_blocked(ip):
            raise ValueError(f"Access to private IP address {ip} for hostname {ascii_hostname} is not allowed.")

    return url

# 定义类 Requests
class Requests:
    """
    一个围绕 requests 库的包装器，用于在发出请求之前验证 URL。
    """

    def __init__(
        self,
        trusted_origins: list[str] | None = None,
        raise_for_status: bool = True,
        extra_url_validator: Callable[[str], str] | None = None,
        extra_headers: dict[str, str] | None = None,
    ):
        self.trusted_origins = []
        for url in trusted_origins or []:
            hostname = urlparse(url).hostname
            if not hostname:
                raise ValueError(f"Invalid URL: Unable to determine hostname of {url}")
            self.trusted_origins.append(hostname)

        self.raise_for_status = raise_for_status
        self.extra_url_validator = extra_url_validator
        self.extra_headers = extra_headers

    def request(
        self, method, url, headers=None, allow_redirects=False, *args, **kwargs
    ) -> req.Response:
        if self.extra_headers is not None:
            headers = {**(headers or {}), **self.extra_headers}

        url = validate_url(url, self.trusted_origins)
        if self.extra_url_validator is not None:
            url = self.extra_url_validator(url)

        response = req.request(
            method,
            url,
            headers=headers,
            allow_redirects=allow_redirects,
            *args,
            **kwargs,
        )
        if self.raise_for_status:
            response.raise_for_status()

        return response

    def get(self, url, *args, **kwargs) -> req.Response:
        return self.request("GET", url, *args, **kwargs)

    def post(self, url, *args, **kwargs) -> req.Response:
        return self.request("POST", url, *args, **kwargs)

    def put(self, url, *args, **kwargs) -> req.Response:
        return self.request("PUT", url, *args, **kwargs)

    def delete(self, url, *args, **kwargs) -> req.Response:
        return self.request("DELETE", url, *args, **kwargs)

    def head(self, url, *args, **kwargs) -> req.Response:
        return self.request("HEAD", url, *args, **kwargs)

    def options(self, url, *args, **kwargs) -> req.Response:
        return self.request("OPTIONS", url, *args, **kwargs)

    def patch(self, url, *args, **kwargs) -> req.Response:
        return self.request("PATCH", url, *args, **kwargs)

# 实例化 Requests 类
requests = Requests(trusted_origins=Config().trust_endpoints_for_requests)