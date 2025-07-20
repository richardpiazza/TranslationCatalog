@testable import TranslationCatalogIO
import XCTest

final class StringCatalogTests: XCTestCase {
    func testStringCatalog0Decoding() throws {
        let url = try XCTUnwrap(Bundle.module.url(forResource: "Localizable0.xcstrings", withExtension: "json"))
        let data = try Data(contentsOf: url)
        let catalog = try JSONDecoder().decode(StringCatalog.self, from: data)
        XCTAssertEqual(catalog.strings.count, 9)
    }
    
    func testStringCatalog1Decoding() throws {
        let url = try XCTUnwrap(Bundle.module.url(forResource: "Localizable1.xcstrings", withExtension: "json"))
        let data = try Data(contentsOf: url)
        let catalog = try JSONDecoder().decode(StringCatalog.self, from: data)
        XCTAssertEqual(catalog.strings.count, 6)
    }
}
