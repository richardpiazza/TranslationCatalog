import LocaleSupport
@testable import TranslationCatalog
@testable import TranslationCatalogFilesystem
import XCTest

class EmptyCatalogTestCase: XCTestCase {

    var catalog: (any Catalog)!

    override func setUpWithError() throws {
        try XCTSkipIf(catalog == nil)
        try super.setUpWithError()
    }

    // MARK: - Insert

    func testInsertProject() throws {
        try catalog.assertInsertProject()
    }

    func testInsertExpression() throws {
        try catalog.assertInsertExpression()
    }

    func testInsertTranslation() throws {
        try catalog.assertInsertTranslation()
    }

    func testInsertProject_CascadeExpressions() throws {
        try catalog.assertInsertProject_CascadeExpressions()
    }

    func testInsertExpress_CascadeTranslations() throws {
        try catalog.assertInsertExpression_CascadeTranslations()
    }

    // MARK: - Update

    func testUpdateProjectName() throws {
        try catalog.assertUpdateProjectName()
    }

    func testUpdateProject_LinkExpression() throws {
        try catalog.assertUpdateProject_LinkExpression()
    }

    func testUpdateProject_UnlinkExpression() throws {
        try catalog.assertUpdateProject_UnlinkExpression()
    }

    func testUpdateExpressionKey() throws {
        try catalog.assertUpdateExpressionKey()
    }

    func testUpdateExpressionName() throws {
        try catalog.assertUpdateExpressionName()
    }

    func testUpdateExpressionDefaultLanguage() throws {
        try catalog.assertUpdateExpressionDefaultLanguage()
    }

    func testUpdateExpressionContext() throws {
        try catalog.assertUpdateExpressionContext()
    }

    func testUpdateExpressionFeature() throws {
        try catalog.assertUpdateExpressionFeature()
    }

    func testUpdateTranslationLanguage() throws {
        try catalog.assertUpdateTranslationLanguage()
    }

    func testUpdateTranslationScript() throws {
        try catalog.assertUpdateTranslationScript()
    }

    func testUpdateTranslationRegion() throws {
        try catalog.assertUpdateTranslationRegion()
    }

    func testUpdateTranslationValue() throws {
        try catalog.assertUpdateTranslationValue()
    }

    // MARK: - Delete

    func testDeleteProject() throws {
        try catalog.assertDeleteProject()
    }

    func testDeleteExpression() throws {
        try catalog.assertDeleteExpression()
    }

    func testDeleteTranslation() throws {
        try catalog.assertDeleteTranslation()
    }

    func testDeleteExpression_CascadeTranslation() throws {
        try catalog.assertDeleteExpression_CascadeTranslation()
    }

    func testDeleteProject_NullifyExpression() throws {
        try catalog.assertDeleteProject_NullifyExpression()
    }
}
