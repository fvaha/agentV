import Foundation
import AnyCodable

public struct AgentToolCall: Codable, Sendable {
    public let name: String
    public let arguments: [String: AnyCodable]

    public init(name: String, arguments: [String: AnyCodable]) {
        self.name = name
        self.arguments = arguments
    }
}

public struct AgentResponse: Codable, Sendable {
    public let response: String
    public let toolCalls: [AgentToolCall]

    public init(response: String, toolCalls: [AgentToolCall]) {
        self.response = response
        self.toolCalls = toolCalls
    }
}

public struct ChatMessage: Codable, Sendable {
    public enum Role: String, Codable {
        case system
        case user
        case assistant
        case tool
    }

    public let role: Role
    public let content: String

    public init(role: Role, content: String) {
        self.role = role
        self.content = content
    }
}

