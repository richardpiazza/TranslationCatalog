import XCTest
@testable import TranslationCatalogIO

final class XMLEscapingTests: XCTestCase {
    
    func testSimpleEscaping() {
        XCTAssertEqual("I am not Spartacus & lying".simpleAndroidXMLEscaped(), "I am not Spartacus &amp; lying")
        XCTAssertEqual(#""I am Spartacus""#.simpleAndroidXMLEscaped(), "&quot;I am Spartacus&quot;")
        XCTAssertEqual("I'm Spartacus".simpleAndroidXMLEscaped(), #"I\'m Spartacus"#)
        XCTAssertEqual("I < Spartacus".simpleAndroidXMLEscaped(), "I &lt; Spartacus")
        XCTAssertEqual("Spartacus > I".simpleAndroidXMLEscaped(), "Spartacus &gt; I")
        XCTAssertEqual("Spartacus is me".simpleAndroidXMLEscaped(), "Spartacus&#160;is&#160;me")
    }
}
