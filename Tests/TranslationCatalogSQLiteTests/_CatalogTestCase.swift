import XCTest
@testable import TranslationCatalog

class _CatalogTestCase: XCTestCase {
    
    let fileManager: FileManager = .default
    
    /// Unique identifier for this execution run.
    let executionId = UUID()
    /// Unique filename for this run.
    lazy var fileName: String = { "\(executionId).sqlite" }()
    /// URL for the catalog used during this run.
    lazy var url: URL = {
        let directory = URL(fileURLWithPath: fileManager.currentDirectoryPath, isDirectory: true)
        return directory.appendingPathComponent(fileName)
    }()
    
    /// Removes the temporarily created catalog during the execution.
    func recycle() throws {
        guard fileManager.fileExists(atPath: url.path) else {
            return
        }
        
        try fileManager.removeItem(at: url)
    }
    
    override func tearDownWithError() throws {
        try recycle()
        try super.tearDownWithError()
    }
}
