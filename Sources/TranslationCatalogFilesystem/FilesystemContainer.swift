import Foundation
import TranslationCatalog

protocol FilesystemContainer: AnyObject, Catalog {
    associatedtype Medium

    var medium: Medium { get }
    var translationContainer: Medium { get }
    var expressionContainer: Medium { get }
    var projectContainer: Medium { get }

    var translationDocuments: [TranslationDocument] { get set }
    var expressionDocuments: [ExpressionDocument] { get set }
    var projectDocuments: [ProjectDocument] { get set }

    func loadDocuments<T: Document>(from container: Medium, using decoder: JSONDecoder) throws -> [T]
    func writeDocument(_ document: any Document, using encoder: JSONEncoder) throws
    func removeDocument(_ document: any Document) throws

    func getSchemaVersion(using decoder: JSONDecoder) -> DocumentSchemaVersion?
    func setSchemaVersion(_ version: DocumentSchemaVersion, using encoder: JSONEncoder) throws
    func migrateSchema(from: DocumentSchemaVersion, to: DocumentSchemaVersion) throws
}

extension FilesystemContainer {
    static var versionPath: String { ".catalog-version" }
    static var translationsPath: String { "Translations" }
    static var expressionsPath: String { "Expressions" }
    static var projectsPath: String { "Projects" }

    func loadAllDocuments() throws {
        translationDocuments = try loadDocuments(from: translationContainer)
        expressionDocuments = try loadDocuments(from: expressionContainer)
        projectDocuments = try loadDocuments(from: projectContainer)
    }

    func loadDocuments<T: Document>(from container: Medium, using decoder: JSONDecoder = .filesystem) throws -> [T] {
        try loadDocuments(from: container, using: decoder)
    }

    func writeDocument(_ document: any Document, using encoder: JSONEncoder = .filesystem) throws {
        try writeDocument(document, using: encoder)
    }

    func getSchemaVersion(using decoder: JSONDecoder = .filesystem) -> DocumentSchemaVersion? {
        getSchemaVersion(using: decoder)
    }

    func setSchemaVersion(_ version: DocumentSchemaVersion, using encoder: JSONEncoder = .filesystem) throws {
        try setSchemaVersion(version, using: encoder)
    }

