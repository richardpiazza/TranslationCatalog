import LocaleSupport
@testable import TranslationCatalog
@testable import TranslationCatalogSQLite
import XCTest

final class SQLiteEmptyCatalogTests: EmptyCatalogTestCase {

    private let fileManager: FileManager = .default

    /// Unique identifier for this execution run.
    private let executionId = UUID()

    /// Unique filename for this run.
    private lazy var fileName: String = "\(executionId).sqlite"

    /// URL for the catalog used during this run.
    private lazy var url: URL = {
        let directory = URL(fileURLWithPath: fileManager.currentDirectoryPath, isDirectory: true)
        #if swift(>=5.7.1) && (os(macOS) || os(iOS) || os(tvOS) || os(watchOS))
        if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            return directory.appending(path: fileName, directoryHint: .isDirectory)
        } else {
            return directory.appendingPathComponent(fileName, isDirectory: true)
        }
        #else
        return directory.appendingPathComponent(fileName, isDirectory: true)
        #endif
    }()

    /// Removes the temporarily created catalog during the execution.
    private func recycle() throws {
        guard fileManager.fileExists(atPath: url.path) else {
            return
        }

        try fileManager.removeItem(at: url)
    }

    override func setUpWithError() throws {
        catalog = try SQLiteCatalog(url: url)
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        try recycle()
        try super.tearDownWithError()
    }
}
