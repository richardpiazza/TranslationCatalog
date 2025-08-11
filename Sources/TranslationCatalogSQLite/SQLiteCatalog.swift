import Foundation
import SQLite
import StatementSQLite
import TranslationCatalog

/// An implementation of `TranslationCatalog.Catalog` using **SQLite**.
public class SQLiteCatalog: TranslationCatalog.Catalog {
    public typealias RenderedStatementHook = (String) -> Void

    private let db: Connection
    /// A hook to observe statements that are rendered and executed.
    public var statementHook: RenderedStatementHook?

    public init(url: URL) throws {
        db = try Connection(url: url)
    }

    // MARK: - Project

    /// Retrieve all `Project`s in the catalog.
    ///
    /// ## SQLiteCatalog Notes
    ///
    /// This presents only a _shallow_ copy of the entities. In order to retrieve a _deep_ hierarchy, use `projects(matching:)` with
    /// the `SQLiteCatalog.ProjectQuery.hierarchy` option.
    public func projects() throws -> [Project] {
        let statement = renderStatement(.selectAllFromProject)
        return try db.projectEntities(statement: statement).map { try $0.project() }
    }

    public func projects(matching query: CatalogQuery) throws -> [Project] {
        switch query {
        case ProjectQuery.hierarchy:
            var output: [Project] = []
            let projectEntities = try db.projectEntities(statement: renderStatement(.selectAllFromProject))
            try projectEntities.forEach { p in
                let expressionEntities = try db.expressionEntities(statement: renderStatement(.selectExpressions(withProjectID: p.id)))
                var expressions: [TranslationCatalog.Expression] = []
                try expressionEntities.forEach { e in
                    let translationEntities = try db.translationEntities(statement: renderStatement(.selectTranslationsFor(e.id)))
                    let translations = try translationEntities.map { try $0.translation(with: e.uuid) }
                    try expressions.append(e.expression(with: translations))
                }

                try output.append(p.project(with: expressions))
            }
            return output
        case GenericProjectQuery.named(let name):
            let entities = try db.projectEntities(statement: renderStatement(.selectProjects(withNameLike: name)))
            return try entities.map { try $0.project() }
        case GenericProjectQuery.expressionId(let expressionId):
            guard let entity = try db.expressionEntity(statement: renderStatement(.selectExpression(withID: expressionId))) else {
                throw CatalogError.expressionId(expressionId)
            }

            let entities = try db.projectEntities(statement: renderStatement(.selectProjects(withExpressionID: entity.id)))
            return try entities.map { try $0.project() }
        default:
            throw CatalogError.unhandledQuery(query)
        }
    }

    public func project(_ id: Project.ID) throws -> Project {
        try project(matching: GenericProjectQuery.id(id))
    }

    public func project(matching query: CatalogQuery) throws -> Project {
        switch query {
        case ProjectQuery.primaryKey(let id):
            guard let entity = try db.projectEntity(statement: renderStatement(.selectProject(withID: id))) else {
                throw Error.invalidPrimaryKey(id)
            }

            return try entity.project()
        case GenericProjectQuery.id(let id):
            guard let entity = try db.projectEntity(statement: renderStatement(.selectProject(withID: id))) else {
                throw CatalogError.projectId(id)
            }

            return try entity.project()
        case GenericProjectQuery.named(let name):
            guard let entity = try db.projectEntity(statement: renderStatement(.selectProject(withName: name))) else {
                throw Error.invalidStringValue(name)
            }

            return try entity.project()
        default:
            throw CatalogError.unhandledQuery(query)
        }
    }

    @discardableResult public func createProject(_ project: Project) throws -> Project.ID {
        if project.id != .zero {
            if let existing = try? self.project(project.id) {
                throw CatalogError.projectId(existing.id)
            }
        }

        var id = project.id
        var entity = ProjectEntity(project)
        if project.id == .zero {
            id = UUID()
            entity.uuid = id.uuidString
        }

        let insert = Insert(literal: renderStatement(.insertProject(entity)))
        let primaryKey = try Int(db.run(insert))
        try project.expressions.forEach { expression in
            try insertAndLinkExpression(expression, projectID: primaryKey)
        }

        return id
    }