    func migrateSchema(from: DocumentSchemaVersion, to: DocumentSchemaVersion) throws {
        guard to != from else {
            // Migration complete
            return
        }

        guard to > from else {
            throw CocoaError(.featureUnsupported)
        }

        switch from {
        case .v1:
            let translations: [TranslationDocumentV1] = try loadDocuments(from: translationContainer)
            let expressions: [ExpressionDocumentV1] = try loadDocuments(from: expressionContainer)

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
            let translations: [TranslationDocumentV1] = try loadDocuments(from: translationContainer)

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

        guard let next = DocumentSchemaVersion(rawValue: from.rawValue + 1) else {
            throw CocoaError(.featureUnsupported)
        }

        try migrateSchema(from: next, to: to)
    }
}

extension FilesystemContainer {
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
        case GenericProjectQuery.expressionId(let expressionId):
            documents = projectDocuments
                .filter { $0.expressionIds.contains(expressionId) }
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
                throw CatalogError.projectId(uuid)
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
                throw CatalogError.projectId(existing.id)
            }
        }

        let expressionIds = try project.expressions.map {
            do {
                return try createExpression($0)
            } catch CatalogError.expressionId {
                return $0.id
            }
        }

        let id = project.id != .zero ? project.id : UUID()
        let document = ProjectDocument(
            id: id,
            name: project.name,
            expressionIds: Set(expressionIds)
        )

        try writeDocument(document)
        projectDocuments.append(document)
        return id
    }

    public func updateProject(_ id: Project.ID, action: CatalogUpdate) throws {
        guard let index = projectDocuments.firstIndex(where: { $0.id == id }) else {
            throw CatalogError.projectId(id)
        }

        switch action {
        case GenericProjectUpdate.name(let name):
            projectDocuments[index].name = name
        case GenericProjectUpdate.linkExpression(let expressionId):
            projectDocuments[index].expressionIds.insert(expressionId)
        case GenericProjectUpdate.unlinkExpression(let expressionId):
            projectDocuments[index].expressionIds.remove(expressionId)
        default:
            throw CatalogError.unhandledUpdate(action)
        }

        let document = projectDocuments[index]
        try writeDocument(document)
    }

    public func deleteProject(_ id: Project.ID) throws {
        guard let index = projectDocuments.firstIndex(where: { $0.id == id }) else {
            throw CatalogError.projectId(id)
        }

        let document = projectDocuments.remove(at: index)
        try removeDocument(document)
    }

    // MARK: - Expression

    public func expressions() throws -> [TranslationCatalog.Expression] {
        expressionDocuments.map { document in
            TranslationCatalog.Expression(document: document, translations: [])
        }
    }

    public func expressions(matching query: CatalogQuery) throws -> [TranslationCatalog.Expression] {
        switch query {
        case GenericExpressionQuery.projectId(let projectId):
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
        case GenericExpressionQuery.value(let value):
            return expressionDocuments
                .filter { $0.defaultValue.lowercased().contains(value.lowercased()) }
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
            return expressionDocuments
                .map { document in
                    let translations = translationDocuments
                        .filter {
                            $0.expressionID == document.id &&
                                $0.languageCode == languageCode &&
                                $0.scriptCode == nil &&
                                $0.regionCode == nil
                        }
                        .map {
                            Translation(document: $0)
                        }

                    return TranslationCatalog.Expression(document: document, translations: translations)
                }
                .filter { !$0.translations.isEmpty }
        case GenericExpressionQuery.translationsHaving(let languageCode, let scriptCode, let regionCode):
            return expressionDocuments
                .map { document in
                    let translations = translationDocuments
                        .filter {
                            $0.expressionID == document.id &&
                                $0.languageCode == languageCode &&
                                $0.scriptCode == scriptCode &&
                                $0.regionCode == regionCode
                        }
                        .map {
                            Translation(document: $0)
                        }

                    return TranslationCatalog.Expression(document: document, translations: translations)
                }
                .filter { !$0.translations.isEmpty }
        case GenericExpressionQuery.translationsHavingState(let state):
            return expressionDocuments
                .map { document in
                    let translations = translationDocuments
                        .filter {
                            $0.expressionID == document.id &&
                                $0.state == state
                        }
                        .map {
                            Translation(document: $0)
                        }

                    return TranslationCatalog.Expression(document: document, translations: translations)
                }
                .filter { !$0.translations.isEmpty }
        case GenericExpressionQuery.withoutAllLocales(let locales):
            let expressions = expressionDocuments
                .map { document in
                    let translations = translationDocuments
                        .filter { $0.expressionID == document.id }
                        .map {
                            Translation(document: $0)
                        }

                    return Expression(document: document, translations: translations)
                }
            return expressions.filter { !$0.hasValuesForLocales(locales) }
        default:
            throw CatalogError.unhandledQuery(query)
        }
    }

    public func expression(_ id: TranslationCatalog.Expression.ID) throws -> TranslationCatalog.Expression {
        try expression(matching: GenericExpressionQuery.id(id))
    }

    public func expression(matching query: CatalogQuery) throws -> TranslationCatalog.Expression {
        let document: ExpressionDocument

        switch query {
        case GenericExpressionQuery.id(let uuid):
            guard let doc = expressionDocuments.first(where: { $0.id == uuid }) else {
                throw CatalogError.expressionId(uuid)
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

    public func createExpression(_ expression: TranslationCatalog.Expression) throws -> TranslationCatalog.Expression.ID {
        if expression.id != .zero {
            if let existing = try? self.expression(expression.id) {
                throw CatalogError.expressionId(existing.id)
            }
        }

        if let existing = try? self.expression(matching: GenericExpressionQuery.key(expression.key)) {
            throw CatalogError.expressionExistingWithKey(expression.key, existing)
        }

        let id = expression.id != .zero ? expression.id : UUID()
        let translations = expression.translations.map {
            Translation(translation: $0, expressionId: id)
        }

        let _ = try translations.map {
            try createTranslation($0)
        }

        let document = ExpressionDocument(
            id: id,
            key: expression.key,
            name: expression.name,
            defaultLanguage: expression.defaultLanguageCode,
            defaultValue: expression.defaultValue,
            context: expression.context,
            feature: expression.feature
        )

        try writeDocument(document)
        expressionDocuments.append(document)
        return id
    }

    public func updateExpression(_ id: TranslationCatalog.Expression.ID, action: CatalogUpdate) throws {
        guard let index = expressionDocuments.firstIndex(where: { $0.id == id }) else {
            throw CatalogError.expressionId(id)
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
        case GenericExpressionUpdate.defaultValue(let value):
            expressionDocuments[index].defaultValue = value
        default:
            throw CatalogError.unhandledUpdate(action)
        }

        let document = expressionDocuments[index]
        try writeDocument(document)
    }

    public func deleteExpression(_ id: TranslationCatalog.Expression.ID) throws {
        guard let index = expressionDocuments.firstIndex(where: { $0.id == id }) else {
            throw CatalogError.expressionId(id)
        }

        let translationIds = translationDocuments
            .filter { $0.expressionID == id }
            .map(\.id)

        try translationIds.forEach { translationId in
            guard let idx = translationDocuments.firstIndex(where: { $0.id == translationId }) else {
                return
            }

            let document = translationDocuments.remove(at: idx)
            try removeDocument(document)
        }

        let projectIds = projectDocuments
            .filter { $0.expressionIds.contains(id) }
            .map(\.id)

        try projectIds.forEach { projectId in
            guard let idx = projectDocuments.firstIndex(where: { $0.id == projectId }) else {
                return
            }

            projectDocuments[idx].expressionIds.remove(id)
            let document = projectDocuments[idx]
            try writeDocument(document)
        }

        let document = expressionDocuments.remove(at: index)
        try removeDocument(document)
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
        case GenericTranslationQuery.expressionId(let expressionId):
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

            if let scriptCode {
                documents.removeAll(where: { $0.scriptCode != scriptCode })
            }
            if let regionCode {
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
                throw CatalogError.translationId(uuid)
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
                throw CatalogError.translationId(existing.id)
            }
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

        let id = translation.id != .zero ? translation.id : UUID()
        let document = TranslationDocument(
            id: id,
            expressionID: translation.expressionId,
            value: translation.value,
            languageCode: translation.language,
            scriptCode: translation.script,
            regionCode: translation.region,
            state: translation.state
        )

        try writeDocument(document)
        translationDocuments.append(document)
        return id
    }

    public func updateTranslation(_ id: Translation.ID, action: CatalogUpdate) throws {
        guard let index = translationDocuments.firstIndex(where: { $0.id == id }) else {
            throw CatalogError.translationId(id)
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
        case GenericTranslationUpdate.state(let state):
            translationDocuments[index].state = state
        default:
            throw CatalogError.unhandledUpdate(action)
        }

        let document = translationDocuments[index]
        try writeDocument(document)
    }

    public func deleteTranslation(_ id: Translation.ID) throws {
        guard let index = translationDocuments.firstIndex(where: { $0.id == id }) else {
            throw CatalogError.translationId(id)
        }

        let document = translationDocuments.remove(at: index)
        try removeDocument(document)
    }

    // MARK: - Metadata

    public func locales() throws -> Set<Locale> {
        let expressionLocales = Set(
            expressionDocuments.map { Locale(languageCode: $0.defaultLanguage) }
        )

        let translationLocales = Set(
            translationDocuments
                .map { translation in
                    Locale(languageCode: translation.languageCode, script: translation.scriptCode, languageRegion: translation.regionCode)
                }
        )

        return expressionLocales.union(translationLocales)
    }
}
