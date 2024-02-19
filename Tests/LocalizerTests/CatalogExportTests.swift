import XCTest

final class CatalogExportTests: XCTestCase {
    
    // MARK: - SQLite
    
    func testSQLiteAppleEnglish() throws {
        let resource = try XCTUnwrap(Bundle.module.url(forResource: "test_multi_language", withExtension: "sqlite"))
        let localizer = Process.LocalizerProcess()
        
        localizer.arguments = ["catalog", "export", "apple", "en", "--path", resource.path]
        try localizer.run()
        
        XCTAssertEqual(localizer.output, """
        "APPLICATION_NAME" = "Lingua";
        "GREETING" = "Hello World!";
        "HIDDEN_MESSAGE" = "solo en español";
        "PLATFORM_ANDROID" = "Android";
        "PLATFORM_APPLE" = "Apple";
        "PLATFORM_WEB" = "Web";
        
        """)
    }
    
    func testSQLiteAppleSpanish() throws {
        let resource = try XCTUnwrap(Bundle.module.url(forResource: "test_multi_language", withExtension: "sqlite"))
        let localizer = Process.LocalizerProcess()
        
        localizer.arguments = ["catalog", "export", "apple", "es", "--path", resource.path]
        try localizer.run()
        
        XCTAssertEqual(localizer.output, """
        "APPLICATION_NAME" = "Lingua";
        "GREETING" = "Hola Mundo!";
        "HIDDEN_MESSAGE" = "solo en español";
        "PLATFORM_ANDROID" = "Android";
        "PLATFORM_APPLE" = "Apple";
        "PLATFORM_WEB" = "Web";
        
        """)
    }
    
    func testSQLiteAndroidEnglish() throws {
        let resource = try XCTUnwrap(Bundle.module.url(forResource: "test_multi_language", withExtension: "sqlite"))
        let localizer = Process.LocalizerProcess()
        
        localizer.arguments = ["catalog", "export", "android", "en", "--path", resource.path]
        try localizer.run()
        
        // TODO: Should this produce a line for 'HIDDEN_MESSAGE' in 'default language' instance?
        XCTAssertEqual(localizer.output, """
        <?xml version="1.0" encoding="UTF-8"?>
        
          <resources xmlns:tools="http://schemas.android.com/tools">
            <string name="APPLICATION_NAME">Lingua</string>
            <string name="GREETING">Hello World!</string>
            <string name="PLATFORM_ANDROID">Android</string>
            <string name="PLATFORM_APPLE">Apple</string>
            <string name="PLATFORM_WEB">Web</string>
          </resources>
        
        """)
    }
    
    func testSQLiteAndroidSpanish() throws {
        let resource = try XCTUnwrap(Bundle.module.url(forResource: "test_multi_language", withExtension: "sqlite"))
        let localizer = Process.LocalizerProcess()
        
        localizer.arguments = ["catalog", "export", "android", "es", "--path", resource.path]
        try localizer.run()
        
        XCTAssertEqual(localizer.output, """
        <?xml version="1.0" encoding="UTF-8"?>
        
          <resources xmlns:tools="http://schemas.android.com/tools">
            <string name="GREETING">Hola Mundo!</string>
            <string name="HIDDEN_MESSAGE">solo en español</string>
          </resources>
        
        """)
    }
    
    func testSQLiteAndroidSpanishWithFallback() throws {
        let resource = try XCTUnwrap(Bundle.module.url(forResource: "test_multi_language", withExtension: "sqlite"))
        let localizer = Process.LocalizerProcess()
        
        localizer.arguments = ["catalog", "export", "android", "es", "--fallback", "--path", resource.path]
        try localizer.run()
        
        XCTAssertEqual(localizer.output, """
        <?xml version="1.0" encoding="UTF-8"?>
        
          <resources xmlns:tools="http://schemas.android.com/tools">
            <string name="APPLICATION_NAME">Lingua</string>
            <string name="GREETING">Hola Mundo!</string>
            <string name="HIDDEN_MESSAGE">solo en español</string>
            <string name="PLATFORM_ANDROID">Android</string>
            <string name="PLATFORM_APPLE">Apple</string>
            <string name="PLATFORM_WEB">Web</string>
          </resources>
        
        """)
    }
    
