import XCTest

final class CatalogGenerateTests: _LocalizerTestCase {
    
    func testExecute() throws {
        process.arguments = ["catalog", "generate", "markdown", "--path", path]
        try process.run()
        process.waitUntilExit()
        
        XCTAssertEqual(output, """
        # Strings
        
        """)
    }
    
}
