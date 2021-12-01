import XCTest
import LocaleSupport
import TranslationCatalog
import TranslationCatalogSQLite

final class CatalogQueryTests: _CatalogTestCase {
    
    lazy var project1: Project = {
        .init(uuid: .project1, name: "Bakeshop", expressions: [expression1, expression2])
    }()
    lazy var project2: Project = {
        .init(uuid: .project2, name: "Shopclass", expressions: [expression1, expression2, expression3])
    }()
    lazy var project3: Project = {
        .init(uuid: .project3, name: "Classmate", expressions: [expression1, expression5])
    }()
    lazy var expression1: Expression = {
        .init(uuid: .expression1, key: "BUTTON_SAVE", name: "Save", defaultLanguage: .en, context: "Button/Action Title", feature: "Buttons", translations: [translation1, translation2, translation3])
    }()
    lazy var expression2: Expression = {
        .init(uuid: .expression2, key: "BUTTON_DELETE", name: "Delete", defaultLanguage: .en, context: "Button/Action Title", feature: "Buttons", translations: [translation4, translation5, translation6])
    }()
    lazy var expression3: Expression = {
        .init(uuid: .expression3, key: "COMMON_PULL_TO_REFRESH", name: "Pull to Refresh", defaultLanguage: .en, context: "Manual Refresh Action", feature: "Common", translations: [translation7, translation8, translation9])
    }()
    lazy var expression4: Expression = {
        .init(uuid: .expression4, key: "GIT_FQDN", name: "Fully Qualified Domain Name", defaultLanguage: .en, context: "Test Entry Prompt", feature: "Git,Internet", translations: [translation10])
    }()
    lazy var expression5: Expression = {
        .init(uuid: .expression5, key: "AUTH_FAILURE_MESSAGE", name: "Authentication Failure Message", defaultLanguage: .en, context: "Authentication Alert Message", feature: "Alert,Auth", translations: [translation11, translation12, translation13])
    }()
    lazy var translation1: TranslationCatalog.Translation = {
        .init(uuid: .translation1, expressionID: .expression1, languageCode: .en, scriptCode: nil, regionCode: nil, value: "Save")
    }()
    lazy var translation2: TranslationCatalog.Translation = {
        .init(uuid: .translation2, expressionID: .expression1, languageCode: .es, scriptCode: nil, regionCode: nil, value: "Guardar")
    }()
    lazy var translation3: TranslationCatalog.Translation = {
        .init(uuid: .translation3, expressionID: .expression1, languageCode: .fr, scriptCode: nil, regionCode: nil, value: "Sauvegarder")
    }()
    lazy var translation4: TranslationCatalog.Translation = {
        .init(uuid: .translation4, expressionID: .expression2, languageCode: .en, scriptCode: nil, regionCode: nil, value: "Delete")
    }()
    lazy var translation5: TranslationCatalog.Translation = {
        .init(uuid: .translation5, expressionID: .expression2, languageCode: .es, scriptCode: nil, regionCode: nil, value: "Eliminar")
    }()
    lazy var translation6: TranslationCatalog.Translation = {
        .init(uuid: .translation6, expressionID: .expression2, languageCode: .fr, scriptCode: nil, regionCode: nil, value: "Effacer")
    }()
    lazy var translation7: TranslationCatalog.Translation = {
        .init(uuid: .translation7, expressionID: .expression3, languageCode: .en, scriptCode: nil, regionCode: nil, value: "Pull to Refresh")
    }()
    lazy var translation8: TranslationCatalog.Translation = {
        .init(uuid: .translation8, expressionID: .expression3, languageCode: .zh, scriptCode: .Hans, regionCode: nil, value: "拉刷新")
    }()
    lazy var translation9: TranslationCatalog.Translation = {
        .init(uuid: .translation9, expressionID: .expression3, languageCode: .pt, scriptCode: nil, regionCode: .BR, value: "Puxe para Atualizar")
    }()
    lazy var translation10: TranslationCatalog.Translation = {
        .init(uuid: .translation10, expressionID: .expression4, languageCode: .en, scriptCode: nil, regionCode: nil, value: "Fully Qualified Domain Name")
    }()
    lazy var translation11: TranslationCatalog.Translation = {
        .init(uuid: .translation11, expressionID: .expression5, languageCode: .en, scriptCode: nil, regionCode: nil, value: "The server '%@' rejected the provided credentials.")
    }()
    lazy var translation12: TranslationCatalog.Translation = {
        .init(uuid: .translation12, expressionID: .expression5, languageCode: .fr, scriptCode: nil, regionCode: nil, value: "Le serveur '%@' a rejeté les informations d'identification fournies.")
    }()
    lazy var translation13: TranslationCatalog.Translation = {
        .init(uuid: .translation13, expressionID: .expression5, languageCode: .fr, scriptCode: nil, regionCode: .CA, value: "Le serveur '%@' a rejeté les informations d'identification fournies, eh.")
    }()
    
    var catalog: SQLiteCatalog!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        catalog = try SQLiteCatalog(url: url)
        
