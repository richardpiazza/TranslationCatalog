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
    
    private let fileManager = FileManager.default

    private var schemaVersion: SchemaVersion? {
        let url = medium.appending(path: Self.versionPath, directoryHint: .notDirectory)

        do {
            let data = try Data(contentsOf: url)
            let rawValue = try JSONDecoder.filesystem.decode(Int.self, from: data)
            return SchemaVersion(rawValue: rawValue)
        } catch {
            return nil
        }
    }

    public init(url: URL) throws {
        guard url.hasDirectoryPath else {
            throw URLError(.unsupportedURL)
        }

        medium = url
        if let schemaVersion {
            try migrateSchema(from: schemaVersion, to: .current)
            try loadDocuments()
        } else {
            try migrateSchema(from: .v1, to: .current)
            try loadDocuments()
        }
    }

    private func loadDocuments() throws {
        let translationUrls = try fileManager.contentsOfDirectory(at: try translationContainer, includingPropertiesForKeys: nil)
        try translationUrls.forEach {
            let data = try Data(contentsOf: $0)
            let translation = try JSONDecoder.filesystem.decode(TranslationDocument.self, from: data)
            translationDocuments.append(translation)
        }

        let expressionUrls = try fileManager.contentsOfDirectory(at: try expressionContainer, includingPropertiesForKeys: nil)
        try expressionUrls.forEach {
            let data = try Data(contentsOf: $0)
            let expression = try JSONDecoder.filesystem.decode(ExpressionDocument.self, from: data)
            expressionDocuments.append(expression)
        }

        let projectUrls = try fileManager.contentsOfDirectory(at: try projectContainer, includingPropertiesForKeys: nil)
        try projectUrls.forEach {
            let data = try Data(contentsOf: $0)
            let project = try JSONDecoder.filesystem.decode(ProjectDocument.self, from: data)
            projectDocuments.append(project)
        }
    }

    private func migrateSchema(from: SchemaVersion, to: SchemaVersion) throws {
        guard to != from else {
            // Migration complete
            return
        }

        guard to > from else {
            throw CocoaError(.featureUnsupported)
        }

        switch from {
        case .v1:
            var translations: [TranslationDocumentV1] = []
            let translationUrls = try fileManager.contentsOfDirectory(at: try translationContainer, includingPropertiesForKeys: nil)
            try translationUrls.forEach {
                let data = try Data(contentsOf: $0)
                let translation = try JSONDecoder.filesystem.decode(TranslationDocumentV1.self, from: data)
                translations.append(translation)
            }

            var expressions: [ExpressionDocumentV1] = []
            let expressionUrls = try fileManager.contentsOfDirectory(at: try expressionContainer, includingPropertiesForKeys: nil)
            try expressionUrls.forEach {
                let data = try Data(contentsOf: $0)
                let expression = try JSONDecoder.filesystem.decode(ExpressionDocumentV1.self, from: data)
                expressions.append(expression)
            }

            for expression in expressions {
                var translationDocuments = translations.filter { $0.expressionID == expression.id }
                let index = translationDocuments.firstIndex(where: {
                    $0.languageCode == expression.defaultLanguage &&
                        $0.scriptCode == nil &&
                        $0.regionCode == nil
                })

                var value: String = ""
                if let index {
                    let translation = translationDocuments.remove(at: index)
                    value = translation.value
                    try removeDocument(translation)
                }

                let document = ExpressionDocument(
                    id: expression.id,
                    key: expression.key,
                    name: expression.name,
                    defaultLanguage: expression.defaultLanguage,
                    defaultValue: value,
                    context: expression.context,
                    feature: expression.feature
                )

                try writeDocument(document)
            }

            try setSchemaVersion(.v2)
        case .v2:
            var translations: [TranslationDocumentV1] = []
            let translationUrls = try fileManager.contentsOfDirectory(at: try translationContainer, includingPropertiesForKeys: nil)
            try translationUrls.forEach {
                let data = try Data(contentsOf: $0)
                let translation = try JSONDecoder.filesystem.decode(TranslationDocumentV1.self, from: data)
                translations.append(translation)
            }

            for translation in translations {
                let document = TranslationDocument(
                    id: translation.id,
                    expressionID: translation.expressionID,
                    value: translation.value,
                    languageCode: translation.languageCode,
                    scriptCode: translation.scriptCode,
                    regionCode: translation.regionCode,
                    state: .needsReview
                )

                try writeDocument(document)
            }

            try setSchemaVersion(.v3)
        case .v3:
            return
        }

        guard let next = SchemaVersion(rawValue: from.rawValue + 1) else {
            throw CocoaError(.featureUnsupported)
        }

        try migrateSchema(from: next, to: to)
    }

    private func setSchemaVersion(_ version: SchemaVersion) throws {
        let url = medium.appending(path: Self.versionPath, directoryHint: .notDirectory)
        let data = try JSONEncoder.filesystem.encode(version.rawValue)
        try data.write(to: url)
    }
}
