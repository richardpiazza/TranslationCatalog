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
        XCTAssertEqual(try "Hello %1$@".decodingDarwinStrings(), "Hello %1$s")
    }

    func testEncodeDarwinStrings() throws {
        XCTAssertEqual(try "Hello %s".encodingDarwinStrings(), "Hello %@")
        XCTAssertEqual(try "Hello %1$s".encodingDarwinStrings(), "Hello %1$@")
    }

    func testSubstitutionDetection() throws {
        var string = "Posix String %s Replacement"
        var ranges = try string.substitutionRanges
        XCTAssertEqual(ranges.count, 1)
        XCTAssertEqual(ranges.first?.lowerBound, string.index(string.startIndex, offsetBy: 13))
        XCTAssertEqual(ranges.first?.upperBound, string.index(string.startIndex, offsetBy: 15))

        string = "Posix String %1$s Replacement"
        ranges = try string.substitutionRanges
        XCTAssertEqual(ranges.count, 1)
        XCTAssertEqual(ranges.first?.lowerBound, string.index(string.startIndex, offsetBy: 13))
        XCTAssertEqual(ranges.first?.upperBound, string.index(string.startIndex, offsetBy: 17))

        string = "Darwin String %@ Replacement"
        ranges = try string.substitutionRanges
        XCTAssertEqual(ranges.count, 1)
        XCTAssertEqual(ranges.first?.lowerBound, string.index(string.startIndex, offsetBy: 14))
        XCTAssertEqual(ranges.first?.upperBound, string.index(string.startIndex, offsetBy: 16))

        string = "Darwin String %1$@ Replacement"
        ranges = try string.substitutionRanges
        XCTAssertEqual(ranges.count, 1)
        XCTAssertEqual(ranges.first?.lowerBound, string.index(string.startIndex, offsetBy: 14))
        XCTAssertEqual(ranges.first?.upperBound, string.index(string.startIndex, offsetBy: 18))

        string = "Posix Int %ld Replacement"
        ranges = try string.substitutionRanges
        XCTAssertEqual(ranges.count, 1)
        XCTAssertEqual(ranges.first?.lowerBound, string.index(string.startIndex, offsetBy: 10))
        XCTAssertEqual(ranges.first?.upperBound, string.index(string.startIndex, offsetBy: 13))

        string = "Posix Int %1$ld Replacement"
        ranges = try string.substitutionRanges
        XCTAssertEqual(ranges.count, 1)
        XCTAssertEqual(ranges.first?.lowerBound, string.index(string.startIndex, offsetBy: 10))
        XCTAssertEqual(ranges.first?.upperBound, string.index(string.startIndex, offsetBy: 15))

        string = "Posix Unsigned-Int %llu Replacement"
        ranges = try string.substitutionRanges
        XCTAssertEqual(ranges.count, 1)
        XCTAssertEqual(ranges.first?.lowerBound, string.index(string.startIndex, offsetBy: 19))
        XCTAssertEqual(ranges.first?.upperBound, string.index(string.startIndex, offsetBy: 23))

        string = "Posix Unsigned-Int %1$llu Replacement"
        ranges = try string.substitutionRanges
        XCTAssertEqual(ranges.count, 1)
        XCTAssertEqual(ranges.first?.lowerBound, string.index(string.startIndex, offsetBy: 19))
        XCTAssertEqual(ranges.first?.upperBound, string.index(string.startIndex, offsetBy: 25))

        string = "Posix Float %lf Replacement"
        ranges = try string.substitutionRanges
        XCTAssertEqual(ranges.count, 1)
        XCTAssertEqual(ranges.first?.lowerBound, string.index(string.startIndex, offsetBy: 12))
        XCTAssertEqual(ranges.first?.upperBound, string.index(string.startIndex, offsetBy: 15))

        string = "Posix Float %1$lf Replacement"
        ranges = try string.substitutionRanges
        XCTAssertEqual(ranges.count, 1)
        XCTAssertEqual(ranges.first?.lowerBound, string.index(string.startIndex, offsetBy: 12))
        XCTAssertEqual(ranges.first?.upperBound, string.index(string.startIndex, offsetBy: 17))

        string = "Multi-match %s. Int %ld, could equal %llu, but does not equal %lf."
        ranges = try string.substitutionRanges
        XCTAssertEqual(ranges.count, 4)
    }
}
