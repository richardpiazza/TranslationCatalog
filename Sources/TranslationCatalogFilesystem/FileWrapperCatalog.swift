import Foundation
import TranslationCatalog

/// Implementation of `Catalog` that reads/writes data from/to a `FileWrapper` package.
public class FileWrapperCatalog: FilesystemContainer {
    
    let medium: FileWrapper
    var translationDocuments: [TranslationDocument] = []
    var expressionDocuments: [ExpressionDocument] = []
    var projectDocuments: [ProjectDocument] = []
    
    private var schemaVersion: SchemaVersion? {
        guard let data = medium.fileWrappers?[Self.versionPath]?.regularFileContents else {
            return nil
        }
        
        do {
            let rawValue = try JSONDecoder.filesystem.decode(Int.self, from: data)
            return SchemaVersion(rawValue: rawValue)
        } catch {
            return nil
        }
    }
    
    public init(fileWrapper: FileWrapper) throws {
        guard fileWrapper.isDirectory else {
            throw CocoaError(.fileReadUnsupportedScheme)
        }
        
        medium = fileWrapper
        if let schemaVersion {
            try migrateSchema(from: schemaVersion, to: .current)
            try loadDocuments()
        } else {
            try migrateSchema(from: .v1, to: .current)
            try loadDocuments()
        }
    }
    
    private func loadDocuments() throws {
        try (translationContainer.fileWrappers ?? [:])
            .compactMapValues { $0.regularFileContents }
            .forEach { _, data in
                let document = try JSONDecoder.filesystem.decode(TranslationDocument.self, from: data)
                translationDocuments.append(document)
            }
        
        try (expressionContainer.fileWrappers ?? [:])
            .compactMapValues { $0.regularFileContents }
            .forEach { _, data in
                let document = try JSONDecoder.filesystem.decode(ExpressionDocument.self, from: data)
                expressionDocuments.append(document)
            }
        
        try (projectContainer.fileWrappers ?? [:])
            .compactMapValues { $0.regularFileContents }
            .forEach { _, data in
                let document = try JSONDecoder.filesystem.decode(ProjectDocument.self, from: data)
                projectDocuments.append(document)
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
            let translations = try (translationContainer.fileWrappers ?? [:])
                .compactMapValues { $0.regularFileContents }
                .compactMap { try JSONDecoder.filesystem.decode(TranslationDocumentV1.self, from: $0.value) }
            
            let expressions = try (expressionContainer.fileWrappers ?? [:])
                .compactMapValues { $0.regularFileContents }
                .compactMap { try JSONDecoder.filesystem.decode(ExpressionDocumentV1.self, from: $0.value) }
            
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
            let translations = try (translationContainer.fileWrappers ?? [:])
                .compactMapValues { $0.regularFileContents }
                .compactMap { try JSONDecoder.filesystem.decode(TranslationDocumentV1.self, from: $0.value) }
            
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
        if let wrapper = medium.fileWrappers?[Self.versionPath] {
            medium.removeFileWrapper(wrapper)
        }
        
        let data = try JSONEncoder.filesystem.encode(version.rawValue)
        medium.addRegularFile(withContents: data, preferredFilename: Self.versionPath)
    }
}
