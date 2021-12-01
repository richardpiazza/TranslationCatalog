import XCTest
import LocaleSupport
import TranslationCatalog
import TranslationCatalogSQLite

final class CatalogDeleteTests: _CatalogTestCase {
    
    /// Verify that a `Project` can be removed from the catalog.
    func testDeleteProject() throws {
        let projectId = UUID(uuidString: "06937A10-2E46-4FFD-A2E7-60A3F03ED007")!
        let project = Project(uuid: projectId, name: "Example Project")
        
        func preConditions(catalog: SQLiteCatalog) throws {
            try catalog.createProject(project)
            let projects = try catalog.projects()
            XCTAssertEqual(projects.count, 1)
        }
        
        func postConditions(catalog: SQLiteCatalog) throws {
            let projects = try catalog.projects()
            XCTAssertEqual(projects.count, 0)
        }
        
        let catalog = try SQLiteCatalog(url: url)
        try preConditions(catalog: catalog)
        try catalog.deleteProject(projectId)
        try postConditions(catalog: catalog)
    }
    
    /// Verify that a `Expression` can be removed from the catalog.
    func testDeleteExpression() throws {
        let expressionId = UUID(uuidString: "0503A67E-EAC5-4612-A91A-559477283C56")!
        let expression = Expression(uuid: expressionId, key: "TEST_EXPRESSION", name: "Test Expression", defaultLanguage: .en)

        func preConditions(catalog: SQLiteCatalog) throws {
            try catalog.createExpression(expression)
            let expressions = try catalog.expressions()
            XCTAssertEqual(expressions.count, 1)
        }
        
        func postConditions(catalog: SQLiteCatalog) throws {
            let expressions = try catalog.expressions()
            XCTAssertEqual(expressions.count, 0)
        }
        
        let catalog = try SQLiteCatalog(url: url)
        try preConditions(catalog: catalog)
        try catalog.deleteExpression(expressionId)
        try postConditions(catalog: catalog)
    }
    
    /// Verify that a `Translation` can be removed from the catalog.
    func testDeleteTranslation() throws {
        let expressionId = UUID(uuidString: "F590AA58-626D-4EAB-AEDA-21F047B9BA42")!
        let expression = Expression(uuid: expressionId, key: "TRACK_TITLE", name: "Track Title", defaultLanguage: .en)
        let translationId = UUID(uuidString: "A93E74CD-58F2-4D00-BA6B-F722FFCCCFBF")!
        let translation = TranslationCatalog.Translation(uuid: translationId, expressionID: expressionId, languageCode: .en, value: "Overture to Egmont, Op. 84")
        
        func preConditions(catalog: SQLiteCatalog) throws {
            try catalog.createExpression(expression)
            try catalog.createTranslation(translation)
            let translations = try catalog.translations()
            XCTAssertEqual(translations.count, 1)
        }
        
        func postConditions(catalog: SQLiteCatalog) throws {
            let translations = try catalog.translations()
            XCTAssertEqual(translations.count, 0)
        }
        
        let catalog = try SQLiteCatalog(url: url)
        try preConditions(catalog: catalog)
        try catalog.deleteTranslation(translationId)
        try postConditions(catalog: catalog)
    }
    
    /// Verify that a `Expression` can be removed from the catalog, and it's related `Translation` entities are also removed.
    func testDeleteExpression_CascadeTranslation() throws {
        let expressionId = UUID(uuidString: "F590AA58-626D-4EAB-AEDA-21F047B9BA42")!
        let expression = Expression(uuid: expressionId, key: "TRACK_TITLE", name: "Track Title", defaultLanguage: .en)
        let translationId = UUID(uuidString: "A93E74CD-58F2-4D00-BA6B-F722FFCCCFBF")!
        let translation = TranslationCatalog.Translation(uuid: translationId, expressionID: expressionId, languageCode: .en, value: "Overture to Egmont, Op. 84")
        
        func preConditions(catalog: SQLiteCatalog) throws {
            try catalog.createExpression(expression)
            try catalog.createTranslation(translation)
            let expressions = try catalog.expressions()
            XCTAssertEqual(expressions.count, 1)
            let translations = try catalog.translations()
            XCTAssertEqual(translations.count, 1)
        }
        
        func postConditions(catalog: SQLiteCatalog) throws {
            let expressions = try catalog.expressions()
            XCTAssertEqual(expressions.count, 0)
            let translations = try catalog.translations()
            XCTAssertEqual(translations.count, 0)
        }
        
        let catalog = try SQLiteCatalog(url: url)
        try preConditions(catalog: catalog)
        try catalog.deleteExpression(expressionId)
        try postConditions(catalog: catalog)
    }
    
    /// Verify that a `Project` can be removed from the catalog, and it's related `Expression` entities remain intact.
    func testDeleteProject_NullifyExpression() throws {
        let projectId = UUID(uuidString: "06937A10-2E46-4FFD-A2E7-60A3F03ED007")!
        let project = Project(uuid: projectId, name: "Example Project")
        let expressionId = UUID(uuidString: "F590AA58-626D-4EAB-AEDA-21F047B9BA42")!
        let expression = Expression(uuid: expressionId, key: "TRACK_TITLE", name: "Track Title", defaultLanguage: .en)
        
        func preConditions(catalog: SQLiteCatalog) throws {
            try catalog.createProject(project)
            try catalog.createExpression(expression)
            try catalog.updateProject(projectId, action: GenericProjectUpdate.linkExpression(expressionId))
            let projects = try catalog.projects()
            XCTAssertEqual(projects.count, 1)
            let expressions = try catalog.expressions()
            XCTAssertEqual(expressions.count, 1)
        }
        
        func postConditions(catalog: SQLiteCatalog) throws {
            let projects = try catalog.projects()
            XCTAssertEqual(projects.count, 0)
            let expressions = try catalog.expressions()
            XCTAssertEqual(expressions.count, 1)
        }
        
        let catalog = try SQLiteCatalog(url: url)
        
        try preConditions(catalog: catalog)
        try catalog.deleteProject(projectId)
        try postConditions(catalog: catalog)
    }
}
