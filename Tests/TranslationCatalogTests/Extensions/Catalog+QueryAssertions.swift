@testable import TranslationCatalog
import XCTest

extension Catalog {
    /// Prepare a `Catalog` with example data.
    func assertPrepare() throws {
        try createProject(CatalogData.project1)
        try createProject(CatalogData.project2)
        try createProject(CatalogData.project3)
        try createExpression(CatalogData.expression4)
    }

    /// Verify an expected number of existing `Project`.
    func assertQueryProjects() throws {
        let projects = try projects()
        XCTAssertEqual(projects.count, 3)
    }

    /// Verify that existing `Project`s can be found loosely matching the `name`.
    func assertQueryProjectsNamed() throws {
        var projects = try projects(matching: GenericProjectQuery.named("shop"))
        XCTAssertEqual(projects.count, 2)
        projects = try self.projects(matching: GenericProjectQuery.named("class"))
        XCTAssertEqual(projects.count, 2)
    }

    /// Verify that a list of `Project`s can be found associated to an `Expression.ID`.
    func assertQueryProjectsExpressionID() throws {
        var projects = try projects(matching: GenericProjectQuery.expressionId(.expression2))
        XCTAssertEqual(projects.count, 2)
        projects = try self.projects(matching: GenericProjectQuery.expressionId(.expression5))
        XCTAssertEqual(projects.count, 1)
    }

    /// Verify that an existing `Project` can be found using its `id`.
    func assertQueryProjectId() throws {
        let project = try project(.project2)
        XCTAssertEqual(project.name, CatalogData.project2.name)
    }

    /// Verify that an existing `Project` can be found using its exact `name`.
    func assertQueryProjectNamed() throws {
        XCTAssertThrowsError(try self.project(matching: GenericProjectQuery.named("class")))
        let project = try project(matching: GenericProjectQuery.named("Shopclass"))
        XCTAssertEqual(project.id, .project2)
    }

    /// Verify an expected number of existing `Expression`.
    func assertQueryExpressions() throws {
        let expressions = try expressions()
        XCTAssertEqual(expressions.count, 5)
    }

    /// Verify that existing `Expression`s can be found using a `Project.ID`.
    func assertQueryExpressionsProjectID() throws {
        let expressions = try expressions(matching: GenericExpressionQuery.projectId(.project3))
        XCTAssertEqual(expressions.count, 2)
    }

    /// Verify `Expression` entities can be retrieved using a loose `key`.
    func assertQueryExpressionsKeyed() throws {
        let expressions = try expressions(matching: GenericExpressionQuery.key("button"))
        XCTAssertEqual(expressions.count, 2)
    }

    /// Verify `Expression` entities can be retrieved using a loose `defaultValue`.
    func assertQueryExpressionsValued() throws {
        let expressions = try expressions(matching: GenericExpressionQuery.value("ull"))
        XCTAssertEqual(expressions.count, 2)
    }

    /// Verify `Expression` entities can be retrieved matching _having_ statements.
    func assertQueryExpressionsHaving() throws {
        var expressions = try expressions(matching: GenericExpressionQuery.translationsHaving(.french, nil, nil))
        XCTAssertEqual(expressions.count, 3)
        expressions = try self.expressions(matching: GenericExpressionQuery.translationsHaving(.french, nil, .canada))
        XCTAssertEqual(expressions.count, 2)
    }

    /// Verify `Expression` entities can be retrieved matching _having only_ statements.
    func assertQueryExpressionsHavingOnly() throws {
        let expressions = try expressions(matching: GenericExpressionQuery.translationsHavingOnly(.french))
        XCTAssertEqual(expressions.count, 3)
    }

    func assertQueryExpressionsHavingState() throws {
        let expressions = try expressions(matching: GenericExpressionQuery.translationsHavingState(.needsReview))
        XCTAssertEqual(expressions.count, 4)
    }

    func assertQueryExpressionsWithoutAllLocales() throws {
        let locales = [
            "en",
            "en_GB",
            "es",
            "fr",
            "fr_CA",
            "pt_BR",
            "zh-Hans",
        ].map { Locale(identifier: $0) }
        let expressions = try expressions(matching: GenericExpressionQuery.withoutAllLocales(Set(locales)))
        XCTAssertEqual(expressions.count, 4)
    }

