import Foundation
import LocaleSupport
import TranslationCatalog

/// Implementation of `Catalog` the reads/writes data from/to a filesystem directory.
public class FilesystemCatalog: Catalog {
    
    private let fileManager = FileManager.default
    private let decoder: JSONDecoder = JSONDecoder()
    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
        return encoder
    }()
    
    private let directory: URL
    private let translationsDirectory: URL
    private let expressionsDirectory: URL
    private let projectsDirectory: URL
    
    private var translationDocuments: [TranslationDocument] = []
    private var expressionDocuments: [ExpressionDocument] = []
    private var projectDocuments: [ProjectDocument] = []
    
    public init(url: URL) throws {
        guard url.hasDirectoryPath else {
            throw URLError(.unsupportedURL)
        }
        
        directory = url
        
        if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            translationsDirectory = directory.appending(path: "Translations", directoryHint: .isDirectory)
            expressionsDirectory = directory.appending(path: "Expressions", directoryHint: .isDirectory)
            projectsDirectory = directory.appending(path: "Projects", directoryHint: .isDirectory)
        } else {
            translationsDirectory = directory.appendingPathComponent("Translations", isDirectory: true)
            expressionsDirectory = directory.appendingPathComponent("Expressions", isDirectory: true)
            projectsDirectory = directory.appendingPathComponent("Projects", isDirectory: true)
        }
        
        try fileManager.createDirectory(at: translationsDirectory, withIntermediateDirectories: true)
        try fileManager.createDirectory(at: expressionsDirectory, withIntermediateDirectories: true)
        try fileManager.createDirectory(at: projectsDirectory, withIntermediateDirectories: true)
        
        let translationUrls = try fileManager.contentsOfDirectory(at: translationsDirectory, includingPropertiesForKeys: nil)
        try translationUrls.forEach {
            let data = try Data(contentsOf: $0)
            let translation = try decoder.decode(TranslationDocument.self, from: data)
            translationDocuments.append(translation)
        }
        
        let expressionUrls = try fileManager.contentsOfDirectory(at: expressionsDirectory, includingPropertiesForKeys: nil)
        try expressionUrls.forEach {
            let data = try Data(contentsOf: $0)
            let expression = try decoder.decode(ExpressionDocument.self, from: data)
            expressionDocuments.append(expression)
        }
        
        let projectUrls = try fileManager.contentsOfDirectory(at: projectsDirectory, includingPropertiesForKeys: nil)
        try projectUrls.forEach {
            let data = try Data(contentsOf: $0)
            let project = try decoder.decode(ProjectDocument.self, from: data)
            projectDocuments.append(project)
        }
    }
    
    public func projects() throws -> [Project] {
        try projectDocuments.map { document in
            let expressions = try document.expressionIds.map {
                try expression($0)
            }
            
            return Project(document: document, expressions: expressions)
        }
    }
    
    public func projects(matching query: CatalogQuery) throws -> [Project] {
        throw CatalogError.unhandledQuery(query)
    }
    
    public func project(_ id: Project.ID) throws -> Project {
        try project(matching: GenericProjectQuery.id(id))
    }
    
    public func project(matching query: CatalogQuery) throws -> Project {
        let document: ProjectDocument
        
        switch query {
        case GenericProjectQuery.id(let uuid):
            guard let doc = projectDocuments.first(where: { $0.id == uuid }) else {
                throw CatalogError.projectID(uuid)
            }
            
            document = doc
        case GenericProjectQuery.named(let name):
            guard let doc = projectDocuments.first(where: { $0.name == name }) else {
                throw CatalogError.badQuery(query)
            }
            
            document = doc
        default:
            throw CatalogError.unhandledQuery(query)
        }
        
        let expressions = try document.expressionIds.map {
            try expression($0)
        }
        
        return Project(document: document, expressions: expressions)
    }
    
    public func createProject(_ project: Project) throws -> Project.ID {
        if project.id != .zero {
            if let existing = try? self.project(project.id) {
                throw CatalogError.projectID(existing.id)
            }
        }
        
        let expressionIds = try project.expressions.map {
            try createExpression($0)
        }
        
        let id = project.id != .zero ? project.id : UUID()
        let document = ProjectDocument(
            id: id,
            name: project.name,
            expressionIds: expressionIds
        )
        
        try document.write(to: projectsDirectory, using: encoder)
        return id
    }
    
    public func updateProject(_ id: Project.ID, action: CatalogUpdate) throws {
        preconditionFailure()
    }
    
    public func deleteProject(_ id: Project.ID) throws {
        guard let index = projectDocuments.firstIndex(where: { $0.id == id }) else {
            throw CatalogError.projectID(id)
        }
        
        try projectDocuments[index].remove(from: projectsDirectory)
        projectDocuments.remove(at: index)
    }
    
    public func expressions() throws -> [Expression] {
        try expressionDocuments.map { document in
            let translations = try document.translationIds.map {
                try translation($0)
            }
            
            return Expression(document: document, translations: translations)
        }
    }
    
    public func expressions(matching query: CatalogQuery) throws -> [Expression] {
        switch query {
        case GenericExpressionQuery.projectID(let projectId):
            return try project(projectId).expressions
        case GenericExpressionQuery.key(let key):
            return try expressionDocuments
                .filter { $0.key == key }
                .map { document in
                    let translations = try document.translationIds.map {
                        try translation($0)
                    }
                    
                    return Expression(document: document, translations: translations)
                }
        case GenericExpressionQuery.named(let name):
            return try expressionDocuments
                .filter { $0.name == name }
                .map { document in
                    let translations = try document.translationIds.map {
                        try translation($0)
                    }
                    
                    return Expression(document: document, translations: translations)
                }
        default:
            throw CatalogError.unhandledQuery(query)
        }
    }
    
    public func expression(_ id: Expression.ID) throws -> Expression {
        try expression(matching: GenericExpressionQuery.id(id))
    }
    
    public func expression(matching query: CatalogQuery) throws -> Expression {
        let document: ExpressionDocument
        
        switch query {
        case GenericExpressionQuery.id(let uuid):
            guard let doc = expressionDocuments.first(where: { $0.id == uuid }) else {
                throw CatalogError.expressionID(uuid)
            }
            
            document = doc
        case GenericExpressionQuery.key(let key):
            guard let doc = expressionDocuments.first(where: { $0.key == key }) else {
                throw CatalogError.badQuery(query)
            }
            
            document = doc
        default:
            throw CatalogError.unhandledQuery(query)
        }
        
        let translations = try document.translationIds.map {
            try translation($0)
        }
        
        return Expression(document: document, translations: translations)
    }
    
    public func createExpression(_ expression: Expression) throws -> Expression.ID {
        preconditionFailure()
    }
    
    public func updateExpression(_ id: Expression.ID, action: CatalogUpdate) throws {
        preconditionFailure()
    }
    
    public func deleteExpression(_ id: Expression.ID) throws {
        preconditionFailure()
    }
    
    public func translations() throws -> [Translation] {
        translationDocuments.map { document in
            Translation(document: document)
        }
    }
    
    public func translations(matching query: CatalogQuery) throws -> [Translation] {
        switch query {
        case GenericTranslationQuery.expressionID(let expressionId):
            return translationDocuments
                .filter { $0.expressionID == expressionId }
                .map { Translation(document: $0) }
        case GenericTranslationQuery.havingOnly(let expressionId, let languageCode):
            return translationDocuments
                .filter {
                    $0.expressionID == expressionId &&
                    $0.languageCode == languageCode &&
                    $0.scriptCode == nil &&
                    $0.regionCode == nil
                }
                .map { Translation(document: $0) }
        case GenericTranslationQuery.having(let expressionId, let languageCode, let scriptCode, let regionCode):
            var documents = translationDocuments.filter { $0.expressionID == expressionId && $0.languageCode == languageCode }
            if let scriptCode = scriptCode {
                documents.removeAll(where: { $0.scriptCode != scriptCode })
            }
            if let regionCode = regionCode {
                documents.removeAll(where: { $0.regionCode != regionCode })
            }
            return documents.map { Translation(document: $0) }
        default:
            throw CatalogError.unhandledQuery(query)
        }
    }
    
    public func translation(_ id: Translation.ID) throws -> Translation {
        try translation(matching: GenericTranslationQuery.id(id))
    }
    
    public func translation(matching query: CatalogQuery) throws -> Translation {
        let document: TranslationDocument
        
        switch query {
        case GenericTranslationQuery.id(let uuid):
            guard let doc = translationDocuments.first(where: { $0.id == uuid }) else {
                throw CatalogError.translationID(uuid)
            }
            
            document = doc
        default:
            throw CatalogError.unhandledQuery(query)
        }
        
        return Translation(document: document)
    }
    
    public func createTranslation(_ translation: Translation) throws -> Translation.ID {
        preconditionFailure()
    }
    
    public func updateTranslation(_ id: Translation.ID, action: CatalogUpdate) throws {
        preconditionFailure()
    }
    
    public func deleteTranslation(_ id: Translation.ID) throws {
        preconditionFailure()
    }
}