    public func updateProject(_ id: Project.ID, action: CatalogUpdate) throws {
        guard let entity = try db.projectEntity(statement: renderStatement(.selectProject(withID: id))) else {
            throw CatalogError.projectId(id)
        }

        switch action {
        case GenericProjectUpdate.name(let name):
            try db.run(renderStatement(.updateProject(entity.id, name: name)))
        case GenericProjectUpdate.linkExpression(let uuid):
            guard let expression = try db.expressionEntity(statement: renderStatement(.selectExpression(withID: uuid))) else {
                throw CatalogError.expressionId(uuid)
            }

            try linkProject(entity.id, expressionID: expression.id)
        case GenericProjectUpdate.unlinkExpression(let uuid):
            guard let expression = try db.expressionEntity(statement: renderStatement(.selectExpression(withID: uuid))) else {
                throw CatalogError.expressionId(uuid)
            }

            try unlinkProject(entity.id, expressionID: expression.id)
        default:
            throw CatalogError.unhandledUpdate(action)
        }
    }

    public func deleteProject(_ id: Project.ID) throws {
        guard let entity = try db.projectEntity(statement: renderStatement(.selectProject(withID: id))) else {
            throw CatalogError.projectId(id)
        }

        try db.transaction {
            try db.run(renderStatement(.deleteProjectExpressions(projectID: entity.id)))
            try db.run(renderStatement(.deleteProject(entity.id)))
        }
    }

    // MARK: - Expression

    public func expressions() throws -> [TranslationCatalog.Expression] {
        try db.expressionEntities(statement: renderStatement(.selectAllFromExpression)).map { try $0.expression() }
    }

    public func expressions(matching query: CatalogQuery) throws -> [TranslationCatalog.Expression] {
        switch query {
        case ExpressionQuery.hierarchy:
            var output: [TranslationCatalog.Expression] = []
            let expressionEntities = try db.expressionEntities(statement: renderStatement(.selectAllFromExpression))
            try expressionEntities.forEach { e in
                let translationEntities = try db.translationEntities(statement: renderStatement(.selectTranslationsFor(e.id)))
                let translations = try translationEntities.map { try $0.translation(with: e.uuid) }
                try output.append(e.expression(with: translations))
            }
            return output
        case GenericExpressionQuery.projectId(let projectID):
            guard let project = try? db.projectEntity(statement: renderStatement(.selectProject(withID: projectID))) else {
                throw CatalogError.projectId(projectID)
            }

            let entities = try db.expressionEntities(statement: renderStatement(.selectExpressions(withProjectID: project.id)))
            return try entities.map { try $0.expression() }
        case GenericExpressionQuery.key(let key):
            let entities = try db.expressionEntities(statement: renderStatement(.selectExpressions(withKeyLike: key)))
            return try entities.map { try $0.expression() }
        case GenericExpressionQuery.value(let value):
            let entities = try db.expressionEntities(statement: renderStatement(.selectExpressions(withValueLike: value)))
            return try entities.map { try $0.expression() }
        case GenericExpressionQuery.named(let name):
            let entities = try db.expressionEntities(statement: renderStatement(.selectExpressions(withNameLike: name)))
            return try entities.map { try $0.expression() }
        case GenericExpressionQuery.translationsHavingOnly(let languageCode):
            let entities = try db.expressionEntities(statement: renderStatement(.selectExpressionsHavingOnly(languageCode: languageCode)))
            return try entities.map { try $0.expression() }
        case GenericExpressionQuery.translationsHaving(let languageCode, let scriptCode, let regionCode):
            let entities = try db.expressionEntities(statement: renderStatement(.selectExpressionsWith(languageCode: languageCode, scriptCode: scriptCode, regionCode: regionCode)))
            return try entities.map { try $0.expression() }
        case GenericExpressionQuery.translationsHavingState(let state):
            let entities = try db.expressionEntities(statement: renderStatement(.selectExpressionsWith(state: state)))
            return try entities.map { try $0.expression() }
        default:
            throw CatalogError.unhandledQuery(query)
        }
    }

    public func expression(_ id: TranslationCatalog.Expression.ID) throws -> TranslationCatalog.Expression {
        try expression(matching: GenericExpressionQuery.id(id))
    }

    public func expression(matching query: CatalogQuery) throws -> TranslationCatalog.Expression {
        switch query {
        case ExpressionQuery.primaryKey(let id):
            guard let entity = try db.expressionEntity(statement: renderStatement(.selectExpression(withID: id))) else {
                throw Error.invalidPrimaryKey(id)
            }

            return try entity.expression()
        case GenericExpressionQuery.id(let uuid):
            guard let entity = try db.expressionEntity(statement: renderStatement(.selectExpression(withID: uuid))) else {
                throw CatalogError.expressionId(uuid)
            }

            return try entity.expression()
        case GenericExpressionQuery.key(let key):
            guard let entity = try db.expressionEntity(statement: renderStatement(.selectExpression(withKey: key))) else {
                throw CatalogError.badQuery(query)
            }

            return try entity.expression()
        default:
            throw CatalogError.unhandledQuery(query)
        }
    }