    /// Verify a `Expression` entity can be retrieved by `id`.
    func assertQueryExpressionId() throws {
        let expression = try expression(.expression4)
        XCTAssertEqual(expression.defaultValue, "Fully Qualified Domain Name")
    }

    /// Verify a `Expression` entity can be retrieved by `key`.
    func assertQueryExpressionKey() throws {
        let expression = try expression(matching: GenericExpressionQuery.key("GIT_FQDN"))
        XCTAssertEqual(expression.id, .expression4)
    }

    /// Verify an expected number of existing `Translation`.
    func assertQueryTranslations() throws {
        let translations = try translations()
        XCTAssertEqual(translations.count, 16)
    }

    /// Verify that existing `Translation`s can be found using a `Expression.ID`.
    func assertQueryTranslationsExpressionId() throws {
        let translations = try translations(matching: GenericTranslationQuery.expressionId(.expression3))
        XCTAssertEqual(translations.count, 3)
    }

    /// Verify `Translation` entities can be retrieved matching _having_ statements.
    func assertQueryTranslationsHaving() throws {
        var translations = try translations(matching: GenericTranslationQuery.having(.expression5, .french, nil, nil))
        XCTAssertEqual(translations.count, 2)
        translations = try self.translations(matching: GenericTranslationQuery.having(.expression5, .french, nil, .canada))
        XCTAssertEqual(translations.count, 1)
    }

    /// Verify `Translation` entities can be retrieved matching _having only_ statements.
    func assertQueryTranslationsHavingOnly() throws {
        let translations = try translations(matching: GenericTranslationQuery.havingOnly(.expression5, .french))
        XCTAssertEqual(translations.count, 1)
    }

    /// Verify a `Translation` entity can be retrieved by `id`.
    func assertQueryTranslationId() throws {
        let translation = try translation(.translation8)
        XCTAssertEqual(translation.locale.identifier, "zh-Hans")
    }

    func assertLocales() throws {
        let localeIdentifiers = try locales().map(\.identifier)
        XCTAssertEqual(localeIdentifiers.count, 7)
        XCTAssertEqual(localeIdentifiers.sorted(), [
            "en",
            "en_GB",
            "es",
            "fr",
            "fr_CA",
            "pt_BR",
            "zh-Hans",
        ])
    }
}

