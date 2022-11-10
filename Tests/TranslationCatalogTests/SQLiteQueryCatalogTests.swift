import XCTest
import LocaleSupport
@testable import TranslationCatalog
@testable import TranslationCatalogSQLite

final class SQLiteQueryCatalogTests: XCTestCase {
    
    private let fileManager: FileManager = .default
    
    /// Unique identifier for this execution run.
    private let executionId = UUID()
    
    /// Unique filename for this run.
    private lazy var fileName: String = { "\(executionId).sqlite" }()
    
    /// URL for the catalog used during this run.
    private lazy var url: URL = {
        let directory = URL(fileURLWithPath: fileManager.currentDirectoryPath, isDirectory: true)
        return directory.appendingPathComponent(fileName)
    }()
    
    /// Removes the temporarily created catalog during the execution.
    private func recycle() throws {
        guard fileManager.fileExists(atPath: url.path) else {
            return
        }
        
        try fileManager.removeItem(at: url)
    }
    
    private var catalog: SQLiteCatalog!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        catalog = try SQLiteCatalog(url: url)
        try catalog.assertPrepare()
    }
    
    override func tearDownWithError() throws {
        try recycle()
        try super.tearDownWithError()
    }
    
    func testProjectQueries() throws {
        try catalog.assertQueryProjects()
        try catalog.assertQueryProjectsNamed()
        try catalog.assertQueryProjectId()
        try catalog.assertQueryProjectNamed()
    }
    
    func testExpressionQueries() throws {
        try catalog.assertQueryExpressions()
        try catalog.assertQueryExpressionsProjectID()
        try catalog.assertQueryExpressionsNamed()
        try catalog.assertQueryExpressionsKeyed()
        try catalog.assertQueryExpressionsHaving()
        try catalog.assertQueryExpressionsHavingOnly()
        try catalog.assertQueryExpressionId()
        try catalog.assertQueryExpressionKey()
    }
    
    func testTranslationQueries() throws {
        try catalog.assertQueryTranslations()
        try catalog.assertQueryTranslationsExpressionId()
        try catalog.assertQueryTranslationsHaving()
        try catalog.assertQueryTranslationsHavingOnly()
        try catalog.assertQueryTranslationId()
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
    
    func testQueryProjectPrimaryKey() throws {
        let project = try catalog.project(matching: SQLiteCatalog.ProjectQuery.primaryKey(3))
        XCTAssertEqual(project.name, CatalogData.project3.name)
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
    
    func testQueryExpressionPrimaryKey() throws {
        let expression = try catalog.expression(matching: SQLiteCatalog.ExpressionQuery.primaryKey(2))
        XCTAssertEqual(expression.key, "BUTTON_DELETE")
    }
    
    func testQueryTranslationPrimaryKey() throws {
        let translation = try catalog.translation(matching: SQLiteCatalog.TranslationQuery.primaryKey(9))
        XCTAssertEqual(translation.regionCode, .BR)
    }
}
