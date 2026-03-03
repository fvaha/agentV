import Foundation

public typealias ToolHandler = @Sendable (_ call: AgentToolCall, _ context: inout [String: String]) async throws -> Void

public actor UniversalAgent {
    private let llmClient: any LLMClient
    private let tools: [Tool]
    private var context: [String: String]
    private var toolHandlers: [String: ToolHandler]
    private var enabledToolNames: Set<String>?

    public init(
        llmClient: some LLMClient,
        tools: [Tool] = [],
        toolHandlers: [String: ToolHandler] = [:],
        initialContext: [String: String] = [:]
    ) {
        self.llmClient = llmClient
        self.tools = tools
        self.toolHandlers = toolHandlers
        self.context = initialContext
        self.enabledToolNames = nil
    }

    public func updateContext(key: String, value: String) {
        context[key] = value
    }

    public func currentContext() -> [String: String] {
        context
    }

    public func availableTools() -> [Tool] {
        tools
    }

    public func setEnabledTools(_ names: Set<String>?) {
        enabledToolNames = names
    }

    public func enabledTools() -> [Tool] {
        guard let enabledToolNames else {
            return tools
        }
        return tools.filter { enabledToolNames.contains($0.name) }
    }

    public func registerToolHandler(
        name: String,
        handler: @escaping ToolHandler
    ) {
        toolHandlers[name] = handler
    }

    public func run(
        systemPrompt: String,
        userPrompt: String,
        extraContext: [String: String] = [:]
    ) async throws -> AgentResponse {
        var messages: [ChatMessage] = []

        messages.append(ChatMessage(role: .system, content: systemPrompt))

        for (key, value) in context {
            messages.append(ChatMessage(role: .user, content: "Context \(key): \(value)"))
        }

        for (key, value) in extraContext {
            messages.append(ChatMessage(role: .user, content: "Context \(key): \(value)"))
        }

        messages.append(ChatMessage(role: .user, content: userPrompt))

        let toolsToUse = enabledTools()
        return try await llmClient.chat(messages: messages, tools: toolsToUse)
    }

    public func executeTool(_ toolCall: AgentToolCall) async throws {
        guard var handlerContext = Optional(context),
              let handler = toolHandlers[toolCall.name] else {
            print("Tool '\(toolCall.name)' not implemented.")
            return
        }

        try await handler(toolCall, &handlerContext)
        context = handlerContext
    }

    public func runWithToolCalls(
        systemPrompt: String,
        userPrompt: String,
        extraContext: [String: String] = [:]
    ) async throws -> (response: String, toolCalls: [AgentToolCall]) {
        let agentResponse = try await run(
            systemPrompt: systemPrompt,
            userPrompt: userPrompt,
            extraContext: extraContext
        )

        for toolCall in agentResponse.toolCalls {
            try await executeTool(toolCall)
        }

        return (agentResponse.response, agentResponse.toolCalls)
    }
}