    /// Insert a `Expression` into the catalog.
    ///
    /// ## SQLiteCatalog Notes:
    ///
    /// * If a `Expression.ID` is specified (non-zero), and a matching entity is found, the insert will fail.
    /// * If an entity with a matching `Expression.key` is found, the insert will fail. (Keys must be unique)
    ///
    /// - parameter expression: The entity to insert.
    /// - returns The unique identifier created for the new entity.
    @discardableResult public func createExpression(_ expression: TranslationCatalog.Expression) throws -> TranslationCatalog.Expression.ID {
        if expression.id != .zero {
            if let existing = try? self.expression(expression.id) {
                throw CatalogError.expressionExistingWithId(existing.id, existing)
            }
        }

        if let existing = try? db.expressionEntity(statement: renderStatement(.selectExpression(withKey: expression.key))) {
            throw CatalogError.expressionExistingWithKey(expression.key, (try? existing.expression()) ?? expression)
        }

        var id = expression.id
        var entity = ExpressionEntity(expression)
        if expression.id == .zero {
            id = UUID()
            entity.uuid = id.uuidString
        }

        try db.run(renderStatement(.insertExpression(entity)))
        for translation in expression.translations {
            let expressionTranslation = Translation(
                translation: translation,
                expressionId: id
            )
            try createTranslation(expressionTranslation)
        }

        return id
    }

    public func updateExpression(_ id: TranslationCatalog.Expression.ID, action: CatalogUpdate) throws {
        guard let entity = try? db.expressionEntity(statement: renderStatement(.selectExpression(withID: id))) else {
            throw CatalogError.expressionId(id)
        }

        switch action {
        case GenericExpressionUpdate.key(let key):
            guard key != entity.key else {
                return
            }

            try db.run(renderStatement(.updateExpression(entity.id, key: key)))
        case GenericExpressionUpdate.name(let name):
            guard name != entity.name else {
                return
            }

            try db.run(renderStatement(.updateExpression(entity.id, name: name)))
        case GenericExpressionUpdate.defaultLanguage(let languageCode):
            guard languageCode.identifier != entity.defaultLanguage else {
                return
            }

            try db.run(renderStatement(.updateExpression(entity.id, defaultLanguage: languageCode)))
        case GenericExpressionUpdate.defaultValue(let value):
            guard value != entity.defaultValue else {
                return
            }

            try db.run(renderStatement(.updateExpression(entity.id, defaultValue: value)))
        case GenericExpressionUpdate.context(let context):
            guard context != entity.context else {
                return
            }

            try db.run(renderStatement(.updateExpression(entity.id, context: context)))
        case GenericExpressionUpdate.feature(let feature):
            guard feature != entity.feature else {
                return
            }

            try db.run(renderStatement(.updateExpression(entity.id, feature: feature)))
        default:
            throw CatalogError.unhandledUpdate(action)
        }
    }

    public func deleteExpression(_ id: TranslationCatalog.Expression.ID) throws {
        guard let entity = try? db.expressionEntity(statement: renderStatement(.selectExpression(withID: id))) else {
            throw CatalogError.expressionId(id)
        }

        try db.transaction {
            try db.run(renderStatement(.deleteTranslations(withExpressionID: entity.id)))
            try db.run(renderStatement(.deleteProjectExpressions(expressionID: entity.id)))
            try db.run(renderStatement(.deleteExpression(entity.id)))
        }
    }

    // MARK: - Translation

    public func translations() throws -> [TranslationCatalog.Translation] {
        // A bit of annoying implementation detail: Since the SQLite database is using a Integer foreign key,
        // in order to map the entity to the struct, a double query needs to be performed.
        // Storing the expression uuid on the translation entity would be one way to counter this.
        // TODO: Render with statement when 'AS' becomes available.

        let expressionEntities = try db.expressionEntities(statement: renderStatement(.selectAllFromExpression))
        let translationEntities = try db.translationEntities(statement: renderStatement(.selectAllFromTranslation))

        var output: [TranslationCatalog.Translation] = []
        try translationEntities.forEach { entity in
            if let expression = expressionEntities.first(where: { $0.id == entity.expressionID }) {
                try output.append(entity.translation(with: expression.uuid))
            }
        }
        return output
    }

