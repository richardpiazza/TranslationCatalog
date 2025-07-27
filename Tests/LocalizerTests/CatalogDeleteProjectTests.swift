import TranslationCatalogSQLite
import XCTest

final class CatalogDeleteProjectTests: XCTestCase {

    func testNoParameters() throws {
        let process = LocalizerProcess()
        let (terminationStatus, _, error) = try process.runReporting(with: [
            "catalog", "delete", "project",
        ])

        XCTAssertNotEqual(terminationStatus, 0)
        XCTAssertEqual(error, """
        Error: Missing expected argument '<id>'
        Help:  <id>  Unique ID of the Project.
        Usage: localizer catalog delete project <id> [--storage <storage>] [--path <path>] [--verbose]
          See 'localizer catalog delete project --help' for more information.

        """)

        try process.recycle()
    }

    func testHelp() throws {
        let process = LocalizerProcess()
        let (terminationStatus, output, _) = try process.runReporting(with: [
            "catalog", "delete", "project", "--help",
        ])

        XCTAssertEqual(terminationStatus, 0)
        XCTAssertTrue(output.contains("OVERVIEW: Delete a Project from the catalog."))
        XCTAssertTrue(output.contains("USAGE: localizer catalog delete project <id> [--storage <storage>] [--path <path>] [--verbose]"))
        XCTAssertTrue(output.contains("ARGUMENTS:"))
        XCTAssertTrue(output.contains("OPTIONS:"))

        try process.recycle()
    }

    func testInvalidProjectID() throws {
        let process = LocalizerProcess()
        let (terminationStatus, _, error) = try process.runReporting(with: [
            "catalog", "delete", "project", "123ABC", "--path", process.url.path(),
        ])

        XCTAssertNotEqual(terminationStatus, 0)
        XCTAssertEqual(error, """
        Error: The value '123ABC' is invalid for '<id>'
        Help:  <id>  Unique ID of the Project.
        Usage: localizer catalog delete project <id> [--storage <storage>] [--path <path>] [--verbose]
          See 'localizer catalog delete project --help' for more information.

        """)

        try process.recycle()
    }

    func testUnknownProjectID() throws {
        let process = LocalizerProcess()
        let (terminationStatus, _, error) = try process.runReporting(with: [
            "catalog", "delete", "project", "399150E5-6709-4CA8-AE54-C665EC3D1916", "--path", process.url.lastPathComponent,
        ])

        XCTAssertNotEqual(terminationStatus, 0)
        XCTAssertEqual(error, """
        Error: Unknown Project '399150E5-6709-4CA8-AE54-C665EC3D1916'.
        Usage: project <id> [--storage <storage>] [--path <path>] [--verbose]
          See 'project --help' for more information.

        """)

        try process.recycle()
    }

    func testUnknownProjectIDDebug() throws {
        let process = LocalizerProcess()
        let (terminationStatus, output, error) = try process.runReporting(with: [
            "catalog", "delete", "project", "399150E5-6709-4CA8-AE54-C665EC3D1916", "--path", process.url.lastPathComponent, "--verbose",
        ])

        XCTAssertNotEqual(terminationStatus, 0)
        XCTAssertEqual(output, """
        ======SQL======
        SELECT id, uuid, name
        FROM project
        WHERE uuid = '399150E5-6709-4CA8-AE54-C665EC3D1916'
        LIMIT 1;
        ======___======


        """)
        XCTAssertEqual(error, """
        Error: Unknown Project '399150E5-6709-4CA8-AE54-C665EC3D1916'.
        Usage: project <id> [--storage <storage>] [--path <path>] [--verbose]
          See 'project --help' for more information.

        """)

        try process.recycle()
    }

    func testKnownProjectId() throws {
        let resource: TestResource = .file(Bundle.module.url(forResource: "test_single_project_entity_v4", withExtension: "sqlite"))
        let process = try LocalizerProcess(copying: resource)
        let (terminationStatus, output, _) = try process.runReporting(with: [
            "catalog", "delete", "project", "82362D51-8C80-4328-BADD-BBE2EA08889F", "--path", process.url.path(), "--verbose",
        ])

        XCTAssertEqual(terminationStatus, 0)
        XCTAssertEqual(output, """
        ======SQL======
        SELECT id, uuid, name
        FROM project
        WHERE uuid = \'82362D51-8C80-4328-BADD-BBE2EA08889F\'
        LIMIT 1;
        ======___======

        Removing project \'LocaleSupport\' [82362D51-8C80-4328-BADD-BBE2EA08889F].
        ======SQL======
        SELECT id, uuid, name
        FROM project
        WHERE uuid = \'82362D51-8C80-4328-BADD-BBE2EA08889F\'
        LIMIT 1;
        ======___======

        ======SQL======
        DELETE FROM project_expression
        WHERE project_id = 1;
        ======___======

        ======SQL======
        DELETE FROM project
        WHERE id = 1;
        ======___======

        Project \'LocaleSupport\' deleted.

        """)

        try process.recycle()
    }
}
