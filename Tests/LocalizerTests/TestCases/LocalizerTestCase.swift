import XCTest

class LocalizerTestCase: XCTestCase {
    
    var process: LocalizerProcess!
    var resource: TestResource { .file(nil) }
    
    var url: URL { process.url }
    var directory: URL { process.directory }
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        process = try LocalizerProcess(copying: resource)
    }
    
    override func tearDownWithError() throws {
        if process != nil {
            try process.recycle()
        }
        try super.tearDownWithError()
    }
}
