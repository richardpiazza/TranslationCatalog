@testable import TranslationCatalogIO
import XCTest

final class StringReplacementTests: XCTestCase {

    func testSimpleEscaping() {
        XCTAssertEqual("I am not Spartacus & lying".simpleAndroidXMLEscaped(), "I am not Spartacus &amp; lying")
//        XCTAssertEqual(#""I am Spartacus""#.simpleAndroidXMLEscaped(), "&quot;I am Spartacus&quot;")
        XCTAssertEqual("I'm Spartacus".simpleAndroidXMLEscaped(), #"I\'m Spartacus"#)
        XCTAssertEqual("I < Spartacus".simpleAndroidXMLEscaped(), "I &lt; Spartacus")
        XCTAssertEqual("Spartacus > I".simpleAndroidXMLEscaped(), "Spartacus &gt; I")
        XCTAssertEqual("Spartacus is me".simpleAndroidXMLEscaped(), "Spartacus&#160;is&#160;me")
    }

    func testMultipleReplacements() {
        XCTAssertFalse("I'm heading to the store.".hasMultipleReplacements)
        XCTAssertFalse("I'm heading to %@.".hasMultipleReplacements)
        XCTAssertTrue("I'm heading to %@ to buy %@.".hasMultipleReplacements)
        XCTAssertTrue("I'm heading to %s to buy %s.".hasMultipleReplacements)
    }

    func testDecodeDarwinStrings() throws {
        XCTAssertEqual(try "Hello %@".decodingDarwinStrings(), "Hello %s")
        XCTAssertEqual(try "Hello $1%@".decodingDarwinStrings(), "Hello $1%s")
    }

    func testEncodeDarwinStrings() throws {
        XCTAssertEqual(try "Hello %s".encodingDarwinStrings(), "Hello %@")
        XCTAssertEqual(try "Hello $1%s".encodingDarwinStrings(), "Hello $1%@")
    }
}
