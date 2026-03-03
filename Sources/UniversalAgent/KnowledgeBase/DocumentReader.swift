import Foundation
import PDFKit
import UniformTypeIdentifiers

public enum DocumentReaderError: Error {
    case unsupportedType
    case unreadableData
}

extension URL {
    fileprivate var detectedContentType: UTType? {
        (try? resourceValues(forKeys: [.contentTypeKey]))?.contentType
    }
}

public final class DocumentReader {
    public init() {}

    public func readText(from url: URL) throws -> String {
        guard let type = url.detectedContentType else {
            throw DocumentReaderError.unsupportedType
        }

        if type.conforms(to: .pdf) {
            return try readPDF(url: url)
        }

        if type.conforms(to: .plainText) || type.conforms(to: .utf8PlainText) {
            return try readPlainText(url: url)
        }

        // Fallback: try UTF‑8 text for other types (EPUB, DOC, etc. can be
        // handled here once you plug in dedicated parsers).
        let data = try Data(contentsOf: url)
        guard let text = String(data: data, encoding: .utf8) else {
            throw DocumentReaderError.unreadableData
        }

        return text
    }

    private func readPDF(url: URL) throws -> String {
        guard let document = PDFDocument(url: url) else {
            throw DocumentReaderError.unreadableData
        }

        var result = ""
        for index in 0 ..< document.pageCount {
            guard let page = document.page(at: index),
                  let pageText = page.string
            else { continue }
            result.append(pageText)
            result.append("\n\n")
        }
        return result
    }

    private func readPlainText(url: URL) throws -> String {
        let data = try Data(contentsOf: url)
        guard let text = String(data: data, encoding: .utf8) else {
            throw DocumentReaderError.unreadableData
        }
        return text
    }
}

