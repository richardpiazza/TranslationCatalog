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

    /// Verify `Expression` entities can be retrieved using a loose `name`.
    func assertQueryExpressionsNamed() throws {
        let expressions = try expressions(matching: GenericExpressionQuery.named("ull"))
        XCTAssertEqual(expressions.count, 2)
    }

    /// Verify `Expression` entities can be retrieved using a loose `key`.
    func assertQueryExpressionsKeyed() throws {
        let expressions = try expressions(matching: GenericExpressionQuery.key("button"))
        XCTAssertEqual(expressions.count, 2)
    }

    /// Verify `Expression` entities can be retrieved matching _having_ statements.
    func assertQueryExpressionsHaving() throws {
        var expressions = try expressions(matching: GenericExpressionQuery.translationsHaving(.french, nil, nil))
        XCTAssertEqual(expressions.count, 3)
        expressions = try self.expressions(matching: GenericExpressionQuery.translationsHaving(.french, nil, .canada))
        XCTAssertEqual(expressions.count, 1)
    }

    /// Verify `Expression` entities can be retrieved matching _having only_ statements.
    func assertQueryExpressionsHavingOnly() throws {
        let expressions = try expressions(matching: GenericExpressionQuery.translationsHavingOnly(.french))
        XCTAssertEqual(expressions.count, 3)
    }

    /// Verify a `Expression` entity can be retrieved by `id`.
    func assertQueryExpressionId() throws {
        let expression = try expression(.expression4)
        XCTAssertEqual(expression.name, "Fully Qualified Domain Name")
    }

    /// Verify a `Expression` entity can be retrieved by `key`.
    func assertQueryExpressionKey() throws {
        let expression = try expression(matching: GenericExpressionQuery.key("GIT_FQDN"))
        XCTAssertEqual(expression.id, .expression4)
    }

    /// Verify an expected number of existing `Translation`.
    func assertQueryTranslations() throws {
        let translations = try translations()
        XCTAssertEqual(translations.count, 13)
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
        XCTAssertEqual(translation.localeIdentifier, "zh-Hans")
    }

    func assertLocaleIdentifiers() throws {
        let localeIdentifiers = try locales().map(\.identifier)
        XCTAssertEqual(localeIdentifiers.count, 6)
        XCTAssertEqual(localeIdentifiers.sorted(), [
            "en",
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
        name: "Save",
        defaultLanguageCode: .english,
        context: "Button/Action Title",
        feature: "Buttons",
        translations: [translation1, translation2, translation3]
    )
    static let expression2 = Expression(
        id: .expression2,
        key: "BUTTON_DELETE",
        name: "Delete",
        defaultLanguageCode: .english,
        context: "Button/Action Title",
        feature: "Buttons",
        translations: [translation4, translation5, translation6]
    )
    static let expression3 = Expression(
        id: .expression3,
        key: "COMMON_PULL_TO_REFRESH",
        name: "Pull to Refresh",
        defaultLanguageCode: .english,
        context: "Manual Refresh Action",
        feature: "Common",
        translations: [translation7, translation8, translation9]
    )
    static let expression4 = Expression(
        id: .expression4,
        key: "GIT_FQDN",
        name: "Fully Qualified Domain Name",
        defaultLanguageCode: .english,
        context: "Test Entry Prompt",
        feature: "Git,Internet",
        translations: [translation10]
    )
    static let expression5 = Expression(
        id: .expression5,
        key: "AUTH_FAILURE_MESSAGE",
        name: "Authentication Failure Message",
        defaultLanguageCode: .english,
        context: "Authentication Alert Message",
        feature: "Alert,Auth",
        translations: [translation11, translation12, translation13]
    )
    static let translation1 = TranslationCatalog.Translation(id: .translation1, expressionId: .expression1, language: .english, script: nil, region: nil, value: "Save")
    static let translation2 = TranslationCatalog.Translation(id: .translation2, expressionId: .expression1, language: .spanish, script: nil, region: nil, value: "Guardar")
    static let translation3 = TranslationCatalog.Translation(id: .translation3, expressionId: .expression1, language: .french, script: nil, region: nil, value: "Sauvegarder")
    static let translation4 = TranslationCatalog.Translation(id: .translation4, expressionId: .expression2, language: .english, script: nil, region: nil, value: "Delete")
    static let translation5 = TranslationCatalog.Translation(id: .translation5, expressionId: .expression2, language: .spanish, script: nil, region: nil, value: "Eliminar")
    static let translation6 = TranslationCatalog.Translation(id: .translation6, expressionId: .expression2, language: .french, script: nil, region: nil, value: "Effacer")
    static let translation7 = TranslationCatalog.Translation(id: .translation7, expressionId: .expression3, language: .english, script: nil, region: nil, value: "Pull to Refresh")
    static let translation8 = TranslationCatalog.Translation(id: .translation8, expressionId: .expression3, language: .chinese, script: .hanSimplified, region: nil, value: "拉刷新")
    static let translation9 = TranslationCatalog.Translation(id: .translation9, expressionId: .expression3, language: .portuguese, script: nil, region: .brazil, value: "Puxe para Atualizar")
    static let translation10 = TranslationCatalog.Translation(id: .translation10, expressionId: .expression4, language: .english, script: nil, region: nil, value: "Fully Qualified Domain Name")
    static let translation11 = TranslationCatalog.Translation(id: .translation11, expressionId: .expression5, language: .english, script: nil, region: nil, value: "The server '%@' rejected the provided credentials.")
    static let translation12 = TranslationCatalog.Translation(id: .translation12, expressionId: .expression5, language: .french, script: nil, region: nil, value: "Le serveur '%@' a rejeté les informations d'identification fournies.")
    static let translation13 = TranslationCatalog.Translation(id: .translation13, expressionId: .expression5, language: .french, script: nil, region: .canada, value: "Le serveur '%@' a rejeté les informations d'identification fournies, eh.")
}

extension UUID {
    static let project1 = UUID(uuidString: "4D9141CF-320C-4691-99CC-7EF6BBA72D4B")!
    static let project2 = UUID(uuidString: "C2877D13-5B29-46F7-91A0-B12DDD3905D5")!
    static let project3 = UUID(uuidString: "0E4FB1D0-A626-4A59-A1DA-6901EDC4237A")!
    static let expression1 = UUID(uuidString: "C809EBF8-3BFB-4C69-84DF-CEA3BDBAF56A")!
    static let expression2 = UUID(uuidString: "AB26F147-1D9E-4D16-92D1-8BAFAC895364")!
    static let expression3 = UUID(uuidString: "DC767BE1-BD00-466B-BBDF-A8DE777E015F")!
    static let expression4 = UUID(uuidString: "6B6D0486-9710-4FCF-B45B-DDF1B78D09B4")!
    static let expression5 = UUID(uuidString: "77A8CE6A-3FC2-4E7E-86D7-CC24E9B43E00")!
    static let translation1 = UUID(uuidString: "AC765DB4-AD11-4B3F-8CA8-E05E6AC75118")!
    static let translation2 = UUID(uuidString: "CFEE0A77-5C7D-49E0-802A-0D5305EC29F4")!
    static let translation3 = UUID(uuidString: "D14E5F3F-9E8D-46C5-B0A5-5B01FAB43F7E")!
    static let translation4 = UUID(uuidString: "CC2D0B15-B3ED-4C17-9C5F-F4DEF8ADFF7D")!
    static let translation5 = UUID(uuidString: "B17407BB-E067-4AEB-B4C4-02C2FC7ECE8F")!
    static let translation6 = UUID(uuidString: "0EF156BC-8674-47E0-9C81-5ED228695770")!
    static let translation7 = UUID(uuidString: "3653E6DB-2555-4ACB-B5DA-4DD99836587D")!
    static let translation8 = UUID(uuidString: "9D0285EB-273D-4A06-BC40-CC78A1DD17E9")!
    static let translation9 = UUID(uuidString: "89A21E95-D421-4BA0-870A-C869E307711F")!
    static let translation10 = UUID(uuidString: "2878142D-DDC5-4700-8AF6-E97CD68D99CE")!
    static let translation11 = UUID(uuidString: "3C48632D-C5FD-4307-A5DB-96FD1C0C5828")!
    static let translation12 = UUID(uuidString: "42DFEB9F-C9E6-457A-9F4E-EEAF645C9E0B")!
    static let translation13 = UUID(uuidString: "D57844A7-68D6-45E6-A260-CD7C5BC708D3")!
}
