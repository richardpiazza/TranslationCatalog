import XCTest

final class FilesystemCatalogImportTests: FilesystemTestCase {
    
    /// Assert that repeated imports of the same file produce the expected results
    func testDoubleImport() throws {
        let resource = try XCTUnwrap(Bundle.module.url(forResource: "Import1", withExtension: "strings"))
        let arguments = ["catalog", "import", "en", resource.path, "--format", "apple", "--storage", "filesystem", "--path", url.path]
        
        var localizer = Process.LocalizerProcess()
        localizer.arguments = arguments
        try localizer.run()
        
        XCTAssertEqual(localizer.output, """
        Imported Expression 'FIRST_NAME'
        Imported Expression 'LAST_NAME'
        Imported Expression 'TITLE'
        
        """)
        
        localizer = Process.LocalizerProcess()
        localizer.arguments = arguments
        try localizer.run()
        
        XCTAssertEqual(localizer.output, """
        Existing Expression Key 'FIRST_NAME'
        Existing Translation Value 'First Name'
        Existing Expression Key 'LAST_NAME'
        Existing Translation Value 'Last Name'
        Existing Expression Key 'TITLE'
        Existing Translation Value 'Title'
        
        """)
    }
    
    /// Assert that repeated imports of the same file (that has changes) produce the expected results
    func testRepeatImport() throws {
        var resource = try XCTUnwrap(Bundle.module.url(forResource: "Import1", withExtension: "strings"))
        var arguments = ["catalog", "import", "en", resource.path, "--format", "apple", "--storage", "filesystem", "--path", url.path]
        
        var localizer = Process.LocalizerProcess()
        localizer.arguments = arguments
        try localizer.run()
        
        XCTAssertEqual(localizer.output, """
        Imported Expression 'FIRST_NAME'
        Imported Expression 'LAST_NAME'
        Imported Expression 'TITLE'
        
        """)
        
        resource = try XCTUnwrap(Bundle.module.url(forResource: "Import2", withExtension: "strings"))
        arguments = ["catalog", "import", "en", resource.path, "--format", "apple", "--storage", "filesystem", "--path", url.path]
        
        localizer = Process.LocalizerProcess()
        localizer.arguments = arguments
        try localizer.run()
        
        XCTAssertEqual(localizer.output, """
        Imported Expression 'FAMILY_NAME'
        Imported Expression 'GIVEN_NAME'
        Existing Expression Key 'TITLE'
        Existing Translation Value 'Title'
        
        """)
    }
    
}
