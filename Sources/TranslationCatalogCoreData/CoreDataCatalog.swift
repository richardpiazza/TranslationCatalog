#if canImport(CoreData)
import CoreData
import CoreDataPlus
import Foundation
import LocaleSupport
import TranslationCatalog

public class CoreDataCatalog: TranslationCatalog.Catalog {

    private let container: CatalogContainer<ManagedModel>
    private var viewContext: NSManagedObjectContext { container.persistentContainer.viewContext }

    /// Initialize a CoreData powered catalog using 'in-memory' persistence.
    ///
    /// This does not persist any data once de-initialized. If persistence beyond the life
    /// of the instance is required, provide a URL where a store can be created.
    public init() throws {
        container = try CatalogContainer(
            version: .v2,
            persistence: .memory,
            name: "CatalogModel"
        )
    }

    /// Initialize a CoreData powered catalog backed by a SQLite container.
    public init(url: URL) throws {
        guard let storeURL = StoreURL(rawValue: url) else {
            preconditionFailure("Unable to initialize StoreURL with '\(url)'.")
        }

        container = try CatalogContainer(
            version: .v2,
            persistence: .store(storeURL),
            name: "CatalogModel",
            silentMigration: false
        )
        
        try migrateDefaultExpressionValues()
    }

    public func projects() throws -> [TranslationCatalog.Project] {
        try viewContext
            .performAndWait {
                try viewContext
                    .fetch(ProjectEntity.fetchRequest())
                    .map {
                        try TranslationCatalog.Project($0)
                    }
            }
    }

    public func projects(matching query: any TranslationCatalog.CatalogQuery) throws -> [TranslationCatalog.Project] {
        let request = ProjectEntity.fetchRequest()

        switch query {
        case GenericProjectQuery.named(let named):
            request.predicate = NSPredicate(format: "%K CONTAINS[cd] %@", "name", named)
        case GenericProjectQuery.expressionId(let expressionId):
            request.predicate = NSPredicate(format: "ANY %K == %@", argumentArray: ["expressionEntities.id", expressionId])
        default:
            throw CatalogError.unhandledQuery(query)
        }

        return try viewContext.performAndWait {
            try viewContext
                .fetch(request)
                .map {
                    try TranslationCatalog.Project($0)
                }
        }
    }

    public func project(_ id: TranslationCatalog.Project.ID) throws -> TranslationCatalog.Project {
        try project(matching: GenericProjectQuery.id(id))
    }

    public func project(matching query: any TranslationCatalog.CatalogQuery) throws -> TranslationCatalog.Project {
        let request = ProjectEntity.fetchRequest()
        let project: TranslationCatalog.Project

        switch query {
        case GenericProjectQuery.id(let id):
            request.predicate = NSPredicate(format: "%K == %@", argumentArray: ["id", id])

            project = try viewContext.performAndWait {
                guard let entity = try viewContext.fetch(request).first else {
                    throw CatalogError.projectId(id)
                }

                return try TranslationCatalog.Project(entity)
            }
        case GenericProjectQuery.named(let named):
            request.predicate = NSPredicate(format: "%K == %@", "name", named)

            project = try viewContext.performAndWait {
                guard let entity = try viewContext.fetch(request).first else {
                    throw CatalogError.badQuery(query)
                }

                return try TranslationCatalog.Project(entity)
            }
        default:
            throw CatalogError.unhandledQuery(query)
        }

        return project
    }

    public func createProject(_ project: TranslationCatalog.Project) throws -> TranslationCatalog.Project.ID {
        if project.id != .zero {
            if let existing = try? self.project(project.id) {
                throw CatalogError.projectId(existing.id)
            }
        }

        var id = project.id
        if id == .zero {
            id = UUID()
        }

        let context = container.persistentContainer.newBackgroundContext()
        try context.performAndWait {
            let entity: ProjectEntity = context.make()
            entity.id = id
            entity.name = project.name
            try entity.addExpressions(project.expressions, context: context)
            try context.save()
        }

        return id
    }