        try catalog.createProject(project1)
        try catalog.createProject(project2)
        try catalog.createProject(project3)
        try catalog.createExpression(expression4)
    }
    
    func testQueryProjects() throws {
        let projects = try catalog.projects()
        XCTAssertEqual(projects.count, 3)
    }
    
    func testQueryProjectsHierarchy() throws {
        let projects = try catalog.projects(matching: SQLiteCatalog.ProjectQuery.hierarchy)
        XCTAssertEqual(projects.count, 3)
        let p1 = try XCTUnwrap(projects.first(where:{ $0.id == .project1 }))
        let p2 = try XCTUnwrap(projects.first(where:{ $0.id == .project2 }))
        let p3 = try XCTUnwrap(projects.first(where:{ $0.id == .project3 }))
        XCTAssertEqual(p1.expressions.count, 2)
        XCTAssertEqual(p2.expressions.count, 3)
        XCTAssertEqual(p3.expressions.count, 2)
        XCTAssertEqual(p1.expressions[0], p3.expressions[0])
    }
    
    func testQueryProjectsNamed() throws {
        var projects = try catalog.projects(matching: GenericProjectQuery.named("shop"))
        XCTAssertEqual(projects.count, 2)
        projects = try catalog.projects(matching: GenericProjectQuery.named("class"))
        XCTAssertEqual(projects.count, 2)
    }
    
    func testQueryProjectId() throws {
        let project = try catalog.project(.project2)
        XCTAssertEqual(project.name, project2.name)
    }
    
    func testQueryProjectPrimaryKey() throws {
        let project = try catalog.project(matching: SQLiteCatalog.ProjectQuery.primaryKey(3))
        XCTAssertEqual(project.name, project3.name)
    }
    
    func testQueryProjectNamed() throws {
        XCTAssertThrowsError(try catalog.project(matching: GenericProjectQuery.named("class")))
        let project = try catalog.project(matching: GenericProjectQuery.named("Shopclass"))
        XCTAssertEqual(project.id, .project2)
    }
    
    func testQueryExpressions() throws {
        let expressions = try catalog.expressions()
        XCTAssertEqual(expressions.count, 5)
    }
    
    func testQueryExpressionsHierarchy() throws {
        let expressions = try catalog.expressions(matching: SQLiteCatalog.ExpressionQuery.hierarchy)
        XCTAssertEqual(expressions.count, 5)
        let e1 = try XCTUnwrap(expressions.first(where:{ $0.id == .expression1 }))
        let e2 = try XCTUnwrap(expressions.first(where:{ $0.id == .expression2 }))
        let e3 = try XCTUnwrap(expressions.first(where:{ $0.id == .expression3 }))
        let e4 = try XCTUnwrap(expressions.first(where:{ $0.id == .expression4 }))
        let e5 = try XCTUnwrap(expressions.first(where:{ $0.id == .expression5 }))
        XCTAssertEqual(e1.translations.count, 3)
        XCTAssertEqual(e2.translations.count, 3)
        XCTAssertEqual(e3.translations.count, 3)
        XCTAssertEqual(e4.translations.count, 1)
        XCTAssertEqual(e5.translations.count, 3)
    }
    
    func testQueryExpressionsProjectID() throws {
        let expressions = try catalog.expressions(matching: GenericExpressionQuery.projectID(.project3))
        XCTAssertEqual(expressions.count, 2)
    }
    
    func testQueryExpressionsNamed() throws {
        let expressions = try catalog.expressions(matching: GenericExpressionQuery.named("ull"))
        XCTAssertEqual(expressions.count, 2)
    }
    
    func testQueryExpressionsHaving() throws {
        var expressions = try catalog.expressions(matching: GenericExpressionQuery.translationsHaving(.fr, nil, nil))
        XCTAssertEqual(expressions.count, 3)
        expressions = try catalog.expressions(matching: GenericExpressionQuery.translationsHaving(.fr, nil, .CA))
        XCTAssertEqual(expressions.count, 1)
    }
    
    func testQueryExpressionsHavingOnly() throws {
        let expressions = try catalog.expressions(matching: GenericExpressionQuery.translationsHavingOnly(.fr))
        XCTAssertEqual(expressions.count, 3)
    }
    
    func testQueryExpressionId() throws {
        let expression = try catalog.expression(.expression4)
        XCTAssertEqual(expression.name, "Fully Qualified Domain Name")
    }
    
    func testQueryExpressionPrimaryKey() throws {
        let expression = try catalog.expression(matching: SQLiteCatalog.ExpressionQuery.primaryKey(2))
        XCTAssertEqual(expression.key, "BUTTON_DELETE")
    }
    
    func testQueryTranslations() throws {
        let translations = try catalog.translations()
        XCTAssertEqual(translations.count, 13)
    }
    
    func testQueryTranslationsExpressionId() throws {
        let translations = try catalog.translations(matching: GenericTranslationQuery.expressionID(.expression3))
        XCTAssertEqual(translations.count, 3)
    }
    
    func testQueryTranslationsHaving() throws {
        var translations = try catalog.translations(matching: GenericTranslationQuery.having(.expression5, .fr, nil, nil))
        XCTAssertEqual(translations.count, 2)
        translations = try catalog.translations(matching: GenericTranslationQuery.having(.expression5, .fr, nil, .CA))
        XCTAssertEqual(translations.count, 1)
    }
    
    func testQueryTranslationsHavingOnly() throws {
        let translations = try catalog.translations(matching: GenericTranslationQuery.havingOnly(.expression5, .fr))
        XCTAssertEqual(translations.count, 1)
    }
    
    func testQueryTranslationId() throws {
        let translation = try catalog.translation(.translation8)
        XCTAssertEqual(translation.localeIdentifier, "zh-Hans")
    }
    
    func testQueryTranslationPrimaryKey() throws {
        let translation = try catalog.translation(matching: SQLiteCatalog.TranslationQuery.primaryKey(9))
        XCTAssertEqual(translation.regionCode, .BR)
    }
}

private extension UUID {
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
