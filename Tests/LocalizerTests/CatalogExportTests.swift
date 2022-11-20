import XCTest

final class CatalogExportTests: XCTestCase {
    
    func testAppleEN() throws {
        let resource = try XCTUnwrap(Bundle.module.url(forResource: "test_multi_language", withExtension: "sqlite"))
        let localizer = Process.LocalizerProcess()
        
        localizer.arguments = ["catalog", "export", "apple", "en", "--path", resource.path]
        try localizer.run()
        
        XCTAssertEqual(localizer.output, """
        "APPLICATION_NAME" = "Ligua";
        "GREETING" = "Hello World!";
        "PLATFORM_ANDROID" = "Android";
        "PLATFORM_APPLE" = "Apple";
        "PLATFORM_WEB" = "Web";
        
        """)
    }
    
    func testAndroidEN() throws {
        let resource = try XCTUnwrap(Bundle.module.url(forResource: "test_multi_language", withExtension: "sqlite"))
        let localizer = Process.LocalizerProcess()
        
        localizer.arguments = ["catalog", "export", "android", "en", "--path", resource.path]
        try localizer.run()
        
        XCTAssertEqual(localizer.output, """
        <?xml version="1.0" encoding="UTF-8"?>
        
          <resources xmlns:tools="http://schemas.android.com/tools">
            <string name="APPLICATION_NAME">Ligua</string>
            <string name="GREETING">Hello World!</string>
            <string name="PLATFORM_ANDROID">Android</string>
            <string name="PLATFORM_APPLE">Apple</string>
            <string name="PLATFORM_WEB">Web</string>
          </resources>
        
        """)
    }
}
