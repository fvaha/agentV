import Foundation

public protocol LLMClient: Sendable {
    func chat(
        messages: [ChatMessage],
        tools: [Tool]
    ) async throws -> AgentResponse
}

public struct AgentAPIConfiguration: Sendable {
    public let baseURL: URL

    public init(baseURL: URL) {
        self.baseURL = baseURL
    }
}

public enum AgentAPIError: Error {
    case invalidResponse
}

public final class HTTPAgentClient: LLMClient {
    private let configuration: AgentAPIConfiguration
    private let urlSession: URLSession

    public init(
        configuration: AgentAPIConfiguration,
        urlSession: URLSession = .shared
    ) {
        self.configuration = configuration
        self.urlSession = urlSession
    }

    public func chat(
        messages: [ChatMessage],
        tools: [Tool]
    ) async throws -> AgentResponse {
        struct Payload: Encodable {
            let messages: [ChatMessage]
            let tools: [Tool]
        }

        let payload = Payload(messages: messages, tools: tools)
        let data = try JSONEncoder().encode(payload)

        var request = URLRequest(url: configuration.baseURL.appendingPathComponent("chat"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (responseData, response) = try await urlSession.upload(for: request, from: data)

        guard
            let httpResponse = response as? HTTPURLResponse,
            (200 ..< 300).contains(httpResponse.statusCode)
        else {
            throw AgentAPIError.invalidResponse
        }

        return try JSONDecoder().decode(AgentResponse.self, from: responseData)
    }
}

