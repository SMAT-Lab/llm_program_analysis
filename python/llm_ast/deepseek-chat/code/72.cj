enum HttpMethod {
    GET = "GET"
    POST = "POST"
    PUT = "PUT"
    DELETE = "DELETE"
    PATCH = "PATCH"
    OPTIONS = "OPTIONS"
    HEAD = "HEAD"
}

class SendWebRequestBlock {
    class Input {
        url: str = SchemaField(
            description="The URL to send the request to",
            placeholder="https://api.example.com"
        )
        method: HttpMethod = SchemaField(
            description="The HTTP method to use for the request",
            default=HttpMethod.POST
        )
        headers: dict[str, str] = SchemaField(
            description="The headers to include in the request",
            default={}
        )
        json_format: bool = SchemaField(
            title="JSON format",
            description="Whether to send and receive body as JSON",
            default=True
        )
        body: Any = SchemaField(
            description="The body of the request",
            default=None
        )
    }

    class Output {
        response: object = SchemaField(description="The response from the server")
        client_error: object = SchemaField(description="The error on 4xx status codes")
        server_error: object = SchemaField(description="The error on 5xx status codes")
    }

    fn __init__() {
        super().__init__(
            id="6595ae1f-b924-42cb-9a41-551a0611c4b4",
            description="This block makes an HTTP request to the given URL.",
            categories={BlockCategory.OUTPUT},
            input_schema=SendWebRequestBlock.Input,
            output_schema=SendWebRequestBlock.Output
        )
    }

    fn run(input_data: Input, **kwargs) -> BlockOutput {
        if isinstance(input_data.body, str) {
            input_data.body = json.loads(input_data.body)
        }

        response = requests.request(
            input_data.method.value,
            input_data.url,
            headers=input_data.headers,
            json=input_data.body if input_data.json_format else None,
            data=input_data.body if not input_data.json_format else None
        )

        result = response.json() if input_data.json_format else response.text

        if response.status_code // 100 == 2 {
            yield "response", result
        } elif response.status_code // 100 == 4 {
            yield "client_error", result
        } elif response.status_code // 100 == 5 {
            yield "server_error", result
        } else {
            raise ValueError(f"Unexpected status code: {response.status_code}")
        }
    }
}