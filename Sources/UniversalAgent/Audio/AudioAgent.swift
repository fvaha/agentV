import Foundation
import AnyCodable

public enum AudioToolNames {
    public static let transcribeAudio = "transcribe_audio"
    public static let synthesizeAudio = "synthesize_audio"
}

public final class AudioAgent {
    public let agent: UniversalAgent
    private let audioBackend: any AudioBackend

    public init(
        llmClient: some LLMClient,
        audioBackend: some AudioBackend = WhisperClient()
    ) {
        self.audioBackend = audioBackend

        let tools: [Tool] = [
            Tool(
                name: AudioToolNames.transcribeAudio,
                description: "Transcribe audio from a URL into text.",
                arguments: [
                    "url": .string
                ]
            ),
            Tool(
                name: AudioToolNames.synthesizeAudio,
                description: "Synthesize spoken audio from the given text.",
                arguments: [
                    "text": .string
                ]
            )
        ]

        let handlers: [String: ToolHandler] = [
            AudioToolNames.transcribeAudio: { [audioBackend] call, context in
                guard
                    let anyURL = call.arguments["url"],
                    let urlString = anyURL.value as? String,
                    let url = URL(string: urlString)
                else { return }

                let data = try Data(contentsOf: url)
                let text = try await audioBackend.transcribe(audio: data)
                context["last_transcription"] = text
            },
            AudioToolNames.synthesizeAudio: { [audioBackend] call, context in
                guard
                    let anyText = call.arguments["text"],
                    let text = anyText.value as? String
                else { return }

                let audioData = try await audioBackend.synthesize(text: text)
                context["last_synthesized_audio_length"] = "\(audioData.count)"
            }
        ]

        self.agent = UniversalAgent(
            llmClient: llmClient,
            tools: tools,
            toolHandlers: handlers
        )
    }
}

