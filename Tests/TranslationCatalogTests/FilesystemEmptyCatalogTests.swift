import XCTest
import LocaleSupport
@testable import TranslationCatalog
@testable import TranslationCatalogFilesystem

final class FilesystemEmptyCatalogTests: XCTestCase {
    
    private let fileManager: FileManager = .default
    
    /// Unique identifier for this execution run.
    private let executionId = UUID()
    
    /// URL for the catalog used during this run.
    private lazy var url: URL = {
        let directory = URL(fileURLWithPath: fileManager.currentDirectoryPath, isDirectory: true)
        #if swift(>=5.7.1) && (os(macOS) || os(iOS) || os(tvOS) || os(watchOS))
        if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            return directory.appending(path: executionId.uuidString, directoryHint: .isDirectory)
        } else {
            return directory.appendingPathComponent(executionId.uuidString, isDirectory: true)
        }
        #else
        return directory.appendingPathComponent(executionId.uuidString, isDirectory: true)
        #endif
    }()
    
    /// Removes the temporarily created catalog during the execution.
    private func recycle() throws {
        guard fileManager.fileExists(atPath: url.path) else {
            return
        }
        
        try fileManager.removeItem(at: url)
    }
    
    private var catalog: FilesystemCatalog!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        catalog = try FilesystemCatalog(url: url)
    }
    
    override func tearDownWithError() throws {
        try recycle()
        try super.tearDownWithError()
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
