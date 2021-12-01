import XCTest
import LocaleSupport
import TranslationCatalog
import TranslationCatalogSQLite

final class CatalogInsertTests: _CatalogTestCase {
    
    /// Verify that a `Project` can be added to the catalog.
    func testInsertProject() throws {
        let projectId = UUID(uuidString: "64BBF2A8-0423-4545-B3E1-4A373F6359AF")!
        let project = Project(uuid: projectId, name: "Project 1")
        
        func preConditions(catalog: SQLiteCatalog) throws {
            let projects = try catalog.projects()
            XCTAssertEqual(projects.count, 0)
        }
        
        func postConditions(catalog: SQLiteCatalog) throws {
            let projects = try catalog.projects()
            XCTAssertEqual(projects.count, 1)
            let entity = try XCTUnwrap(projects.first)
            XCTAssertEqual(projectId, entity.id)
            XCTAssertEqual(project.name, entity.name)
        }
        
        let catalog = try SQLiteCatalog(url: url)
        try preConditions(catalog: catalog)
        try catalog.createProject(project)
        try postConditions(catalog: catalog)
    }
    
    /// Verify that a `Expression` can be added to the catalog.
    func testInsertExpression() throws {
        let expressionId = UUID(uuidString: "A2A5A62D-D532-4FEB-8905-9DBFFC77C07E")!
        let expression = Expression(uuid: expressionId, key: "EXP_1", name: "Test Expression", defaultLanguage: .en, context: "Generic Message", feature: "Settings")
        
        func preConditions(catalog: SQLiteCatalog) throws {
            let expressions = try catalog.expressions()
            XCTAssertEqual(expressions.count, 0)
        }
        
        func postConditions(catalog: SQLiteCatalog) throws {
            let expressions = try catalog.expressions()
            XCTAssertEqual(expressions.count, 1)
            let entity = try XCTUnwrap(expressions.first)
            XCTAssertEqual(entity.id, expressionId)
            XCTAssertEqual(entity.key, "EXP_1")
            XCTAssertEqual(entity.name, "Test Expression")
            XCTAssertEqual(entity.defaultLanguage, .en)
            XCTAssertEqual(entity.context, "Generic Message")
            XCTAssertEqual(entity.feature, "Settings")
        }
        
        let catalog = try SQLiteCatalog(url: url)
        try preConditions(catalog: catalog)
        try catalog.createExpression(expression)
        try postConditions(catalog: catalog)
    }
    
    /// Verify that a `Translation` can be added to the catalog.
    func testInsertTranslation() throws {
        let expressionId = UUID(uuidString: "A2A5A62D-D532-4FEB-8905-9DBFFC77C07E")!
        let expression = Expression(uuid: expressionId, key: "EXP_1", name: "Test Expression", defaultLanguage: .en, context: "Generic Message", feature: "Settings")
        let translationId = UUID(uuidString: "80F9B7D4-BFF5-41CC-8BB6-28A990864046")!
        let translation = TranslationCatalog.Translation(uuid: translationId, expressionID: expressionId, languageCode: .en, scriptCode: nil, regionCode: .US, value: "Party-on Wayne!")
        
        func preConditions(catalog: SQLiteCatalog) throws {
            try catalog.createExpression(expression)
            let translations = try catalog.translations()
            XCTAssertEqual(translations.count, 0)
        }
        
        func postConditions(catalog: SQLiteCatalog) throws {
            let translations = try catalog.translations()
            XCTAssertEqual(translations.count, 1)
            let entity = try XCTUnwrap(translations.first)
            XCTAssertEqual(entity.id, translationId)
            XCTAssertEqual(entity.expressionID, expressionId)
            XCTAssertEqual(entity.languageCode, .en)
            XCTAssertNil(entity.scriptCode)
            XCTAssertEqual(entity.regionCode, .US)
            XCTAssertEqual(entity.value, "Party-on Wayne!")
        }
        
        let catalog = try SQLiteCatalog(url: url)
        try preConditions(catalog: catalog)
        try catalog.createTranslation(translation)
        try postConditions(catalog: catalog)
    }
    
    /// Verify that a `Project` can be added to the catalog, and the related `Expression`s are created as well.
    func testInsertProject_CascadeExpressions() throws {
        let expressionId = UUID(uuidString: "1721B307-9A67-4FC1-A529-3A128695E802")!
        let expression = Expression(uuid: expressionId, key: "BUTTON_NEXT", name: "Next", defaultLanguage: .en, context: "Button Title", feature: "Buttons")
        let projectId = UUID(uuidString: "CB3900B9-C4A8-4953-9CF7-C737323954E9")!
        let project = Project(uuid: projectId, name: "", expressions: [expression])
        
        func preConditions(catalog: SQLiteCatalog) throws {
            let projects = try catalog.projects()
            XCTAssertEqual(projects.count, 0)
            let expressions = try catalog.expressions()
            XCTAssertEqual(expressions.count, 0)
        }
        
        func postConditions(catalog: SQLiteCatalog) throws {
            let expressions = try catalog.expressions()
            XCTAssertEqual(expressions.count, 1)
            let projects = try catalog.projects()
            XCTAssertEqual(projects.count, 1)
        }
        
        let catalog = try SQLiteCatalog(url: url)
        try preConditions(catalog: catalog)
        try catalog.createProject(project)
        try postConditions(catalog: catalog)
    }
    
    /// Verify that a `Expression` can be added to the catalog, and the related `Translation`s are created as well.
    func testInsertExpression_CascadeTranslations() throws {
        let translationId = UUID(uuidString: "1C013C96-AEC7-4F05-AC24-F5DF547B77AA")!
        // It shouldn't matter that the correct expressionId is set here... the catalog will auto-override
        let translation = TranslationCatalog.Translation(uuid: translationId, expressionID: .zero, languageCode: .en, scriptCode: nil, regionCode: .US, value: "Next")
        let expressionId = UUID(uuidString: "1721B307-9A67-4FC1-A529-3A128695E802")!
        let expression = Expression(uuid: expressionId, key: "BUTTON_NEXT", name: "Next", defaultLanguage: .en, context: "Button Title", feature: "Buttons", translations: [translation])
        
        func preConditions(catalog: SQLiteCatalog) throws {
            let expressions = try catalog.expressions()
            XCTAssertEqual(expressions.count, 0)
            let translations = try catalog.translations()
            XCTAssertEqual(translations.count, 0)
        }
        
        func postConditions(catalog: SQLiteCatalog) throws {
            let expressions = try catalog.expressions()
            XCTAssertEqual(expressions.count, 1)
            let translations = try catalog.translations()
            XCTAssertEqual(translations.count, 1)
        }
        
        let catalog = try SQLiteCatalog(url: url)
        try preConditions(catalog: catalog)
        try catalog.createExpression(expression)
        try postConditions(catalog: catalog)
    }
}