    public func updateProject(_ id: TranslationCatalog.Project.ID, action: any TranslationCatalog.CatalogUpdate) throws {
        let fetchRequest = ProjectEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K == %@", argumentArray: ["id", id])

        let context = container.persistentContainer.newBackgroundContext()

        guard let projectEntity = try context.fetch(fetchRequest).first else {
            throw CatalogError.projectId(id)
        }

        switch action {
        case GenericProjectUpdate.name(let name):
            try context.performAndWait {
                projectEntity.name = name
                try context.save()
            }
        case GenericProjectUpdate.linkExpression(let expressionId):
            let expressionRequest = ExpressionEntity.fetchRequest()
            expressionRequest.predicate = NSPredicate(format: "%K == %@", argumentArray: ["id", expressionId])
            guard let expression = try context.fetch(expressionRequest).first else {
                throw CatalogError.expressionId(expressionId)
            }

            try context.performAndWait {
                projectEntity.addToExpressionEntities(expression)
                try context.save()
            }
        case GenericProjectUpdate.unlinkExpression(let expressionId):
            let expressionRequest = ExpressionEntity.fetchRequest()
            expressionRequest.predicate = NSPredicate(format: "%K == %@", argumentArray: ["id", expressionId])
            guard let expression = try context.fetch(expressionRequest).first else {
                throw CatalogError.expressionId(expressionId)
            }

            try context.performAndWait {
                projectEntity.removeFromExpressionEntities(expression)
                try context.save()
            }
        default:
            throw CatalogError.unhandledUpdate(action)
        }
    }

    public func deleteProject(_ id: TranslationCatalog.Project.ID) throws {
        let fetchRequest = ProjectEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K == %@", argumentArray: ["id", id])

        let context = container.persistentContainer.newBackgroundContext()

        guard let projectEntity = try context.fetch(fetchRequest).first else {
            throw CatalogError.projectId(id)
        }

        try context.performAndWait {
            context.delete(projectEntity)
            try context.save()
        }
    }

    public func expressions() throws -> [TranslationCatalog.Expression] {
        try viewContext
            .performAndWait {
                try viewContext
                    .fetch(ExpressionEntity.fetchRequest())
                    .map {
                        try TranslationCatalog.Expression($0)
                    }
            }
    }

    public func expressions(matching query: any TranslationCatalog.CatalogQuery) throws -> [TranslationCatalog.Expression] {
        let fetchRequest = ExpressionEntity.fetchRequest()

        switch query {
        case GenericExpressionQuery.key(let named):
            fetchRequest.predicate = NSPredicate(format: "%K CONTAINS[cd] %@", "key", named)
        case GenericExpressionQuery.named(let named):
            fetchRequest.predicate = NSPredicate(format: "%K CONTAINS[cd] %@", "name", named)
        case GenericExpressionQuery.projectId(let projectId):
            fetchRequest.predicate = NSPredicate(format: "ANY %K == %@", argumentArray: ["projectEntities.id", projectId])
        case GenericExpressionQuery.translationsHaving(let languageCode, let scriptCode, let regionCode):
            var subpredicates: [NSPredicate] = [
                NSPredicate(format: "ANY %K == %@", "translationEntities.languageCodeRawValue", languageCode.identifier),
            ]
            if let scriptCode {
                subpredicates.append(
                    NSPredicate(format: "ANY %K == %@", "translationEntities.scriptCodeRawValue", scriptCode.identifier)
                )
            }
            if let regionCode {
                subpredicates.append(
                    NSPredicate(format: "ANY %K == %@", "translationEntities.regionCodeRawValue", regionCode.identifier)
                )
            }

            fetchRequest.predicate = NSCompoundPredicate(type: .and, subpredicates: subpredicates)
        case GenericExpressionQuery.translationsHavingOnly(let languageCode):
            fetchRequest.predicate = NSPredicate(
                format: "SUBQUERY(translationEntities, $translation, $translation.languageCodeRawValue == %@ AND $translation.scriptCodeRawValue == NIL AND $translation.regionCodeRawValue == NIL).@count > 0",
                languageCode.identifier
            )
        default:
            throw CatalogError.unhandledQuery(query)
        }

        return try viewContext
            .performAndWait {
                try viewContext
                    .fetch(fetchRequest)
                    .map {
                        try TranslationCatalog.Expression($0)
                    }
            }
    }

