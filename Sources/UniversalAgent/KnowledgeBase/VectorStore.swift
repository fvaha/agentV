import Foundation

public struct VectorItem: Sendable {
    public let id: UUID
    public let text: String
    public let metadata: [String: String]
    public let embedding: [Float]
}

public final class InMemoryVectorStore: @unchecked Sendable {
    private var items: [VectorItem] = []

    public init() {}

    public func clear() {
        items.removeAll()
    }

    public func add(_ newItems: [VectorItem]) {
        items.append(contentsOf: newItems)
    }

    public func topK(
        similarTo queryEmbedding: [Float],
        k: Int
    ) -> [VectorItem] {
        guard queryEmbedding.isEmpty == false else { return [] }

        return items
            .map { item in
                (item, cosineSimilarity(queryEmbedding, item.embedding))
            }
            .sorted { $0.1 > $1.1 }
            .prefix(k)
            .map { $0.0 }
    }

    private func cosineSimilarity(_ a: [Float], _ b: [Float]) -> Float {
        let count = min(a.count, b.count)
        guard count > 0 else { return 0 }

        var dot: Float = 0
        var normA: Float = 0
        var normB: Float = 0

        for i in 0 ..< count {
            dot += a[i] * b[i]
            normA += a[i] * a[i]
            normB += b[i] * b[i]
        }

        guard normA > 0, normB > 0 else { return 0 }
        return dot / (sqrt(normA) * sqrt(normB))
    }
}

