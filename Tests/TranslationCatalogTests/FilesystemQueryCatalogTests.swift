import LocaleSupport
@testable import TranslationCatalog
@testable import TranslationCatalogFilesystem
import XCTest

final class FilesystemQueryCatalogTests: XCTestCase {

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

    func testMetadataQueries() throws {
        try catalog.assertLocaleIdentifiers()
    }
}
