import Foundation
import AnyCodable

public enum ImageToolNames {
    public static let analyzeImage = "analyze_image"
}

public final class VisionAgent {
    public let agent: UniversalAgent
    private let visionBackend: any VisionBackend

    public init(
        llmClient: some LLMClient,
        visionBackend: some VisionBackend = ImageService()
    ) {
        self.visionBackend = visionBackend

        let tools: [Tool] = [
            Tool(
                name: ImageToolNames.analyzeImage,
                description: "Analyze an image from a URL and return a description.",
                arguments: [
                    "url": .string
                ]
            )
        ]

        let handlers: [String: ToolHandler] = [
            ImageToolNames.analyzeImage: { [visionBackend] call, context in
                guard
                    let anyURL = call.arguments["url"],
                    let urlString = anyURL.value as? String,
                    let url = URL(string: urlString)
                else { return }

                let data = try Data(contentsOf: url)
                let description = try await visionBackend.analyzeImage(data: data)
                context["last_image_description"] = description
            }
        ]

        self.agent = UniversalAgent(
            llmClient: llmClient,
            tools: tools,
            toolHandlers: handlers
        )
    }
}

