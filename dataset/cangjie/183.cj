package oauth4cj
public interface ServiceBuilderCommon {
    func setCallback(callback: Option<String>): ServiceBuilderCommon
    func setApiKey(apiKey: String): ServiceBuilderCommon
    func setApiSecret(apiSecret: String): ServiceBuilderCommon
    func setApiSecretIsEmptyStringUnsafe(): ServiceBuilderCommon
    func setHttpClientConfig(httpClientConfig: Option<HttpClientConfig>): ServiceBuilderCommon
    func setHttpClient(httpClient: Option<HttpClient>): ServiceBuilderCommon
    func setHttpClientProvider(httpClientProvider: Option<HttpClientProvider>): ServiceBuilderCommon
    func setUserAgent(userAgent: String): ServiceBuilderCommon
}