    public func expression(_ id: TranslationCatalog.Expression.ID) throws -> TranslationCatalog.Expression {
        try expression(matching: GenericExpressionQuery.id(id))
    }

    public func expression(matching query: any TranslationCatalog.CatalogQuery) throws -> TranslationCatalog.Expression {
        let fetchRequest = ExpressionEntity.fetchRequest()
        let expression: TranslationCatalog.Expression

        switch query {
        case GenericExpressionQuery.id(let id):
            fetchRequest.predicate = NSPredicate(format: "%K == %@", argumentArray: ["id", id])

            expression = try viewContext.performAndWait {
                guard let entity = try viewContext.fetch(fetchRequest).first else {
                    throw CatalogError.expressionId(id)
                }

                return try TranslationCatalog.Expression(entity)
            }
        case GenericExpressionQuery.key(let key):
            fetchRequest.predicate = NSPredicate(format: "%K CONTAINS[cd] %@", "key", key)

            expression = try viewContext.performAndWait {
                guard let entity = try viewContext.fetch(fetchRequest).first else {
                    throw CatalogError.badQuery(query)
                }

                return try TranslationCatalog.Expression(entity)
            }
        default:
            throw CatalogError.unhandledQuery(query)
        }

        return expression
    }

    public func createExpression(_ expression: TranslationCatalog.Expression) throws -> TranslationCatalog.Expression.ID {
        if expression.id != .zero {
            if let existing = try? self.expression(expression.id) {
                throw CatalogError.projectId(existing.id)
            }
        }

        if let existing = try? self.expression(matching: GenericExpressionQuery.key(expression.key)) {
            throw CatalogError.expressionExistingWithKey(expression.key, existing)
        }

        var id = expression.id
        if id == .zero {
            id = UUID()
        }

        let context = container.persistentContainer.newBackgroundContext()
        try context.performAndWait {
            let entity: ExpressionEntity = context.make()
            entity.id = id
            entity.key = expression.key
            entity.name = expression.name
            entity.defaultLanguageRawValue = expression.defaultLanguageCode.identifier
            entity.context = expression.context
            entity.feature = expression.feature
            try entity.addTranslations(expression.translations, context: context)
            try context.save()
        }

        return id
    }

    public func updateExpression(_ id: TranslationCatalog.Expression.ID, action: any TranslationCatalog.CatalogUpdate) throws {
        let fetchRequest = ExpressionEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K == %@", argumentArray: ["id", id])

        let context = container.persistentContainer.newBackgroundContext()

        guard let expressionEntity = try context.fetch(fetchRequest).first else {
            throw CatalogError.expressionId(id)
        }

        switch action {
        case GenericExpressionUpdate.context(let expressionContext):
            guard expressionContext != expressionEntity.context else {
                return
            }

            try context.performAndWait {
                expressionEntity.context = expressionContext
                try context.save()
            }
        case GenericExpressionUpdate.defaultLanguage(let languageCode):
            guard languageCode != expressionEntity.defaultLanguage else {
                return
            }

            try context.performAndWait {
                expressionEntity.defaultLanguageRawValue = languageCode.identifier
                try context.save()
            }
        case GenericExpressionUpdate.defaultValue(let value):
            guard value != expressionEntity.value else {
                return
            }
            
            try context.performAndWait {
                expressionEntity.defaultValue = value
                try context.save()
            }
        case GenericExpressionUpdate.feature(let feature):
            guard feature != expressionEntity.feature else {
                return
            }

            try context.performAndWait {
                expressionEntity.feature = feature
                try context.save()
            }
        case GenericExpressionUpdate.key(let key):
            let fetch = ExpressionEntity.fetchRequest()
            fetch.predicate = NSPredicate(format: "%K == %@", "key", key)
            if let existing = try context.fetch(fetch).first.map({ try TranslationCatalog.Expression($0) }) {
                throw CatalogError.expressionExistingWithKey(key, existing)
            }

            try context.performAndWait {
                expressionEntity.key = key.uppercased()
                try context.save()
            }
        case GenericExpressionUpdate.name(let name):
            guard name != expressionEntity.name else {
                return
            }

            try context.performAndWait {
                expressionEntity.name = name
                try context.save()
            }
        default:
            throw CatalogError.unhandledUpdate(action)
        }
    }

