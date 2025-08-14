#if canImport(CoreData)
import XCTest

final class CoreDataExportTests: LocalizerTestCase {

    override var resource: TestResource {
        .file(
            Bundle.module.url(forResource: "test_multi_language_core_data_v3", withExtension: "sqlite")
        )
    }

    func testAppleStringsEnglish() throws {
        let output = try process.runOutputting(with: [
            "catalog", "export", "apple-strings", "en", "--storage", "core-data", "--path", url.path(),
        ])

        XCTAssertEqual(output, """
        "APPLICATION_NAME" = "Lingua";
        "GREETING" = "Hello World!";
        "HIDDEN_MESSAGE" = "";
        "PLATFORM_ANDROID" = "Android";
        "PLATFORM_APPLE" = "Apple";
        "PLATFORM_WEB" = "Web";

        """)
    }

    func testAppleStringsSpanish() throws {
        let output = try process.runOutputting(with: [
            "catalog", "export", "apple-strings", "es", "--storage", "core-data", "--path", url.path(),
        ])

        XCTAssertEqual(output, """
        "APPLICATION_NAME" = "Lingua";
        "GREETING" = "Hola Mundo!";
        "HIDDEN_MESSAGE" = "solo en español";
        "PLATFORM_ANDROID" = "Android";
        "PLATFORM_APPLE" = "Apple";
        "PLATFORM_WEB" = "Web";

        """)
    }

    func testAndroidXMLEnglish() throws {
        let output = try process.runOutputting(with: [
            "catalog", "export", "android-xml", "en", "--storage", "core-data", "--path", url.path(),
        ])

        XCTAssertEqual(output, """
        <?xml version="1.0" encoding="UTF-8"?>

          <resources>
            <string name="APPLICATION_NAME">Lingua</string>
            <string name="GREETING">Hello World!</string>
            <string name="HIDDEN_MESSAGE"></string>
            <string name="PLATFORM_ANDROID">Android</string>
            <string name="PLATFORM_APPLE">Apple</string>
            <string name="PLATFORM_WEB">Web</string>
          </resources>

        """)
    }

    func testAndroidXMLSpanish() throws {
        let output = try process.runOutputting(with: [
            "catalog", "export", "android-xml", "es", "--storage", "core-data", "--path", url.path(),
        ])

        XCTAssertEqual(output, """
        <?xml version="1.0" encoding="UTF-8"?>

          <resources>
            <string name="GREETING">Hola Mundo!</string>
            <string name="HIDDEN_MESSAGE">solo en español</string>
          </resources>

        """)
    }

    func testAndroidXMLSpanishWithFallback() throws {
        let output = try process.runOutputting(with: [
            "catalog", "export", "android-xml", "es", "--fallback", "--storage", "core-data", "--path", url.path(),
        ])

        XCTAssertEqual(output, """
        <?xml version="1.0" encoding="UTF-8"?>

          <resources>
            <string name="APPLICATION_NAME">Lingua</string>
            <string name="GREETING">Hola Mundo!</string>
            <string name="HIDDEN_MESSAGE">solo en español</string>
            <string name="PLATFORM_ANDROID">Android</string>
            <string name="PLATFORM_APPLE">Apple</string>
            <string name="PLATFORM_WEB">Web</string>
          </resources>

        """)
    }

    func testJSONEnglish() throws {
        let output = try process.runOutputting(with: [
            "catalog", "export", "json", "en", "--storage", "core-data", "--path", url.path(),
        ])

        XCTAssertEqual(output, """
        {
          "APPLICATION_NAME" : "Lingua",
          "GREETING" : "Hello World!",
          "HIDDEN_MESSAGE" : "",
          "PLATFORM_ANDROID" : "Android",
          "PLATFORM_APPLE" : "Apple",
          "PLATFORM_WEB" : "Web"
        }

        """)
    }

    func testJSONSpanish() throws {
        let output = try process.runOutputting(with: [
            "catalog", "export", "json", "es", "--storage", "core-data", "--path", url.path(),
        ])

        XCTAssertEqual(output, """
        {
          "GREETING" : "Hola Mundo!",
          "HIDDEN_MESSAGE" : "solo en español"
        }

        """)
    }

    func testJSONSpanishWithFallback() throws {
        let output = try process.runOutputting(with: [
            "catalog", "export", "json", "es", "--storage", "core-data", "--fallback", "--path", url.path(),
        ])

        XCTAssertEqual(output, """
        {
          "APPLICATION_NAME" : "Lingua",
          "GREETING" : "Hola Mundo!",
          "HIDDEN_MESSAGE" : "solo en español",
          "PLATFORM_ANDROID" : "Android",
          "PLATFORM_APPLE" : "Apple",
          "PLATFORM_WEB" : "Web"
        }

        """)
    }
}
#endif
