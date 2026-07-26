#if os(macOS) || os(iOS) || os(watchOS) || os(tvOS) || os(visionOS)
import Foundation
import TranslationCatalog

/// Implementation of `Catalog` that reads/writes data from/to a `FileWrapper` package.
public class FileWrapperCatalog: FilesystemContainer {

    let medium: FileWrapper
    let translationContainer: FileWrapper
    let expressionContainer: FileWrapper
    let projectContainer: FileWrapper
    var translationDocuments: [TranslationDocument] = []
    var expressionDocuments: [ExpressionDocument] = []
    var projectDocuments: [ProjectDocument] = []

    public init(fileWrapper: FileWrapper) throws {
        guard fileWrapper.isDirectory else {
            throw CocoaError(.fileReadUnsupportedScheme)
        }

        medium = fileWrapper
        translationContainer = fileWrapper.directory(forPath: Self.translationsPath)
        expressionContainer = fileWrapper.directory(forPath: Self.expressionsPath)
        projectContainer = fileWrapper.directory(forPath: Self.projectsPath)

        if let schemaVersion = getSchemaVersion() {
            try migrateSchema(from: schemaVersion, to: .current)
            try loadAllDocuments()
        } else {
            try migrateSchema(from: .v1, to: .current)
            try loadAllDocuments()
        }
    }

    /// Add all catalog content to the provided `FileWrapper`
    public func snapshot(to fileWrapper: FileWrapper, using encoder: JSONEncoder) throws {
        let translationsWrapper = fileWrapper.directory(forPath: Self.translationsPath)
        let expressionsWrapper = fileWrapper.directory(forPath: Self.expressionsPath)
        let projectsWrapper = fileWrapper.directory(forPath: Self.projectsPath)

        let existingTranslations = Set((translationsWrapper.fileWrappers ?? [:]).keys)
        let existingExpressions = Set((expressionsWrapper.fileWrappers ?? [:]).keys)
        let existingProjects = Set((projectsWrapper.fileWrappers ?? [:]).keys)

        let nextTranslations = Set(translationDocuments.map(\.filename))
        let nextExpressions = Set(expressionDocuments.map(\.filename))
        let nextProjects = Set(projectDocuments.map(\.filename))

        // Translations
        let addedTranslations = nextTranslations.subtracting(existingTranslations)
        let removedTranslations = existingTranslations.subtracting(nextTranslations)
        for filename in removedTranslations {
            if let wrapper = translationsWrapper.fileWrappers?[filename] {
                translationsWrapper.removeFileWrapper(wrapper)
            }
        }

        for document in translationDocuments {
            let data = try encoder.encode(document)
            if !addedTranslations.contains(document.filename) {
                if let wrapper = translationsWrapper.fileWrappers?[document.filename] {
                    translationsWrapper.removeFileWrapper(wrapper)
                }
            }
            translationsWrapper.addRegularFile(withContents: data, preferredFilename: document.filename)
        }

        // Expressions
        let addedExpressions = nextExpressions.subtracting(existingExpressions)
        let removedExpressions = existingExpressions.subtracting(nextExpressions)
        for filename in removedExpressions {
            if let wrapper = expressionsWrapper.fileWrappers?[filename] {
                expressionsWrapper.removeFileWrapper(wrapper)
            }
        }

        for document in expressionDocuments {
            let data = try encoder.encode(document)
            if !addedExpressions.contains(document.filename) {
                if let wrapper = expressionsWrapper.fileWrappers?[document.filename] {
                    expressionsWrapper.removeFileWrapper(wrapper)
                }
            }
            expressionsWrapper.addRegularFile(withContents: data, preferredFilename: document.filename)
        }

        // Projects
        let addedProjects = nextProjects.subtracting(existingProjects)
        let removedProjects = existingProjects.subtracting(nextProjects)
        for filename in removedProjects {
            if let wrapper = projectsWrapper.fileWrappers?[filename] {
                projectsWrapper.removeFileWrapper(wrapper)
            }
        }

        for document in projectDocuments {
            let data = try encoder.encode(document)
            if !addedProjects.contains(document.filename) {
                if let wrapper = projectsWrapper.fileWrappers?[document.filename] {
                    projectsWrapper.removeFileWrapper(wrapper)
                }
            }
            projectsWrapper.addRegularFile(withContents: data, preferredFilename: document.filename)
        }
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

        let data = try encoder.encode(document)
        try removeDocument(document)
        container.addRegularFile(withContents: data, preferredFilename: document.filename)
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

        guard let existing = container.fileWrappers?[document.filename] else {
            return
        }

        container.removeFileWrapper(existing)
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
#endif