    func testSQLiteWebEnglish() throws {
        let resource = try XCTUnwrap(Bundle.module.url(forResource: "test_multi_language", withExtension: "sqlite"))
        let localizer = Process.LocalizerProcess()
        
        localizer.arguments = ["catalog", "export", "json", "en", "--path", resource.path]
        try localizer.run()
        
        // TODO: Should this produce a line for 'HIDDEN_MESSAGE' in 'default language' instance?
        XCTAssertEqual(localizer.output, """
        {
          "APPLICATION_NAME" : "Lingua",
          "GREETING" : "Hello World!",
          "PLATFORM_ANDROID" : "Android",
          "PLATFORM_APPLE" : "Apple",
          "PLATFORM_WEB" : "Web"
        }
        
        """)
    }
    
    func testSQLiteWebSpanish() throws {
        let resource = try XCTUnwrap(Bundle.module.url(forResource: "test_multi_language", withExtension: "sqlite"))
        let localizer = Process.LocalizerProcess()
        
        localizer.arguments = ["catalog", "export", "json", "es", "--path", resource.path]
        try localizer.run()
        
        XCTAssertEqual(localizer.output, """
        {
          "GREETING" : "Hola Mundo!",
          "HIDDEN_MESSAGE" : "solo en español"
        }
        
        """)
    }
    
