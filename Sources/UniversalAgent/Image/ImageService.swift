import Foundation

public final class ImageService: VisionBackend {
    public init() {}

    public func analyzeImage(data: Data) async throws -> String {
        // TODO: Zameni ovo pravim multimodalnim LLM‑om (slika + tekst).
        return "Image description (stub)."
    }
}

