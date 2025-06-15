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
        Expression Created 'FIRST_NAME'
        Expression Created 'LAST_NAME'
        Expression Created 'TITLE'

        """)

        localizer = Process.LocalizerProcess()
        localizer.arguments = arguments
        try localizer.run()

        XCTAssertEqual(localizer.output, """
        Expression Exists with Key \'FIRST_NAME\'; checking translations…
        Translation Skipped \'First Name\'
        Expression Exists with Key \'LAST_NAME\'; checking translations…
        Translation Skipped \'Last Name\'
        Expression Exists with Key \'TITLE\'; checking translations…
        Translation Skipped \'Title\'

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
        Expression Created 'FIRST_NAME'
        Expression Created 'LAST_NAME'
        Expression Created 'TITLE'

        """)

        resource = try XCTUnwrap(Bundle.module.url(forResource: "Import2", withExtension: "strings"))
        arguments = ["catalog", "import", "en", resource.path, "--format", "apple", "--storage", "filesystem", "--path", url.path]

        localizer = Process.LocalizerProcess()
        localizer.arguments = arguments
        try localizer.run()

        XCTAssertEqual(localizer.output, """
        Expression Created 'FAMILY_NAME'
        Expression Created 'GIVEN_NAME'
        Expression Exists with Key 'TITLE'; checking translations…
        Translation Skipped 'Title'

        """)
    }
}