    public func deleteExpression(_ id: TranslationCatalog.Expression.ID) throws {
        let fetchRequest = ExpressionEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K == %@", argumentArray: ["id", id])

        let context = container.persistentContainer.newBackgroundContext()

        guard let expressionEntity = try context.fetch(fetchRequest).first else {
            throw CatalogError.expressionId(id)
        }

        try context.performAndWait {
            context.delete(expressionEntity)
            try context.save()
        }
    }

    public func translations() throws -> [TranslationCatalog.Translation] {
        try viewContext
            .performAndWait {
                try viewContext
                    .fetch(TranslationEntity.fetchRequest())
                    .map {
                        try TranslationCatalog.Translation($0)
                    }
            }
    }

    public func translations(matching query: any TranslationCatalog.CatalogQuery) throws -> [TranslationCatalog.Translation] {
        let fetchRequest = TranslationEntity.fetchRequest()

        switch query {
        case GenericTranslationQuery.expressionId(let expressionId):
            fetchRequest.predicate = NSPredicate(format: "%K == %@", argumentArray: ["expressionEntity.id", expressionId])
        case GenericTranslationQuery.having(let expressionId, let languageCode, let scriptCode, let regionCode):
            var subpredicates: [NSPredicate] = [
                NSPredicate(format: "%K == %@", argumentArray: ["expressionEntity.id", expressionId]),
                NSPredicate(format: "%K == %@", "languageCodeRawValue", languageCode.identifier),
            ]
            if let scriptCode {
                subpredicates.append(
                    NSPredicate(format: "%K == %@", "scriptCodeRawValue", scriptCode.identifier)
                )
            }
            if let regionCode {
                subpredicates.append(
                    NSPredicate(format: "%K == %@", "regionCodeRawValue", regionCode.identifier)
                )
            }

            fetchRequest.predicate = NSCompoundPredicate(type: .and, subpredicates: subpredicates)
        case GenericTranslationQuery.havingOnly(let expressionId, let languageCode):
            fetchRequest.predicate = NSCompoundPredicate(
                type: .and,
                subpredicates: [
                    NSPredicate(format: "%K == %@", argumentArray: ["expressionEntity.id", expressionId]),
                    NSPredicate(format: "%K == %@", "languageCodeRawValue", languageCode.identifier),
                    NSPredicate(format: "%K == NIL", "scriptCodeRawValue"),
                    NSPredicate(format: "%K == NIL", "regionCodeRawValue"),
                ]
            )
        default:
            throw CatalogError.unhandledQuery(query)
        }

        return try viewContext
            .performAndWait {
                try viewContext
                    .fetch(fetchRequest)
                    .map {
                        try TranslationCatalog.Translation($0)
                    }
            }
    }

    public func translation(_ id: TranslationCatalog.Translation.ID) throws -> TranslationCatalog.Translation {
        try translation(matching: GenericTranslationQuery.id(id))
    }

