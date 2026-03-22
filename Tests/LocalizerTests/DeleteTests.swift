import Foundation
import Testing

struct DeleteTests {

    @Test func noParameters() throws {
        let process = LocalizerProcess()
        let (terminationStatus, _, error) = try process.runReporting(with: [
            "catalog", "delete", "project",
        ])

        #expect(terminationStatus != 0)
        #expect(error == """
        Error: Missing expected argument '<id>'
        Help:  <id>  Unique ID of the Project.
        Usage: localizer catalog delete project <id> [--storage <storage>] [--path <path>] [--verbose]
          See 'localizer catalog delete project --help' for more information.

        """)

        try process.recycle()
    }

    @Test func help() throws {
        let process = LocalizerProcess()
        let (terminationStatus, output, _) = try process.runReporting(with: [
            "catalog", "delete", "project", "--help",
        ])

        #expect(terminationStatus == 0)
        #expect(output.contains("OVERVIEW: Delete a Project from the catalog."))
        #expect(output.contains("USAGE: localizer catalog delete project <id> [--storage <storage>] [--path <path>] [--verbose]"))
        #expect(output.contains("ARGUMENTS:"))
        #expect(output.contains("OPTIONS:"))

        try process.recycle()
    }

    @Test func invalidProjectID() throws {
        let process = LocalizerProcess()
        let (terminationStatus, _, error) = try process.runReporting(with: [
            "catalog", "delete", "project", "123ABC", "--path", process.url.path(),
        ])

        #expect(terminationStatus != 0)
        #expect(error == """
        Error: The value '123ABC' is invalid for '<id>'
        Help:  <id>  Unique ID of the Project.
        Usage: localizer catalog delete project <id> [--storage <storage>] [--path <path>] [--verbose]
          See 'localizer catalog delete project --help' for more information.

        """)

        try process.recycle()
    }

    @Test func unknownProjectID() throws {
        let process = LocalizerProcess()
        let (terminationStatus, _, error) = try process.runReporting(with: [
            "catalog", "delete", "project", "399150E5-6709-4CA8-AE54-C665EC3D1916", "--path", process.url.lastPathComponent,
        ])

        #expect(terminationStatus != 0)
        #expect(error == """
        Error: Unknown Project '399150E5-6709-4CA8-AE54-C665EC3D1916'.
        Usage: project <id> [--storage <storage>] [--path <path>] [--verbose]
          See 'project --help' for more information.

        """)

        try process.recycle()
    }

    @Test func unknownProjectIDDebug() throws {
        let process = LocalizerProcess()
        let (terminationStatus, output, error) = try process.runReporting(with: [
            "catalog", "delete", "project", "399150E5-6709-4CA8-AE54-C665EC3D1916", "--path", process.url.lastPathComponent, "--verbose",
        ])

        #expect(terminationStatus != 0)
        #expect(output == """
        ======SQL======
        SELECT id, uuid, name
        FROM project
        WHERE uuid = '399150E5-6709-4CA8-AE54-C665EC3D1916'
        LIMIT 1;
        ======___======


        """)
        #expect(error == """
        Error: Unknown Project '399150E5-6709-4CA8-AE54-C665EC3D1916'.
        Usage: project <id> [--storage <storage>] [--path <path>] [--verbose]
          See 'project --help' for more information.

        """)

        try process.recycle()
    }

    @Test func knownProjectIdVerbose() throws {
        let resource: TestResource = .file(Bundle.module.url(forResource: "test_single_project_entity_v5", withExtension: "sqlite"))
        let process = try LocalizerProcess(copying: resource)
        let (terminationStatus, output, _) = try process.runReporting(with: [
            "catalog", "delete", "project", "82362D51-8C80-4328-BADD-BBE2EA08889F", "--path", process.url.path(), "--verbose",
        ])

        #expect(terminationStatus == 0)
        #expect(output == """
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
