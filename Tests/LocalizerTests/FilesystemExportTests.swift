import XCTest

final class FilesystemExportTests: LocalizerTestCase {

    override var resource: TestResource {
        .directory(
            Bundle.module.resourceURL?
                .appending(path: "StructuredResources", directoryHint: .isDirectory)
                .appending(path: "MultiLanguageCatalog", directoryHint: .isDirectory)
        )
    }

    func testAppleStringsEnglish() throws {
        let output = try process.runOutputting(with: [
            "catalog", "export", "apple", "en", "--storage", "filesystem", "--path", directory.path(),
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
            "catalog", "export", "apple", "es", "--storage", "filesystem", "--path", directory.path(),
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
            "catalog", "export", "android", "en", "--storage", "filesystem", "--path", directory.path(),
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
            "catalog", "export", "android", "es", "--storage", "filesystem", "--path", directory.path(),
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
            "catalog", "export", "android", "es", "--fallback", "--storage", "filesystem", "--path", directory.path(),
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
            "catalog", "export", "json", "en", "--storage", "filesystem", "--path", directory.path(),
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
            "catalog", "export", "json", "es", "--storage", "filesystem", "--path", directory.path(),
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
            "catalog", "export", "json", "es", "--fallback", "--storage", "filesystem", "--path", directory.path(),
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
