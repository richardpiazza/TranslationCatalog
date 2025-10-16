import XCTest

final class CatalogSyntaxTests: LocalizerTestCase {

    override var resource: TestResource {
        .directory(
            Bundle.module.resourceURL?
                .appending(path: "StructuredResources", directoryHint: .isDirectory)
                .appending(path: "MultiLanguageCatalog", directoryHint: .isDirectory)
        )
    }

    func testSyntax() throws {
        let process = LocalizerProcess()
        let output = try process.runOutputting(with: [
            "catalog", "syntax", "--storage", "filesystem", "--path", directory.path(),
        ])

        XCTAssertEqual(output, """
        import LocaleSupport

        enum LocalizedStrings: String, LocalizedStringConvertible {
            /// Expression with translations for each language in the catalog.
            case greeting = "Hello World!"

            enum Application: String, LocalizedStringConvertible {
                /// This expression has a single 'en' translation.
                case name = "Lingua"

                var prefix: String? {
                    "application"
                }
            }

            enum Hidden: String, LocalizedStringConvertible {
                /// Expression with 'es' translation only, no default language translations.
                case message = ""

                var prefix: String? {
                    "hidden"
                }
            }

            enum Platform: String, LocalizedStringConvertible {
                /// Platform identifier in 'en' only.
                case android = "Android"
                /// Platform identifier in 'en' only.
                case apple = "Apple"
                /// Platform identifier in 'en' only.
                case web = "Web"

                var prefix: String? {
                    "platform"
                }
            }
        }

        """)
    }
}
