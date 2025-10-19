import Foundation
import TranslationCatalog

@available(*, deprecated, renamed: "DirectoryCatalog")
public typealias FilesystemCatalog = DirectoryCatalog

/// Implementation of `Catalog` the reads/writes data from/to a filesystem directory.
public class DirectoryCatalog: FilesystemContainer {

    let medium: URL
    var translationDocuments: [TranslationDocument] = []
    var expressionDocuments: [ExpressionDocument] = []
    var projectDocuments: [ProjectDocument] = []

    var translationContainer: URL {
        guard let url = try? directory(forPath: Self.translationsPath) else {
            preconditionFailure("Invalid Translation Directory")
        }

        return url
    }

    var expressionContainer: URL {
        guard let url = try? directory(forPath: Self.expressionsPath) else {
            preconditionFailure("Invalid Expression Directory")
        }

        return url
    }

    var projectContainer: URL {
        guard let url = try? directory(forPath: Self.projectsPath) else {
            preconditionFailure("")
        }

        return url
    }

    private let fileManager = FileManager.default

    public init(url: URL) throws {
        guard url.hasDirectoryPath else {
            throw URLError(.unsupportedURL)
        }

        medium = url
        if let schemaVersion = getSchemaVersion() {
            try migrateSchema(from: schemaVersion, to: .current)
            try loadAllDocuments()
        } else {
            try migrateSchema(from: .v1, to: .current)
            try loadAllDocuments()
        }
    }

    private func directory(forPath path: String) throws -> URL {
        let url = medium.appending(path: path, directoryHint: .isDirectory)
        if !fileManager.fileExists(atPath: url.path()) {
            try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
        }
        return url
    }

    func loadDocuments<T: Document>(from container: URL, using decoder: JSONDecoder) throws -> [T] {
        try fileManager
            .contentsOfDirectory(at: container, includingPropertiesForKeys: nil)
            .map { try Data(contentsOf: $0) }
            .map { try decoder.decode(T.self, from: $0) }
    }

    func writeDocument(_ document: any Document, using encoder: JSONEncoder) throws {
        let container = switch document {
        case is TranslationDocument:
            translationContainer
        case is ExpressionDocument:
            expressionContainer
        case is ProjectDocument:
            projectContainer
        default:
            throw CocoaError(.fileWriteUnsupportedScheme)
        }

        try document.write(to: container, using: encoder)
    }

    func removeDocument(_ document: any Document) throws {
        let container = switch document {
        case is TranslationDocument, is TranslationDocumentV1:
            translationContainer
        case is ExpressionDocument, is ExpressionDocumentV1:
            expressionContainer
        case is ProjectDocument:
            projectContainer
        default:
            throw CocoaError(.fileWriteUnsupportedScheme)
        }

        try document.remove(from: container)
    }

    func getSchemaVersion(using decoder: JSONDecoder) -> DocumentSchemaVersion? {
        let url = medium.appending(path: Self.versionPath, directoryHint: .notDirectory)

        do {
            let data = try Data(contentsOf: url)
            let rawValue = try decoder.decode(Int.self, from: data)
            return DocumentSchemaVersion(rawValue: rawValue)
        } catch {
            return nil
        }
    }

    func setSchemaVersion(_ version: DocumentSchemaVersion, using encoder: JSONEncoder) throws {
        let url = medium.appending(path: Self.versionPath, directoryHint: .notDirectory)
        let data = try encoder.encode(version.rawValue)
        try data.write(to: url)
    }
}
