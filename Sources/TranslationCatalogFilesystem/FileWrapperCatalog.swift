import Foundation
import TranslationCatalog

/// Implementation of `Catalog` that reads/writes data from/to a `FileWrapper` package.
public class FileWrapperCatalog: FilesystemContainer {

    let medium: FileWrapper
    var translationDocuments: [TranslationDocument] = []
    var expressionDocuments: [ExpressionDocument] = []
    var projectDocuments: [ProjectDocument] = []

    var translationContainer: FileWrapper {
        directory(forPath: Self.translationsPath)
    }

    var expressionContainer: FileWrapper {
        directory(forPath: Self.expressionsPath)
    }

    var projectContainer: FileWrapper {
        directory(forPath: Self.projectsPath)
    }

    public init(fileWrapper: FileWrapper) throws {
        guard fileWrapper.isDirectory else {
            throw CocoaError(.fileReadUnsupportedScheme)
        }

        medium = fileWrapper
        if let schemaVersion = getSchemaVersion() {
            try migrateSchema(from: schemaVersion, to: .current)
            try loadAllDocuments()
        } else {
            try migrateSchema(from: .v1, to: .current)
            try loadAllDocuments()
        }
    }

    private func directory(forPath path: String) -> FileWrapper {
        guard let wrapper = medium.fileWrappers?[path] else {
            let directoryWrapper = FileWrapper(directoryWithFileWrappers: [:])
            directoryWrapper.preferredFilename = path
            medium.addFileWrapper(directoryWrapper)
            return directoryWrapper
        }

        return wrapper
    }

    func loadDocuments<T: Document>(from container: FileWrapper, using decoder: JSONDecoder) throws -> [T] {
        try (container.fileWrappers ?? [:])
            .compactMapValues { $0.regularFileContents }
            .map { try decoder.decode(T.self, from: $0.value) }
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
        guard let data = medium.fileWrappers?[Self.versionPath]?.regularFileContents else {
            return nil
        }

        do {
            let rawValue = try decoder.decode(Int.self, from: data)
            return DocumentSchemaVersion(rawValue: rawValue)
        } catch {
            return nil
        }
    }

    func setSchemaVersion(_ version: DocumentSchemaVersion, using encoder: JSONEncoder) throws {
        if let wrapper = medium.fileWrappers?[Self.versionPath] {
            medium.removeFileWrapper(wrapper)
        }

        let data = try encoder.encode(version.rawValue)
        medium.addRegularFile(withContents: data, preferredFilename: Self.versionPath)
    }
}
