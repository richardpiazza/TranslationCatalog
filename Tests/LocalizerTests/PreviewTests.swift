import Foundation
import Testing

struct LocalizerPreviewTests {

    @Test func previewAndroidXML() throws {
        let resource: TestResource = .file(Bundle.module.url(forResource: "Strings", withExtension: "xml"))
        let process = try LocalizerProcess(copying: resource)
        let output = try process.runOutputting(with: [
            "preview", "android", process.url.path(),
        ])

        #expect(output == """
        APP_NAME = Localizer
        NAVIGATION_TITLE = Welcome
        PERFORM_ACTION = Make It Go!

        """)

        try process.recycle()
    }

    @Test func previewAppleStrings() throws {
        let resource: TestResource = .file(Bundle.module.url(forResource: "Localizable", withExtension: "strings"))
        let process = try LocalizerProcess(copying: resource)
        let output = try process.runOutputting(with: [
            "preview", "apple-strings", process.url.path(),
        ])

        #expect(output == """
        APP_NAME = Localizer
        NAVIGATION_TITLE = Welcome
        PERFORM_ACTION = Make It Go!

        """)

        try process.recycle()
    }
}