    public func translation(matching query: any TranslationCatalog.CatalogQuery) throws -> TranslationCatalog.Translation {
        let fetchRequest = TranslationEntity.fetchRequest()
        let translation: TranslationCatalog.Translation

        switch query {
        case GenericTranslationQuery.having(let expressionId, let languageCode, let scriptCode, let regionCode):
            var subpredicates: [NSPredicate] = [
                NSPredicate(format: "%K == %@", argumentArray: ["expressionEntity.id", expressionId]),
                NSPredicate(format: "%K == %@", "languageCodeRawValue", languageCode.identifier),
            ]
            if let scriptCode {
                subpredicates.append(
                    NSPredicate(format: "%K == %@", "scriptCodeRawValue", scriptCode.identifier)
                )
            } else {
                subpredicates.append(
                    NSPredicate(format: "%K == NIL", "scriptCodeRawValue")
                )
            }
            if let regionCode {
                subpredicates.append(
                    NSPredicate(format: "%K == %@", "regionCodeRawValue", regionCode.identifier)
                )
            } else {
                subpredicates.append(
                    NSPredicate(format: "%K == NIL", "regionCodeRawValue")
                )
            }

            fetchRequest.predicate = NSCompoundPredicate(
                type: .and,
                subpredicates: subpredicates
            )

            translation = try viewContext.performAndWait {
                guard let entity = try viewContext.fetch(fetchRequest).first else {
                    throw CatalogError.badQuery(query)
                }

                return try TranslationCatalog.Translation(entity)
            }
        case GenericTranslationQuery.id(let translationId):
            fetchRequest.predicate = NSPredicate(format: "%K == %@", argumentArray: ["id", translationId])

            translation = try viewContext.performAndWait {
                guard let entity = try viewContext.fetch(fetchRequest).first else {
                    throw CatalogError.translationId(translationId)
                }

                return try TranslationCatalog.Translation(entity)
            }
        default:
            throw CatalogError.unhandledQuery(query)
        }

        return translation
    }

    public func createTranslation(_ translation: TranslationCatalog.Translation) throws -> TranslationCatalog.Translation.ID {
        if translation.id != .zero {
            if let existing = try? self.translation(translation.id) {
                throw CatalogError.translationId(existing.id)
            }
        }

        let context = container.persistentContainer.newBackgroundContext()

        let request = ExpressionEntity.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %@", argumentArray: ["id", translation.expressionId])

        guard let expressionEntity = try context.fetch(request).first else {
            throw CatalogError.expressionId(translation.expressionId)
        }

        let query = GenericTranslationQuery.having(translation.expressionId, translation.language, translation.script, translation.region)
        if let existingTranslation = try? self.translation(matching: query) {
            guard existingTranslation.value != translation.value else {
                throw CatalogError.translationExistingWithValue(translation.value, existingTranslation)
            }

            try updateTranslation(translation.id, action: GenericTranslationUpdate.value(translation.value))
            return existingTranslation.id
        }

        var id = translation.id
        if id == .zero {
            id = UUID()
        }

        try context.performAndWait {
            let entity: TranslationEntity = context.make()
            entity.id = id
            entity.languageCodeRawValue = translation.language.identifier
            entity.regionCodeRawValue = translation.region?.identifier
            entity.scriptCodeRawValue = translation.script?.identifier
            entity.value = translation.value
            expressionEntity.addToTranslationEntities(entity)

            try context.save()
        }

        return id
    }

    public func updateTranslation(_ id: TranslationCatalog.Translation.ID, action: any TranslationCatalog.CatalogUpdate) throws {
        let fetchRequest = TranslationEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K == %@", argumentArray: ["id", id])

        let context = container.persistentContainer.newBackgroundContext()

        guard let translationEntity = try context.fetch(fetchRequest).first else {
            throw CatalogError.translationId(id)
        }

        switch action {
        case GenericTranslationUpdate.language(let languageCode):
            guard translationEntity.language != languageCode else {
                return
            }

            try context.performAndWait {
                translationEntity.languageCodeRawValue = languageCode.identifier
                try context.save()
            }
        case GenericTranslationUpdate.region(let regionCode):
            guard translationEntity.region != regionCode else {
                return
            }

            try context.performAndWait {
                translationEntity.regionCodeRawValue = regionCode?.identifier
                try context.save()
            }
        case GenericTranslationUpdate.script(let scriptCode):
            guard translationEntity.script != scriptCode else {
                return
            }

            try context.performAndWait {
                translationEntity.scriptCodeRawValue = scriptCode?.identifier
                try context.save()
            }
        case GenericTranslationUpdate.value(let value):
            guard translationEntity.value != value else {
                return
            }

            try context.performAndWait {
                translationEntity.value = value
                try context.save()
            }
        default:
            throw CatalogError.unhandledUpdate(action)
        }
    }

