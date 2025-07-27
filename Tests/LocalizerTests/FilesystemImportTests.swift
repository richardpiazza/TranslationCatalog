import XCTest

final class FilesystemImportTests: XCTestCase {

    /// Assert that repeated imports of the same file produce the expected results
    func testDoubleImport() throws {
        let resource: TestResource = .file(
            Bundle.module.url(forResource: "Import1", withExtension: "strings")
        )
        var process = try LocalizerProcess(copying: resource)
        var output = try process.runOutputting(with: [
            "catalog", "import", "en", process.url.path(), "--format", "apple", "--storage", "filesystem", "--path", process.directory.path(),
        ])

        XCTAssertEqual(output, """
        Expression Created 'FIRST_NAME'
        Expression Created 'LAST_NAME'
        Expression Created 'TITLE'

        """)

        let id = process.executionIdentifier
        try process.recycle()

        process = try LocalizerProcess(copying: resource, cleanupDirectory: true, id: id)
        output = try process.runOutputting(with: [
            "catalog", "import", "en", process.url.path(), "--format", "apple", "--storage", "filesystem", "--path", process.directory.path(),
        ])

        XCTAssertEqual(output, """
        Expression Exists with Key \'FIRST_NAME\'
        Expression Exists with Key \'LAST_NAME\'
        Expression Exists with Key \'TITLE\'

        """)

        try process.recycle()
    }

    /// Assert that repeated imports of the same file (that has changes) produce the expected results
    func testRepeatImport() throws {
        var resource: TestResource = .file(
            Bundle.module.url(forResource: "Import1", withExtension: "strings")
        )
        var process = try LocalizerProcess(copying: resource)
        var output = try process.runOutputting(with: [
            "catalog", "import", "en", process.url.path(), "--format", "apple", "--storage", "filesystem", "--path", process.directory.path(),
        ])

        XCTAssertEqual(output, """
        Expression Created 'FIRST_NAME'
        Expression Created 'LAST_NAME'
        Expression Created 'TITLE'

        """)

        let id = process.executionIdentifier
        try process.recycle()

        resource = .file(
            Bundle.module.url(forResource: "Import2", withExtension: "strings")
        )
        process = try LocalizerProcess(copying: resource, cleanupDirectory: true, id: id)
        output = try process.runOutputting(with: [
            "catalog", "import", "en", process.url.path(), "--format", "apple", "--storage", "filesystem", "--path", process.directory.path(),
        ])

        XCTAssertEqual(output, """
        Expression Created 'FAMILY_NAME'
        Expression Created 'GIVEN_NAME'
        Expression Exists with Key 'TITLE'

        """)

        try process.recycle()
    }
}
