import TranslationCatalog
@testable import TranslationCatalogIO
import XCTest

final class ExpressionEncoderTests: XCTestCase {

    private let locale: Locale = Locale(identifier: "en_US")
    private let expressions: [TranslationCatalog.Expression] = [
        Expression(
            id: UUID(uuidString: "4D08CE7F-ED98-437E-B7CB-BB18147B9B1A")!,
            key: "EXP_01",
            value: "Hello World!",
            languageCode: .english
        ),
        Expression(
            id: UUID(uuidString: "5638B19C-2034-49F2-A163-54CC37269050")!,
            key: "EXP_02",
            value: "Hello %s!",
            languageCode: .english
        ),
        Expression(
            id: UUID(uuidString: "5870E853-35B9-4C71-B8D6-7EA922C72835")!,
            key: "EXP_03",
            value: "Hello %s, welcome to %s!",
            languageCode: .english
        ),
    ]

    func testAndroidXMLEncoding() throws {
        let data = try ExpressionEncoder.encodeValues(
            for: expressions,
            locale: locale,
            fallback: true,
            format: .androidXML
        )
        let output = String(decoding: data, as: UTF8.self)
        XCTAssertEqual(output, """
        <?xml version="1.0" encoding="UTF-8"?>
        <resources>
          <string name="EXP_01">Hello World!</string>
          <string name="EXP_02">Hello %s!</string>
          <string formatted="false" name="EXP_03">Hello %s, welcome to %s!</string>
        </resources>
        """)
    }

    func testAppleStringsEncoding() throws {
        let data = try ExpressionEncoder.encodeValues(
            for: expressions,
            locale: locale,
            fallback: true,
            format: .appleStrings
        )
        let output = String(decoding: data, as: UTF8.self)
        XCTAssertEqual(output, """
        "EXP_01" = "Hello World!";
        "EXP_02" = "Hello %@!";
        "EXP_03" = "Hello %@, welcome to %@!";
        """)
    }

    func testJSONEncoding() throws {
        let data = try ExpressionEncoder.encodeValues(
            for: expressions,
            locale: locale,
            fallback: true,
            format: .json
        )
        let output = String(decoding: data, as: UTF8.self)
        XCTAssertEqual(output, """
        {
          "EXP_01" : "Hello World!",
          "EXP_02" : "Hello %s!",
          "EXP_03" : "Hello %s, welcome to %s!"
        }
        """)
    }
}