    public func deleteTranslation(_ id: TranslationCatalog.Translation.ID) throws {
        let fetchRequest = TranslationEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K == %@", argumentArray: ["id", id])

        let context = container.persistentContainer.newBackgroundContext()

        guard let translationEntity = try context.fetch(fetchRequest).first else {
            throw CatalogError.translationId(id)
        }

        try context.performAndWait {
            context.delete(translationEntity)
            try context.save()
        }
    }

    public func locales() throws -> Set<Locale> {
        let translations = try translations()
        return Set(
            translations.map { translation in
                Locale(languageCode: translation.language, script: translation.script, languageRegion: translation.region)
            }
        )
    }

    @available(*, deprecated)
    public func localeIdentifiers() throws -> Set<Locale.Identifier> {
        try Set(locales().map(\.identifier))
    }
}

private extension CoreDataCatalog {
    func migrateDefaultExpressionValues() throws {
        let context = container.persistentContainer.newBackgroundContext()
        try context.performAndWait {
            let expressionRequest = ExpressionEntity.fetchRequest()
            expressionRequest.predicate = NSPredicate(format: "%K == %@", argumentArray: ["defaultValue", ""])
            
            let expressionEntities = try context.fetch(expressionRequest)
            for expression in expressionEntities {
                guard let language = expression.defaultLanguageRawValue, !language.isEmpty else {
                    continue
                }
                
                let translationRequest = TranslationEntity.fetchRequest()
                translationRequest.predicate = NSCompoundPredicate(
                    type: .and,
                    subpredicates: [
                        NSPredicate(format: "%K == %@", argumentArray: ["expressionEntity", expression]),
                        NSPredicate(format: "%K == %@", argumentArray: ["languageCodeRawValue", language]),
                        NSPredicate(format: "%K == NIL", "scriptCodeRawValue"),
                        NSPredicate(format: "%K == NIL", "regionCodeRawValue"),
                    ]
                )
                
                if let translationEntity = try context.fetch(translationRequest).first {
                    expression.defaultValue = translationEntity.value ?? ""
                    context.delete(translationEntity)
                }
            }
            
            try context.save()
        }
    }
}

private extension ProjectEntity {
    func addExpressions(
        _ expressions: [TranslationCatalog.Expression],
        context: NSManagedObjectContext
    ) throws {
        for expression in expressions {
            var expressionId = expression.id
            if expressionId == .zero {
                expressionId = UUID()
            }

            let fetch = ExpressionEntity.fetchRequest()
            fetch.predicate = NSPredicate(format: "%K == %@", argumentArray: ["id", expressionId])

            let entity: ExpressionEntity
            if let match = try context.fetch(fetch).first {
                entity = match
            } else {
                entity = context.make()
                entity.id = expressionId
                entity.key = expression.key
                entity.name = expression.name
                entity.defaultLanguageRawValue = expression.defaultLanguageCode.identifier
                entity.context = expression.context
                entity.feature = expression.feature
            }

            try entity.addTranslations(expression.translations, context: context)

            addToExpressionEntities(entity)
        }
    }
}

private extension ExpressionEntity {
    func addTranslations(
        _ translations: [TranslationCatalog.Translation],
        context: NSManagedObjectContext
    ) throws {
        for translation in translations {
            var translationId = translation.id
            if translationId == .zero {
                translationId = UUID()
            }

            let fetch = TranslationEntity.fetchRequest()
            fetch.predicate = NSPredicate(format: "%K == %@", argumentArray: ["id", translationId])

            let entity: TranslationEntity
            if let match = try context.fetch(fetch).first {
                entity = match
            } else {
                entity = context.make()
                entity.id = translationId
                entity.value = translation.value
                entity.languageCodeRawValue = translation.language.identifier
                entity.scriptCodeRawValue = translation.script?.identifier
                entity.regionCodeRawValue = translation.region?.identifier
            }

            addToTranslationEntities(entity)
        }
    }
}

#endif
