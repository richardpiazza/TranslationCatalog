import XCTest
import TranslationCatalogSQLite

final class CatalogDeleteProjectTests: _LocalizerTestCase {
    
    func testNoParameters() throws {
        process.arguments = ["catalog", "delete", "project"]
        try process.run()
        process.waitUntilExit()
        
        switch process.terminationStatus {
        case 0:
            XCTFail("Unexpected clean exit.")
        default:
            XCTAssertEqual(error, """
            Error: Missing expected argument '<id>'
            Help:  <id>  Unique ID of the Project.
            Usage: localizer catalog delete project <id> [--storage <storage>] [--path <path>] [--debug]
              See 'localizer catalog delete project --help' for more information.
            
            """)
            
        }
    }
    
    func testHelp() throws {
        process.arguments = ["catalog", "delete", "project", "--help"]
        try process.run()
        process.waitUntilExit()
        
        switch process.terminationStatus {
        case 0:
            let output = try XCTUnwrap(self.output)
            XCTAssertTrue(output.contains("OVERVIEW: Delete a Project from the catalog."))
            XCTAssertTrue(output.contains("USAGE: localizer catalog delete project <id> [--storage <storage>] [--path <path>] [--debug]"))
            XCTAssertTrue(output.contains("ARGUMENTS:"))
            XCTAssertTrue(output.contains("OPTIONS:"))
        default:
            XCTFail("Unexpected dirty exit.")
        }
    }
    
    func testInvalidProjectID() throws {
        process.arguments = ["catalog", "delete", "project", "123ABC", "--path", path]
        try process.run()
        process.waitUntilExit()
        
        switch process.terminationStatus {
        case 0:
            XCTFail("Unexpected clean exit.")
        default:
            XCTAssertEqual(error, """
            Error: The value '123ABC' is invalid for '<id>'
            Help:  <id>  Unique ID of the Project.
            Usage: localizer catalog delete project <id> [--storage <storage>] [--path <path>] [--debug]
              See 'localizer catalog delete project --help' for more information.
            
            """)
        }
    }
    
    func testUnknownProjectID() throws {
        process.arguments = ["catalog", "delete", "project", "399150E5-6709-4CA8-AE54-C665EC3D1916", "--path", path]
        try process.run()
        process.waitUntilExit()
        
        switch process.terminationStatus {
        case 0:
            XCTFail("Unexpected clean exit.")
        default:
            XCTAssertEqual(error, """
            Error: Unknown Project '399150E5-6709-4CA8-AE54-C665EC3D1916'.
            Usage: project <id> [--storage <storage>] [--path <path>] [--debug]
              See 'project --help' for more information.
            
            """)
        }
    }
    
    func testUnknownProjectIDDebug() throws {
        process.arguments = ["catalog", "delete", "project", "399150E5-6709-4CA8-AE54-C665EC3D1916", "--path", path, "--debug"]
        try process.run()
        process.waitUntilExit()
        
        switch process.terminationStatus {
        case 0:
            XCTFail("Unexpected clean exit.")
        default:
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
            Usage: project <id> [--storage <storage>] [--path <path>] [--debug]
              See 'project --help' for more information.
            
            """)
        }
    }
    
    func testKnownProjectId() throws {
        func preconditions() throws {
            let resource = try XCTUnwrap(Bundle.module.url(forResource: "test_single_project_entity", withExtension: "sqlite"))
            let url = try caseUrl()
            try FileManager.default.copyItem(at: resource, to: url)
        }
        
        try preconditions()
        
        process.arguments = ["catalog", "delete", "project", "82362D51-8C80-4328-BADD-BBE2EA08889F", "--path", path]
        try process.run()
        process.waitUntilExit()
        
        switch process.terminationStatus {
        case 0:
            XCTAssertEqual(output, """
            Removing project \'LocaleSupport\' [82362D51-8C80-4328-BADD-BBE2EA08889F].
            Project \'LocaleSupport\' deleted.
            
            """)
        default:
            XCTFail("Unexpected dirty exit.")
        }
    }
}
