import Foundation

public final class RAGService {
    private let documentReader: DocumentReader
    private let embeddingBackend: (any EmbeddingBackend)?
    private let vectorStore: InMemoryVectorStore?

    public init(
        documentReader: DocumentReader = DocumentReader(),
        embeddingBackend: (any EmbeddingBackend)? = nil,
        vectorStore: InMemoryVectorStore? = nil
    ) {
        self.documentReader = documentReader
        self.embeddingBackend = embeddingBackend
        self.vectorStore = vectorStore
    }

    public func retrieveRelevantContent(
        from folderURL: URL,
        query: String
    ) async throws -> String {
        let urls = try FileManager.default.contentsOfDirectory(
            at: folderURL,
            includingPropertiesForKeys: nil
        )

        // Ako imamo embeddings + vector store, koristi ih.
        if let embeddingBackend, let vectorStore {
            return try await retrieveWithEmbeddings(
                urls: urls,
                query: query,
                embeddingBackend: embeddingBackend,
                vectorStore: vectorStore
            )
        }

        // Fallback: jednostavno konkateniraj sve tekstove.
        var relevantText = ""

        for url in urls {
            let text = try documentReader.readText(from: url)
            relevantText += "Document \(url.lastPathComponent):\n"
            relevantText += text
            relevantText += "\n\n"
        }

        return relevantText
    }

    private func retrieveWithEmbeddings(
        urls: [URL],
        query: String,
        embeddingBackend: any EmbeddingBackend,
        vectorStore: InMemoryVectorStore
    ) async throws -> String {
        vectorStore.clear()

        var texts: [String] = []
        var metadataList: [[String: String]] = []

        for url in urls {
            let text = try documentReader.readText(from: url)
            texts.append(text)
            metadataList.append([
                "filename": url.lastPathComponent
            ])
        }

        guard texts.isEmpty == false else {
            return ""
        }

        let documentEmbeddings = try await embeddingBackend.embed(texts: texts)

        var items: [VectorItem] = []
        for index in 0 ..< documentEmbeddings.count {
            let embedding = documentEmbeddings[index]
            let text = texts[index]
            let metadata = metadataList[index]

            let item = VectorItem(
                id: UUID(),
                text: text,
                metadata: metadata,
                embedding: embedding
            )
            items.append(item)
        }

        vectorStore.add(items)

        let queryEmbeddingArray = try await embeddingBackend.embed(texts: [query])
        guard let queryEmbedding = queryEmbeddingArray.first else {
            return ""
        }

        let topItems = vectorStore.topK(similarTo: queryEmbedding, k: 5)

        var result = ""
        for item in topItems {
            let filename = item.metadata["filename"] ?? "Document"
            result += "Document \(filename):\n"
            result += item.text
            result += "\n\n"
        }

        return result
    }
}

