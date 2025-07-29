import XCTest

final class CatalogGenerateTests: XCTestCase {

    func testExecute() throws {
        let process = LocalizerProcess()
        let output = try process.runOutputting(with: [
            "catalog", "generate", "markdown", "--path", process.url.lastPathComponent,
        ])

        XCTAssertEqual(output, """
        # Strings

        """)

        try process.recycle()
    }
}
