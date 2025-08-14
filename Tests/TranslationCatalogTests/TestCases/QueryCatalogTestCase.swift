@testable import TranslationCatalog
@testable import TranslationCatalogFilesystem
import XCTest

class QueryCatalogTestCase: XCTestCase {

    var catalog: (any Catalog)!

    override func setUpWithError() throws {
        try XCTSkipIf(catalog == nil)
        try catalog.assertPrepare()
        try super.setUpWithError()
    }

    func testProjectQueries() throws {
        try catalog.assertQueryProjects()
        try catalog.assertQueryProjectsNamed()
        try catalog.assertQueryProjectsExpressionID()
        try catalog.assertQueryProjectId()
        try catalog.assertQueryProjectNamed()
    }

    func testExpressionQueries() throws {
        try catalog.assertQueryExpressions()
        try catalog.assertQueryExpressionsProjectID()
        try catalog.assertQueryExpressionsKeyed()
        try catalog.assertQueryExpressionsValued()
        try catalog.assertQueryExpressionsHaving()
        try catalog.assertQueryExpressionsHavingOnly()
        try catalog.assertQueryExpressionsHavingState()
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

    func testMetadataQueries() throws {
        try catalog.assertLocaleIdentifiers()
    }
}
