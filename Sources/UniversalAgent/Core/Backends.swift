import Foundation

// MARK: - Pluggable backends (LLM‑agnostic)

public protocol AudioBackend: Sendable {
    func transcribe(audio data: Data) async throws -> String
    func synthesize(text: String) async throws -> Data
}

public protocol VisionBackend: Sendable {
    func analyzeImage(data: Data) async throws -> String
}

public protocol EmbeddingBackend: Sendable {
    /// Returns one embedding vector per input text.
    func embed(texts: [String]) async throws -> [[Float]]
}

