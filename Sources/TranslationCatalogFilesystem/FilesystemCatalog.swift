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
        
        #if swift(>=5.7.1) && (os(macOS) || os(iOS) || os(tvOS) || os(watchOS))
        if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            translationsDirectory = directory.appending(path: "Translations", directoryHint: .isDirectory)
            expressionsDirectory = directory.appending(path: "Expressions", directoryHint: .isDirectory)
            projectsDirectory = directory.appending(path: "Projects", directoryHint: .isDirectory)
        } else {
            translationsDirectory = directory.appendingPathComponent("Translations", isDirectory: true)
            expressionsDirectory = directory.appendingPathComponent("Expressions", isDirectory: true)
            projectsDirectory = directory.appendingPathComponent("Projects", isDirectory: true)
        }
        #else
        translationsDirectory = directory.appendingPathComponent("Translations", isDirectory: true)
        expressionsDirectory = directory.appendingPathComponent("Expressions", isDirectory: true)
        projectsDirectory = directory.appendingPathComponent("Projects", isDirectory: true)
        #endif
        
        if !fileManager.fileExists(atPath: translationsDirectory.path) {
            try fileManager.createDirectory(at: translationsDirectory, withIntermediateDirectories: true)
        }
        if !fileManager.fileExists(atPath: expressionsDirectory.path) {
            try fileManager.createDirectory(at: expressionsDirectory, withIntermediateDirectories: true)
        }
        if !fileManager.fileExists(atPath: projectsDirectory.path) {
            try fileManager.createDirectory(at: projectsDirectory, withIntermediateDirectories: true)
        }
        
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
    
    // MARK: - Project
    
    public func projects() throws -> [Project] {
        try projectDocuments.map { document in
            let expressions = try document.expressionIds.map {
                try expression($0)
            }
            
            return Project(document: document, expressions: expressions)
        }
    }
    
    public func projects(matching query: CatalogQuery) throws -> [Project] {
        let documents: [ProjectDocument]
        
        switch query {
        case GenericProjectQuery.named(let name):
            documents = projectDocuments
                .filter { $0.name.lowercased().contains(name.lowercased()) }
        default:
            throw CatalogError.unhandledQuery(query)
        }
        
        return documents.map { Project(document: $0, expressions: []) }
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
            do {
                return try createExpression($0)
            } catch CatalogError.expressionID {
                return $0.id
            }
        }
        
        let id = project.id != .zero ? project.id : UUID()
        let document = ProjectDocument(
            id: id,
            name: project.name,
            expressionIds: expressionIds
        )
        
        try document.write(to: projectsDirectory, using: encoder)
        projectDocuments.append(document)
        return id
    }
    
    public func updateProject(_ id: Project.ID, action: CatalogUpdate) throws {
        guard let index = projectDocuments.firstIndex(where: { $0.id == id }) else {
            throw CatalogError.projectID(id)
        }
        
        switch action {
        case GenericProjectUpdate.name(let name):
            projectDocuments[index].name = name
        case GenericProjectUpdate.linkExpression(let expressionId):
            projectDocuments[index].expressionIds.append(expressionId)
        case GenericProjectUpdate.unlinkExpression(let expressionId):
            projectDocuments[index].expressionIds.removeAll(where: { $0 == expressionId })
        default:
            throw CatalogError.unhandledUpdate(action)
        }
        
        try projectDocuments[index].write(to: projectsDirectory, using: encoder)
    }
    
    public func deleteProject(_ id: Project.ID) throws {
        guard let index = projectDocuments.firstIndex(where: { $0.id == id }) else {
            throw CatalogError.projectID(id)
        }
        
        try projectDocuments[index].remove(from: projectsDirectory)
        projectDocuments.remove(at: index)
    }
    
    // MARK: - Expression
    
    public func expressions() throws -> [Expression] {
        expressionDocuments.map { document in
            let translations = translationDocuments
                .filter { $0.expressionID == document.id }
                .map {
                    Translation(document: $0)
                }
            
            return Expression(document: document, translations: translations)
        }
    }
    
    public func expressions(matching query: CatalogQuery) throws -> [Expression] {
        switch query {
        case GenericExpressionQuery.projectID(let projectId):
            return try project(projectId).expressions
        case GenericExpressionQuery.key(let key):
            return expressionDocuments
                .filter { $0.key.lowercased().contains(key.lowercased()) }
                .map { document in
                    let translations = translationDocuments
                        .filter { $0.expressionID == document.id }
                        .map {
                            Translation(document: $0)
                        }
                    
                    return Expression(document: document, translations: translations)
                }
        case GenericExpressionQuery.named(let name):
            return expressionDocuments
                .filter { $0.name.lowercased().contains(name.lowercased()) }
                .map { document in
                    let translations = translationDocuments
                        .filter { $0.expressionID == document.id }
                        .map {
                            Translation(document: $0)
                        }
                    
                    return Expression(document: document, translations: translations)
                }
        case GenericExpressionQuery.translationsHavingOnly(let languageCode):
            // TODO: Find a better/optimized way of doing this
            var expressions = try self.expressions()
            var index = expressions.count - 1
            while index >= 0 {
                let expression = expressions[index]
                if !expression.translations.contains(where: {
                    $0.languageCode == languageCode &&
                    $0.scriptCode == nil &&
                    $0.regionCode == nil
                }) {
                    expressions.remove(at: index)
                }
                
                index -= 1
            }
            return expressions
        case GenericExpressionQuery.translationsHaving(let languageCode, let scriptCode, let regionCode):
            // TODO: Find a better/optimized way of doing this
            var expressions = try self.expressions()
            var index = expressions.count - 1
            while index >= 0 {
                let expression = expressions[index]
                if !expression.translations.contains(where: {
                    $0.languageCode == languageCode &&
                    $0.scriptCode == scriptCode &&
                    $0.regionCode == regionCode
                }) {
                    expressions.remove(at: index)
                }
                
                index -= 1
            }
            return expressions
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
        
        let translations = translationDocuments
            .filter { $0.expressionID == document.id }
            .map {
                Translation(document: $0)
            }
        
        return Expression(document: document, translations: translations)
    }
    
    public func createExpression(_ expression: Expression) throws -> Expression.ID {
        if expression.id != .zero {
            if let existing = try? self.expression(expression.id) {
                throw CatalogError.expressionID(existing.id)
            }
        }
        
        if let existing = try? self.expression(matching: GenericExpressionQuery.key(expression.key)) {
            throw CatalogError.expressionExistingWithKey(expression.key, existing)
        }
        
        let id = expression.id != .zero ? expression.id : UUID()
        let translations = expression.translations.map {
            Translation(
                uuid: $0.id,
                expressionID: id,
                languageCode: $0.languageCode,
                scriptCode: $0.scriptCode,
                regionCode: $0.regionCode,
                value: $0.value
            )
        }
        
        let _ = try translations.map {
            try createTranslation($0)
        }
        
        let document = ExpressionDocument(
            id: id,
            key: expression.key,
            name: expression.name,
            defaultLanguage: expression.defaultLanguage,
            context: expression.context,
            feature: expression.feature
        )
        
        try document.write(to: expressionsDirectory, using: encoder)
        expressionDocuments.append(document)
        return id
    }
    
    public func updateExpression(_ id: Expression.ID, action: CatalogUpdate) throws {
        guard let index = expressionDocuments.firstIndex(where: { $0.id == id }) else {
            throw CatalogError.expressionID(id)
        }
        
        switch action {
        case GenericExpressionUpdate.key(let key):
            expressionDocuments[index].key = key
        case GenericExpressionUpdate.name(let name):
            expressionDocuments[index].name = name
        case GenericExpressionUpdate.context(let context):
            expressionDocuments[index].context = context
        case GenericExpressionUpdate.feature(let feature):
            expressionDocuments[index].feature = feature
        case GenericExpressionUpdate.defaultLanguage(let languageCode):
            expressionDocuments[index].defaultLanguage = languageCode
        default:
            throw CatalogError.unhandledUpdate(action)
        }
        
        try expressionDocuments[index].write(to: expressionsDirectory, using: encoder)
    }
    
    public func deleteExpression(_ id: Expression.ID) throws {
        guard let index = expressionDocuments.firstIndex(where: { $0.id == id }) else {
            throw CatalogError.expressionID(id)
        }
        
        let translationIds = translationDocuments
            .filter { $0.expressionID == id }
            .map { $0.id }
        
        try translationIds.forEach { translationId in
            guard let idx = translationDocuments.firstIndex(where: { $0.id == translationId }) else {
                return
            }
            
            try translationDocuments[idx].remove(from: translationsDirectory)
            translationDocuments.remove(at: idx)
        }
        
        let projectIds = projectDocuments
            .filter { $0.expressionIds.contains(id) }
            .map { $0.id }
        
        try projectIds.forEach { projectId in
            guard let idx = projectDocuments.firstIndex(where: { $0.id == projectId }) else {
                return
            }
            
            projectDocuments[idx].expressionIds.removeAll(where: { $0 == id })
            try projectDocuments[idx].write(to: projectsDirectory, using: encoder)
        }
        
        try expressionDocuments[index].remove(from: expressionsDirectory)
        expressionDocuments.remove(at: index)
    }
    
    // MARK: - Translation
    
    public func translations() throws -> [Translation] {
        translationDocuments.map { document in
            Translation(document: document)
        }
    }
    
    public func translations(matching query: CatalogQuery) throws -> [Translation] {
        var documents: [TranslationDocument]
        
        switch query {
        case GenericTranslationQuery.expressionID(let expressionId):
            documents = translationDocuments
                .filter { $0.expressionID == expressionId }
        case GenericTranslationQuery.havingOnly(let expressionId, let languageCode):
            documents = translationDocuments
                .filter {
                    $0.expressionID == expressionId &&
                    $0.languageCode == languageCode &&
                    $0.scriptCode == nil &&
                    $0.regionCode == nil
                }
        case GenericTranslationQuery.having(let expressionId, let languageCode, let scriptCode, let regionCode):
            documents = translationDocuments
                .filter {
                    $0.expressionID == expressionId &&
                    $0.languageCode == languageCode
                }
            
            if let scriptCode = scriptCode {
                documents.removeAll(where: { $0.scriptCode != scriptCode })
            }
            if let regionCode = regionCode {
                documents.removeAll(where: { $0.regionCode != regionCode })
            }
        default:
            throw CatalogError.unhandledQuery(query)
        }
        
        return documents.map { Translation(document: $0) }
    }
    
    public func translation(_ id: Translation.ID) throws -> Translation {
        try translation(matching: GenericTranslationQuery.id(id))
    }
    
    public func translation(matching query: CatalogQuery) throws -> Translation {
        switch query {
        case GenericTranslationQuery.id(let uuid):
            guard let document = translationDocuments.first(where: { $0.id == uuid }) else {
                throw CatalogError.translationID(uuid)
            }
            
            return Translation(document: document)
        case GenericTranslationQuery.having(let expressionId, let languageCode, let scriptCode, let regionCode):
            guard let document = translationDocuments.first(where: {
                $0.expressionID == expressionId &&
                $0.languageCode == languageCode &&
                $0.scriptCode == scriptCode &&
                $0.regionCode == regionCode
            }) else {
                throw CatalogError.badQuery(query)
            }
            
            return Translation(document: document)
        default:
            throw CatalogError.unhandledQuery(query)
        }
    }
    
    public func createTranslation(_ translation: Translation) throws -> Translation.ID {
        if translation.id != .zero {
            if let existing = try? self.translation(translation.id) {
                throw CatalogError.translationID(existing.id)
            }
        }
        
        let query = GenericTranslationQuery.having(translation.expressionID, translation.languageCode, translation.scriptCode, translation.regionCode)
        if let existing = try? self.translation(matching: query) {
            throw CatalogError.translationExistingWithValue(translation.value, existing)
        }
        
        let id = translation.id != .zero ? translation.id : UUID()
        let document = TranslationDocument(
            id: id,
            expressionID: translation.expressionID,
            languageCode: translation.languageCode,
            scriptCode: translation.scriptCode,
            regionCode: translation.regionCode,
            value: translation.value
        )
        
        try document.write(to: translationsDirectory, using: encoder)
        translationDocuments.append(document)
        return id
    }
    
    public func updateTranslation(_ id: Translation.ID, action: CatalogUpdate) throws {
        guard let index = translationDocuments.firstIndex(where: { $0.id == id }) else {
            throw CatalogError.translationID(id)
        }
        
        switch action {
        case GenericTranslationUpdate.language(let languageCode):
            translationDocuments[index].languageCode = languageCode
        case GenericTranslationUpdate.script(let scriptCode):
            translationDocuments[index].scriptCode = scriptCode
        case GenericTranslationUpdate.region(let regionCode):
            translationDocuments[index].regionCode = regionCode
        case GenericTranslationUpdate.value(let value):
            translationDocuments[index].value = value
        default:
            throw CatalogError.unhandledUpdate(action)
        }
        
        try translationDocuments[index].write(to: translationsDirectory, using: encoder)
    }
    
    public func deleteTranslation(_ id: Translation.ID) throws {
        guard let index = translationDocuments.firstIndex(where: { $0.id == id }) else {
            throw CatalogError.translationID(id)
        }
        
        try translationDocuments[index].remove(from: translationsDirectory)
        translationDocuments.remove(at: index)
    }
}
