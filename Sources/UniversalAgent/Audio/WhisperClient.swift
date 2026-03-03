import Foundation

public final class WhisperClient: AudioBackend {
    public init() {}

    public func transcribe(audio data: Data) async throws -> String {
        // TODO: Zameni ovo pravim Whisper‑iOS klijentom.
        return "Transcribed text from audio (stub)."
    }

    public func synthesize(text: String) async throws -> Data {
        // TODO: Zameni ovo pravim TTS modelom ili AVSpeechSynthesizer‑om.
        return Data()
    }
}