    public func translations(matching query: CatalogQuery) throws -> [TranslationCatalog.Translation] {
        switch query {
        case GenericTranslationQuery.expressionId(let expressionUUID):
            guard let expressionEntity = try db.expressionEntity(statement: renderStatement(.selectExpression(withID: expressionUUID))) else {
                throw CatalogError.expressionId(expressionUUID)
            }

            let entities = try db.translationEntities(statement: renderStatement(.selectTranslationsFor(expressionEntity.id)))
            return try entities.map { try $0.translation(with: expressionEntity.uuid) }
        case GenericTranslationQuery.havingOnly(let expressionId, let language):
            guard let expressionEntity = try db.expressionEntity(statement: renderStatement(.selectExpression(withID: expressionId))) else {
                throw CatalogError.expressionId(expressionId)
            }

            let entities = try db.translationEntities(statement: renderStatement(.selectTranslationsHavingOnly(expressionEntity.id, languageCode: language)))
            return try entities.map { try $0.translation(with: expressionEntity.uuid) }
        case GenericTranslationQuery.having(let expressionId, let language, let script, let region):
            guard let expressionEntity = try db.expressionEntity(statement: renderStatement(.selectExpression(withID: expressionId))) else {
                throw CatalogError.expressionId(expressionId)
            }

            let entities = try db.translationEntities(statement: renderStatement(.selectTranslationsFor(expressionEntity.id, languageCode: language, scriptCode: script, regionCode: region)))
            return try entities.map { try $0.translation(with: expressionEntity.uuid) }
        default:
            throw CatalogError.unhandledQuery(query)
        }
    }

    public func translation(_ id: TranslationCatalog.Translation.ID) throws -> TranslationCatalog.Translation {
        try translation(matching: GenericTranslationQuery.id(id))
    }

    public func translation(matching query: CatalogQuery) throws -> TranslationCatalog.Translation {
        let entity: TranslationEntity

        switch query {
        case TranslationQuery.primaryKey(let id):
            guard let _entity = try db.translationEntity(statement: renderStatement(.selectTranslation(withID: id))) else {
                throw Error.invalidPrimaryKey(id)
            }
            entity = _entity
        case GenericTranslationQuery.id(let uuid):
            guard let _entity = try db.translationEntity(statement: renderStatement(.selectTranslation(withID: uuid))) else {
                throw CatalogError.translationId(uuid)
            }
            entity = _entity
        case GenericTranslationQuery.having(let expressionId, let languageCode, let scriptCode, let regionCode):
            guard let expression = try db.expressionEntity(statement: renderStatement(.selectExpression(withID: expressionId))) else {
                throw CatalogError.expressionId(expressionId)
            }

            guard let _entity = try db.translationEntity(statement: renderStatement(.selectTranslationsHaving(expression.id, languageCode: languageCode, scriptCode: scriptCode, regionCode: regionCode))) else {
                throw CatalogError.badQuery(query)
            }

            entity = _entity
        default:
            throw CatalogError.unhandledQuery(query)
        }

        guard let expressionEntity = try db.expressionEntity(statement: renderStatement(.selectExpression(withID: entity.expressionID))) else {
            throw Error.invalidPrimaryKey(entity.expressionID)
        }

        return try entity.translation(with: expressionEntity.uuid)
    }

    /// Insert a `Translation` into the catalog.
    ///
    /// ## SQLiteCatalog Notes:
    ///
    /// * A `Expression` with `Translation.expressionID` must already exist, or the insert will fail.
    /// * If a `Translation.ID` is specified (non-zero), and a matching entity is found, the insert will fail.
    ///
    /// - parameter translation: The entity to insert.
    /// - returns The unique identifier created for the new entity.
    @discardableResult public func createTranslation(_ translation: TranslationCatalog.Translation) throws -> TranslationCatalog.Translation.ID {
        if translation.id != .zero {
            if let existing = try? self.translation(translation.id) {
                throw CatalogError.translationExistingWithId(existing.id, existing)
            }
        }

        guard let expression = try db.expressionEntity(statement: renderStatement(.selectExpression(withID: translation.expressionId))) else {
            throw CatalogError.expressionId(translation.expressionId)
        }

        let query = GenericTranslationQuery.having(translation.expressionId, translation.language, translation.script, translation.region)
        if let existing = try? self.translation(matching: query) {
            if existing.value == translation.value {
                throw CatalogError.translationExistingWithValue(translation.value, existing)
            } else {
                try updateTranslation(existing.id, action: GenericTranslationUpdate.value(translation.value))
                return existing.id
            }
        }

        var id = translation.id
        var entity = TranslationEntity(translation)
        if translation.id == .zero {
            id = UUID()
            entity.uuid = id.uuidString
        }
        entity.expressionID = expression.id

        try db.run(renderStatement(.insertTranslation(entity)))

        return id
    }