    func testSQLiteWebSpanishWithFallback() throws {
        let resource = try XCTUnwrap(Bundle.module.url(forResource: "test_multi_language", withExtension: "sqlite"))
        let localizer = Process.LocalizerProcess()
        
        localizer.arguments = ["catalog", "export", "json", "es", "--fallback", "--path", resource.path]
        try localizer.run()
        
        XCTAssertEqual(localizer.output, """
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
    
    // MARK: - Filesystem
    
    func testFilesystemAppleEnglish() throws {
        let resource = try XCTUnwrap(Bundle.module.resourceURL)
        let directory = resource
            .appendingPathComponent("StructuredResources")
            .appendingPathComponent("MultiLanguageCatalog")
        
        let localizer = Process.LocalizerProcess()
        
        localizer.arguments = ["catalog", "export", "apple", "en", "--storage" , "filesystem", "--path", directory.path]
        try localizer.run()
        
        XCTAssertEqual(localizer.output, """
        "APPLICATION_NAME" = "Lingua";
        "GREETING" = "Hello World!";
        "HIDDEN_MESSAGE" = "solo en español";
        "PLATFORM_ANDROID" = "Android";
        "PLATFORM_APPLE" = "Apple";
        "PLATFORM_WEB" = "Web";
        
        """)
    }
    
    func testFilesystemAppleSpanish() throws {
        let resource = try XCTUnwrap(Bundle.module.resourceURL)
        let directory = resource
            .appendingPathComponent("StructuredResources")
            .appendingPathComponent("MultiLanguageCatalog")
        
        let localizer = Process.LocalizerProcess()
        
        localizer.arguments = ["catalog", "export", "apple", "es", "--storage", "filesystem", "--path", directory.path]
        try localizer.run()
        
        XCTAssertEqual(localizer.output, """
        "APPLICATION_NAME" = "Lingua";
        "GREETING" = "Hola Mundo!";
        "HIDDEN_MESSAGE" = "solo en español";
        "PLATFORM_ANDROID" = "Android";
        "PLATFORM_APPLE" = "Apple";
        "PLATFORM_WEB" = "Web";
        
        """)
    }
    
    func testFilesystemAndroidEnglish() throws {
        let resource = try XCTUnwrap(Bundle.module.resourceURL)
        let directory = resource
            .appendingPathComponent("StructuredResources")
            .appendingPathComponent("MultiLanguageCatalog")
        
        let localizer = Process.LocalizerProcess()
        
        localizer.arguments = ["catalog", "export", "android", "en", "--storage", "filesystem", "--path", directory.path]
        try localizer.run()
        
        // TODO: Should this produce a line for 'HIDDEN_MESSAGE' in 'default language' instance?
        XCTAssertEqual(localizer.output, """
        <?xml version="1.0" encoding="UTF-8"?>
        
          <resources xmlns:tools="http://schemas.android.com/tools">
            <string name="APPLICATION_NAME">Lingua</string>
            <string name="GREETING">Hello World!</string>
            <string name="PLATFORM_ANDROID">Android</string>
            <string name="PLATFORM_APPLE">Apple</string>
            <string name="PLATFORM_WEB">Web</string>
          </resources>
        
        """)
    }
    
    func testFilesystemAndroidSpanish() throws {
        let resource = try XCTUnwrap(Bundle.module.resourceURL)
        let directory = resource
            .appendingPathComponent("StructuredResources")
            .appendingPathComponent("MultiLanguageCatalog")
        
        let localizer = Process.LocalizerProcess()
        
        localizer.arguments = ["catalog", "export", "android", "es", "--storage", "filesystem", "--path", directory.path]
        try localizer.run()
        
        XCTAssertEqual(localizer.output, """
        <?xml version="1.0" encoding="UTF-8"?>
        
          <resources xmlns:tools="http://schemas.android.com/tools">
            <string name="GREETING">Hola Mundo!</string>
            <string name="HIDDEN_MESSAGE">solo en español</string>
          </resources>
        
        """)
    }
    
    func testFilesystemAndroidSpanishWithFallback() throws {
        let resource = try XCTUnwrap(Bundle.module.resourceURL)
        let directory = resource
            .appendingPathComponent("StructuredResources")
            .appendingPathComponent("MultiLanguageCatalog")
        
        let localizer = Process.LocalizerProcess()
        
        localizer.arguments = ["catalog", "export", "android", "es", "--fallback", "--storage", "filesystem", "--path", directory.path]
        try localizer.run()
        
        XCTAssertEqual(localizer.output, """
        <?xml version="1.0" encoding="UTF-8"?>
        
          <resources xmlns:tools="http://schemas.android.com/tools">
            <string name="APPLICATION_NAME">Lingua</string>
            <string name="GREETING">Hola Mundo!</string>
            <string name="HIDDEN_MESSAGE">solo en español</string>
            <string name="PLATFORM_ANDROID">Android</string>
            <string name="PLATFORM_APPLE">Apple</string>
            <string name="PLATFORM_WEB">Web</string>
          </resources>
        
        """)
    }
    
    func testFilesystemWebEnglish() throws {
        let resource = try XCTUnwrap(Bundle.module.resourceURL)
        let directory = resource
            .appendingPathComponent("StructuredResources")
            .appendingPathComponent("MultiLanguageCatalog")
        
        let localizer = Process.LocalizerProcess()
        
        localizer.arguments = ["catalog", "export", "json", "en", "--storage", "filesystem", "--path", directory.path]
        try localizer.run()
        
        // TODO: Should this produce a line for 'HIDDEN_MESSAGE' in 'default language' instance?
        XCTAssertEqual(localizer.output, """
        {
          "APPLICATION_NAME" : "Lingua",
          "GREETING" : "Hello World!",
          "PLATFORM_ANDROID" : "Android",
          "PLATFORM_APPLE" : "Apple",
          "PLATFORM_WEB" : "Web"
        }
        
        """)
    }
    
    func testFilesystemWebSpanish() throws {
        let resource = try XCTUnwrap(Bundle.module.resourceURL)
        let directory = resource
            .appendingPathComponent("StructuredResources")
            .appendingPathComponent("MultiLanguageCatalog")
            
        let localizer = Process.LocalizerProcess()
        
        localizer.arguments = ["catalog", "export", "json", "es", "--storage", "filesystem", "--path", directory.path]
        try localizer.run()
        
        XCTAssertEqual(localizer.output, """
        {
          "GREETING" : "Hola Mundo!",
          "HIDDEN_MESSAGE" : "solo en español"
        }
        
        """)
    }
    
    func testFilesystemWebSpanishWithFallback() throws {
        let resource = try XCTUnwrap(Bundle.module.resourceURL)
        let directory = resource
            .appendingPathComponent("StructuredResources")
            .appendingPathComponent("MultiLanguageCatalog")
        
        let localizer = Process.LocalizerProcess()
        
        localizer.arguments = ["catalog", "export", "json", "es", "--fallback", "--storage", "filesystem", "--path", directory.path]
        try localizer.run()
        
        XCTAssertEqual(localizer.output, """
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