enum CatalogData {
    static let project1 = Project(
        id: .project1,
        name: "Bakeshop",
        expressions: [expression1, expression2]
    )
    static let project2 = Project(
        id: .project2,
        name: "Shopclass",
        expressions: [expression1, expression2, expression3]
    )
    static let project3 = Project(
        id: .project3,
        name: "Classmate",
        expressions: [expression1, expression5]
    )
    static let expression1 = Expression(
        id: .expression1,
        key: "BUTTON_SAVE",
        value: "Save",
        languageCode: .english,
        context: "Button/Action Title",
        feature: "Buttons",
        translations: [translation1, translation2, translation3, translation14, translation15, translation16]
    )
    static let expression2 = Expression(
        id: .expression2,
        key: "BUTTON_DELETE",
        value: "Delete",
        languageCode: .english,
        context: "Button/Action Title",
        feature: "Buttons",
        translations: [translation4, translation5, translation6]
    )
    static let expression3 = Expression(
        id: .expression3,
        key: "COMMON_PULL_TO_REFRESH",
        value: "Pull to Refresh",
        languageCode: .english,
        name: "Pull to Refresh",
        context: "Manual Refresh Action",
        feature: "Common",
        translations: [translation7, translation8, translation9]
    )
    static let expression4 = Expression(
        id: .expression4,
        key: "GIT_FQDN",
        value: "Fully Qualified Domain Name",
        languageCode: .english,
        name: "Fully Qualified Domain Name",
        context: "Test Entry Prompt",
        feature: "Git,Internet",
        translations: [translation10]
    )
    static let expression5 = Expression(
        id: .expression5,
        key: "AUTH_FAILURE_MESSAGE",
        value: "The server '%@' rejected the provided credentials.",
        languageCode: .english,
        name: "Authentication Failure Message",
        context: "Authentication Alert Message",
        feature: "Alert,Auth",
        translations: [translation11, translation12, translation13]
    )
    static let translation1 = TranslationCatalog.Translation(
        id: .translation1,
        expressionId: .expression1,
        value: "Save",
        language: .english,
        script: nil,
        region: .unitedKingdom,
        state: .translated
    )
    static let translation2 = TranslationCatalog.Translation(
        id: .translation2,
        expressionId: .expression1,
        value: "Guardar",
        language: .spanish,
        script: nil,
        region: nil,
        state: .translated
    )
    static let translation3 = TranslationCatalog.Translation(
        id: .translation3,
        expressionId: .expression1,
        value: "Sauvegarder",
        language: .french,
        script: nil,
        region: nil,
        state: .needsReview
    )
    static let translation4 = TranslationCatalog.Translation(
        id: .translation4,
        expressionId: .expression2,
        value: "Delete",
        language: .english,
        script: nil,
        region: .unitedKingdom,
        state: .translated
    )
    static let translation5 = TranslationCatalog.Translation(
        id: .translation5,
        expressionId: .expression2,
        value: "Eliminar",
        language: .spanish,
        script: nil,
        region: nil,
        state: .translated
    )
    static let translation6 = TranslationCatalog.Translation(
        id: .translation6,
        expressionId: .expression2,
        value: "Effacer",
        language: .french,
        script: nil,
        region: nil,
        state: .needsReview
    )
    static let translation7 = TranslationCatalog.Translation(
        id: .translation7,
        expressionId: .expression3,
        value: "Pull to Refresh",
        language: .english,
        script: nil,
        region: .unitedKingdom,
        state: .translated
    )
    static let translation8 = TranslationCatalog.Translation(
        id: .translation8,
        expressionId: .expression3,
        value: "拉刷新",
        language: .chinese,
        script: .hanSimplified,
        region: nil,
        state: .needsReview
    )
    static let translation9 = TranslationCatalog.Translation(
        id: .translation9,
        expressionId: .expression3,
        value: "Puxe para Atualizar",
        language: .portuguese,
        script: nil,
        region: .brazil,
        state: .needsReview
    )
    static let translation10 = TranslationCatalog.Translation(
        id: .translation10,
        expressionId: .expression4,
        value: "Fully Qualified Domain Name",
        language: .english,
        script: nil,
        region: .unitedKingdom,
        state: .translated
    )
    static let translation11 = TranslationCatalog.Translation(
        id: .translation11,
        expressionId: .expression5,
        value: "The server '%@' rejected the provided credentials.",
        language: .english,
        script: nil,
        region: .unitedKingdom,
        state: .translated
    )
    static let translation12 = TranslationCatalog.Translation(
        id: .translation12,
        expressionId: .expression5,
        value: "Le serveur '%@' a rejeté les informations d'identification fournies.",
        language: .french,
        script: nil,
        region: nil,
        state: .needsReview
    )
    static let translation13 = TranslationCatalog.Translation(
        id: .translation13,
        expressionId: .expression5,
        value: "Le serveur '%@' a rejeté les informations d'identification fournies, eh.",
        language: .french,
        script: nil,
        region: .canada,
        state: .needsReview
    )
    static let translation14 = TranslationCatalog.Translation(
        id: .translation14,
        expressionId: .expression1,
        value: "sauver",
        language: .french,
        script: nil,
        region: .canada,
        state: .needsReview
    )
    static let translation15 = TranslationCatalog.Translation(
        id: .translation15,
        expressionId: .expression1,
        value: "Guardar",
        language: .portuguese,
        script: nil,
        region: .brazil,
        state: .needsReview
    )
    static let translation16 = TranslationCatalog.Translation(
        id: .translation16,
        expressionId: .expression1,
        value: "保存",
        language: .chinese,
        script: .hanSimplified,
        region: nil,
        state: .needsReview
    )
}
