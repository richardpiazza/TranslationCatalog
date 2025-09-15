@testable import TranslationCatalog
@testable import TranslationCatalogFilesystem
import XCTest

class FilesystemEncodingTests: XCTestCase {

    func testProjectDocumentEncoding() throws {
        let document = ProjectDocument(
            id: UUID(uuidString: "24D67823-F859-40A1-88C2-A56F1170905B")!,
            name: "Example",
            expressionIds: [
                UUID(uuidString: "7F9D2FF1-31C1-47A1-94EE-E23BB0A7AD2B")!,
                UUID(uuidString: "592E488D-4E3C-490B-8725-C45FF7DEC872")!,
                UUID(uuidString: "FB7C761C-9026-49C2-BBC7-9B7B897CAA6D")!,
            ]
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let data = try encoder.encode(document)
        let json = String(decoding: data, as: UTF8.self)
        XCTAssertEqual(
            json,
            #"{"expressionIds":["592E488D-4E3C-490B-8725-C45FF7DEC872","7F9D2FF1-31C1-47A1-94EE-E23BB0A7AD2B","FB7C761C-9026-49C2-BBC7-9B7B897CAA6D"],"id":"24D67823-F859-40A1-88C2-A56F1170905B","name":"Example"}"#
        )
    }
}
