import Foundation
import AnyCodable

public enum EducationToolNames {
    public static let loadFromFolder = "load_documents_from_folder"
}

public final class EducationAgent {
    public let agent: UniversalAgent
    private let ragService: RAGService

    public init(
        llmClient: some LLMClient,
        ragService: RAGService = RAGService()
    ) {
        self.ragService = ragService

        let tools: [Tool] = [
            Tool(
                name: EducationToolNames.loadFromFolder,
                description: "Load and summarize documents from a local folder for use as learning material.",
                arguments: [
                    "folder_path": .string,
                    "query": .string
                ]
            )
        ]

        let handlers: [String: ToolHandler] = [
            EducationToolNames.loadFromFolder: { [ragService] call, context in
                guard
                    let anyFolder = call.arguments["folder_path"],
                    let folderPath = anyFolder.value as? String
                else { return }

                let query = (call.arguments["query"]?.value as? String) ?? ""
                let folderURL = URL(fileURLWithPath: folderPath)
                let text = try await ragService.retrieveRelevantContent(from: folderURL, query: query)

                context["kb_query"] = query
                context["kb_documents"] = text
            }
        ]

        self.agent = UniversalAgent(
            llmClient: llmClient,
            tools: tools,
            toolHandlers: handlers
        )
    }
}

