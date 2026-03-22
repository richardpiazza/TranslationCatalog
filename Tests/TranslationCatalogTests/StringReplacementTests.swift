import Testing
@testable import TranslationCatalogIO

struct StringReplacementTests {

    @Test func simpleAndroidEscaping() {
        #expect("I am not Spartacus & lying".simpleAndroidXMLEscaped() == "I am not Spartacus &amp; lying")
        #expect(#""I am Spartacus""#.simpleAndroidXMLEscaped() == "\\\"I am Spartacus\\\"")
        #expect("I'm Spartacus".simpleAndroidXMLEscaped() == #"I\'m Spartacus"#)
        #expect("I < Spartacus".simpleAndroidXMLEscaped() == "I &lt; Spartacus")
        #expect("Spartacus > I".simpleAndroidXMLEscaped() == "Spartacus &gt; I")
        #expect("Spartacus is me".simpleAndroidXMLEscaped() == "Spartacus&#160;is&#160;me")
    }

    @Test func hasMultipleReplacements() {
        #expect(!"I'm heading to the store.".hasMultipleReplacements)
        #expect(!"I'm heading to %@.".hasMultipleReplacements)
        #expect("I'm heading to %@ to buy %@.".hasMultipleReplacements)
        #expect("I'm heading to %s to buy %s.".hasMultipleReplacements)
    }

    @Test func decodingDarwinStrings() throws {
        #expect(try "Hello %@".decodingDarwinStrings() == "Hello %s")
        #expect(try "Hello %1$@".decodingDarwinStrings() == "Hello %1$s")
    }

    @Test func encodingDarwinStrings() throws {
        #expect(try "Hello %s".encodingDarwinStrings() == "Hello %@")
        #expect(try "Hello %1$s".encodingDarwinStrings() == "Hello %1$@")
    }

    @Test func substitutionRanges() throws {
        var string = "Posix String %s Replacement"
        var ranges = try string.substitutionRanges
        #expect(ranges.count == 1)
        #expect(ranges.first?.lowerBound == string.index(string.startIndex, offsetBy: 13))
        #expect(ranges.first?.upperBound == string.index(string.startIndex, offsetBy: 15))

        string = "Posix String %1$s Replacement"
        ranges = try string.substitutionRanges
        #expect(ranges.count == 1)
        #expect(ranges.first?.lowerBound == string.index(string.startIndex, offsetBy: 13))
        #expect(ranges.first?.upperBound == string.index(string.startIndex, offsetBy: 17))

        string = "Darwin String %@ Replacement"
        ranges = try string.substitutionRanges
        #expect(ranges.count == 1)
        #expect(ranges.first?.lowerBound == string.index(string.startIndex, offsetBy: 14))
        #expect(ranges.first?.upperBound == string.index(string.startIndex, offsetBy: 16))

        string = "Darwin String %1$@ Replacement"
        ranges = try string.substitutionRanges
        #expect(ranges.count == 1)
        #expect(ranges.first?.lowerBound == string.index(string.startIndex, offsetBy: 14))
        #expect(ranges.first?.upperBound == string.index(string.startIndex, offsetBy: 18))

        string = "Posix Int %ld Replacement"
        ranges = try string.substitutionRanges
        #expect(ranges.count == 1)
        #expect(ranges.first?.lowerBound == string.index(string.startIndex, offsetBy: 10))
        #expect(ranges.first?.upperBound == string.index(string.startIndex, offsetBy: 13))

        string = "Posix Int %1$ld Replacement"
        ranges = try string.substitutionRanges
        #expect(ranges.count == 1)
        #expect(ranges.first?.lowerBound == string.index(string.startIndex, offsetBy: 10))
        #expect(ranges.first?.upperBound == string.index(string.startIndex, offsetBy: 15))

        string = "Posix Unsigned-Int %llu Replacement"
        ranges = try string.substitutionRanges
        #expect(ranges.count == 1)
        #expect(ranges.first?.lowerBound == string.index(string.startIndex, offsetBy: 19))
        #expect(ranges.first?.upperBound == string.index(string.startIndex, offsetBy: 23))

        string = "Posix Unsigned-Int %1$llu Replacement"
        ranges = try string.substitutionRanges
        #expect(ranges.count == 1)
        #expect(ranges.first?.lowerBound == string.index(string.startIndex, offsetBy: 19))
        #expect(ranges.first?.upperBound == string.index(string.startIndex, offsetBy: 25))

        string = "Posix Float %lf Replacement"
        ranges = try string.substitutionRanges
        #expect(ranges.count == 1)
        #expect(ranges.first?.lowerBound == string.index(string.startIndex, offsetBy: 12))
        #expect(ranges.first?.upperBound == string.index(string.startIndex, offsetBy: 15))

        string = "Posix Float %1$lf Replacement"
        ranges = try string.substitutionRanges
        #expect(ranges.count == 1)
        #expect(ranges.first?.lowerBound == string.index(string.startIndex, offsetBy: 12))
        #expect(ranges.first?.upperBound == string.index(string.startIndex, offsetBy: 17))

        string = "Multi-match %s. Int %ld, could equal %llu, but does not equal %lf."
        ranges = try string.substitutionRanges
        #expect(ranges.count == 4)
    }
}