    public func updateTranslation(_ id: TranslationCatalog.Translation.ID, action: CatalogUpdate) throws {
        guard let entity = try? db.translationEntity(statement: renderStatement(.selectTranslation(withID: id))) else {
            throw CatalogError.translationId(id)
        }

        switch action {
        case GenericTranslationUpdate.language(let languageCode):
            guard languageCode.identifier != entity.language else {
                return
            }

            try db.run(renderStatement(.updateTranslation(entity.id, languageCode: languageCode)))
        case GenericTranslationUpdate.script(let scriptCode):
            guard scriptCode?.identifier != entity.script else {
                return
            }

            try db.run(renderStatement(.updateTranslation(entity.id, scriptCode: scriptCode)))
        case GenericTranslationUpdate.region(let regionCode):
            guard regionCode?.identifier != entity.region else {
                return
            }

            try db.run(renderStatement(.updateTranslation(entity.id, regionCode: regionCode)))
        case GenericTranslationUpdate.value(let value):
            guard value != entity.value else {
                return
            }

            try db.run(renderStatement(.updateTranslation(entity.id, value: value)))
        case GenericTranslationUpdate.state(let state):
            guard state != entity.state else {
                return
            }

            try db.run(renderStatement(.updateTranslation(entity.id, state: state)))
        default:
            throw CatalogError.unhandledUpdate(action)
        }
    }

    public func deleteTranslation(_ id: TranslationCatalog.Translation.ID) throws {
        guard let entity = try? db.translationEntity(statement: renderStatement(.selectTranslation(withID: id))) else {
            throw CatalogError.translationId(id)
        }

        try db.transaction {
            try db.run(renderStatement(.deleteTranslation(entity.id)))
        }
    }

    // MARK: - Metadata

    public func locales() throws -> Set<Locale> {
        let expressionEntities = try db.expressionEntities(statement: renderStatement(.selectAllFromExpression))
        let expressionLocales = Set(
            expressionEntities.map { Locale(languageCode: $0.languageCode) }
        )

        let translationEntities = try db.translationEntities(statement: renderStatement(.selectAllFromTranslation))
        let translationLocales = Set(
            translationEntities
                .map { translation in
                    Locale(languageCode: translation.languageCode, script: translation.scriptCode, languageRegion: translation.regionCode)
                }
        )

        return expressionLocales.union(translationLocales)
    }
}

private extension SQLiteCatalog {
    func renderStatement(_ statement: SQLiteStatement) -> String {
        let rendered = statement.render()
        statementHook?(rendered)
        return rendered
    }

    /// Creates an `Expression` (if needed) , and links to the provided project
    func insertAndLinkExpression(_ expression: TranslationCatalog.Expression, projectID: Int) throws {
        // Link Only
        if let entity = try db.expressionEntity(statement: renderStatement(.selectExpression(withID: expression.id))) {
            try linkProject(projectID, expressionID: entity.id)
            return
        }

        // Create & Link
        let uuid = try createExpression(expression)
        guard let entity = try db.expressionEntity(statement: renderStatement(.selectExpression(withID: uuid))) else {
            throw CatalogError.expressionId(uuid)
        }

        try linkProject(projectID, expressionID: entity.id)
    }

    func linkProject(_ projectID: Int, expressionID: Int) throws {
        if let _ = try db.projectExpressionEntity(statement: renderStatement(.selectProjectExpression(projectID: projectID, expressionID: expressionID))) {
            // Link exists
            return
        }

        try db.run(renderStatement(.insertProjectExpression(projectID: projectID, expressionID: expressionID)))
    }

    func unlinkProject(_ projectID: Int, expressionID: Int) throws {
        guard let _ = try db.projectExpressionEntity(statement: renderStatement(.selectProjectExpression(projectID: projectID, expressionID: expressionID))) else {
            return
        }

        try db.run(renderStatement(.deleteProjectExpression(projectID: projectID, expressionID: expressionID)))
    }
}
