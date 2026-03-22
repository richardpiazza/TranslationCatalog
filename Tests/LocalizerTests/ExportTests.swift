import Foundation
@testable import localizer
import Testing

struct ExportTests {

    private static var resources: [(TestResource, Catalog.Storage)] {
        var resources: [(TestResource, Catalog.Storage)] = [
            (
                .file(
                    Bundle.module.url(forResource: "test_multi_language_v5", withExtension: "sqlite")
                ),
                .sqlite
            ),
            (
                .directory(
                    Bundle.module.resourceURL?
                        .appending(path: "StructuredResources", directoryHint: .isDirectory)
                        .appending(path: "MultiLanguageCatalog", directoryHint: .isDirectory)
                ),
                .filesystem
            ),
        ]
        #if canImport(CoreData) && os(macOS)
        resources.append(
            (
                .file(
                    Bundle.module.url(forResource: "test_multi_language_core_data_v3", withExtension: "sqlite")
                ),
                .coreData
            )
        )
        #endif
        return resources
    }

    @Test(arguments: Self.resources)
    func appleStringsEnglish(resource: (TestResource, Catalog.Storage)) throws {
        let process = try LocalizerProcess(copying: resource.0)
        let output = try process.runOutputting(with: [
            "catalog", "export", "apple-strings", "en", "--storage", resource.1.rawValue, "--path", process.url.path(),
        ])

        #expect(output == """
        "APPLICATION_NAME" = "Lingua";
        "GREETING" = "Hello World!";
        "HIDDEN_MESSAGE" = "";
        "PLATFORM_ANDROID" = "Android";
        "PLATFORM_APPLE" = "Apple";
        "PLATFORM_WEB" = "Web";

        """)

        try process.recycle()
    }

    @Test(arguments: Self.resources)
    func appleStringsSpanish(resource: (TestResource, Catalog.Storage)) throws {
        let process = try LocalizerProcess(copying: resource.0)
        let output = try process.runOutputting(with: [
            "catalog", "export", "apple-strings", "es", "--storage", resource.1.rawValue, "--path", process.url.path(),
        ])

        #expect(output == """
        "APPLICATION_NAME" = "Lingua";
        "GREETING" = "Hola Mundo!";
        "HIDDEN_MESSAGE" = "solo en español";
        "PLATFORM_ANDROID" = "Android";
        "PLATFORM_APPLE" = "Apple";
        "PLATFORM_WEB" = "Web";

        """)

        try process.recycle()
    }

    @Test(arguments: Self.resources)
    func androidXMLEnglish(resource: (TestResource, Catalog.Storage)) throws {
        let process = try LocalizerProcess(copying: resource.0)
        let output = try process.runOutputting(with: [
            "catalog", "export", "android-xml", "en", "--storage", resource.1.rawValue, "--path", process.url.path(),
        ])

        #expect(output == """
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

        try process.recycle()
    }

    @Test(arguments: Self.resources)
    func androidXMLSpanish(resource: (TestResource, Catalog.Storage)) throws {
        let process = try LocalizerProcess(copying: resource.0)
        let output = try process.runOutputting(with: [
            "catalog", "export", "android-xml", "es", "--storage", resource.1.rawValue, "--path", process.url.path(),
        ])

        #expect(output == """
        <?xml version="1.0" encoding="UTF-8"?>
        <resources>
          <string name="GREETING">Hola Mundo!</string>
          <string name="HIDDEN_MESSAGE">solo en español</string>
        </resources>

        """)
    }

    @Test(arguments: Self.resources)
    func androidXMLSpanishWithFallback(resource: (TestResource, Catalog.Storage)) throws {
        let process = try LocalizerProcess(copying: resource.0)
        let output = try process.runOutputting(with: [
            "catalog", "export", "android-xml", "es", "--storage", resource.1.rawValue, "--fallback", "--path", process.url.path(),
        ])

        #expect(output == """
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

        try process.recycle()
    }

    @Test(arguments: Self.resources)
    func jsonEnglish(resource: (TestResource, Catalog.Storage)) throws {
        let process = try LocalizerProcess(copying: resource.0)
        let output = try process.runOutputting(with: [
            "catalog", "export", "json", "en", "--storage", resource.1.rawValue, "--path", process.url.path(),
        ])

        #expect(output == """
        {
          "APPLICATION_NAME" : "Lingua",
          "GREETING" : "Hello World!",
          "HIDDEN_MESSAGE" : "",
          "PLATFORM_ANDROID" : "Android",
          "PLATFORM_APPLE" : "Apple",
          "PLATFORM_WEB" : "Web"
        }

        """)

        try process.recycle()
    }

    @Test(arguments: Self.resources)
    func jsonSpanish(resource: (TestResource, Catalog.Storage)) throws {
        let process = try LocalizerProcess(copying: resource.0)
        let output = try process.runOutputting(with: [
            "catalog", "export", "json", "es", "--storage", resource.1.rawValue, "--path", process.url.path(),
        ])

        #expect(output == """
        {
          "GREETING" : "Hola Mundo!",
          "HIDDEN_MESSAGE" : "solo en español"
        }

        """)

        try process.recycle()
    }

    @Test(arguments: Self.resources)
    func jsonSpanishWithFallback(resource: (TestResource, Catalog.Storage)) throws {
        let process = try LocalizerProcess(copying: resource.0)
        let output = try process.runOutputting(with: [
            "catalog", "export", "json", "es", "--fallback", "--storage", resource.1.rawValue, "--path", process.url.path(),
        ])

        #expect(output == """
        {
          "APPLICATION_NAME" : "Lingua",
          "GREETING" : "Hola Mundo!",
          "HIDDEN_MESSAGE" : "solo en español",
          "PLATFORM_ANDROID" : "Android",
          "PLATFORM_APPLE" : "Apple",
          "PLATFORM_WEB" : "Web"
        }

        """)

        try process.recycle()
    }
}
