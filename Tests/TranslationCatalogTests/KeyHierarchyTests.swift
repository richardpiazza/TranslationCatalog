import LocaleSupport
@testable import TranslationCatalog
@testable import TranslationCatalogIO
import XCTest

final class KeyHierarchyTests: XCTestCase {

    let keys: [LocalizationKey] = [
        LocalizationKey(
            key: "GREETING",
            defaultValue: "Hello World!"
        ),
        LocalizationKey(
            key: "APPLICATION_NAME",
            defaultValue: "Lingua"
        ),
        LocalizationKey(
            key: "HIDDEN_MESSAGE",
            defaultValue: ""
        ),
        LocalizationKey(
            key: "PLATFORM_ANDROID",
            defaultValue: "Android"
        ),
        LocalizationKey(
            key: "PLATFORM_APPLE",
            defaultValue: "Apple"
        ),
        LocalizationKey(
            key: "PLATFORM_APPLE_MAC",
            defaultValue: "macOS"
        ),
        LocalizationKey(
            key: "PLATFORM_WEB",
            defaultValue: "Web"
        ),
        LocalizationKey(
            key: "ZULU_TIME_DEFINITION",
            defaultValue: "definition"
        ),
    ]

    var hierarchy: KeyHierarchy!

    override func setUpWithError() throws {
        try super.setUpWithError()
        hierarchy = try KeyHierarchy.make(with: keys)
    }

    func testHierarchyGeneration() {
        XCTAssertEqual(hierarchy.contents.count, 1)
        XCTAssertEqual(Array(hierarchy.contents.keys), [
            ["GREETING"],
        ])
        XCTAssertEqual(hierarchy.nodes.count, 4)
        XCTAssertEqual(hierarchy.nodes.map(\.id), [
            ["APPLICATION"],
            ["HIDDEN"],
            ["PLATFORM"],
            ["ZULU"],
        ])
        XCTAssertFalse(hierarchy.isOrphan)
        XCTAssertTrue(hierarchy.containsOrphans)
        XCTAssertFalse(hierarchy.isPhantom)
        XCTAssertTrue(hierarchy.containsPhantoms)
    }

    func testNodeAtPath() {
        var node = hierarchy.node(at: [["UNKNOWN"]])
        XCTAssertNil(node)
        node = hierarchy.node(at: [["HIDDEN"]])
        XCTAssertNotNil(node)
        node = hierarchy.node(at: [["PLATFORM"], ["APPLE"]])
        XCTAssertNotNil(node)
    }

    func testRemoveNodeAtPath() {
        let node = hierarchy.removeNode(at: [["PLATFORM"], ["APPLE"]])
        XCTAssertNotNil(node)
    }

    func testOrphanNodes() {
        let nodes = hierarchy.orphanNodes()
        XCTAssertEqual(nodes.count, 4)
        XCTAssertEqual(nodes, [
            [["APPLICATION"]],
            [["HIDDEN"]],
            [["PLATFORM"], ["APPLE"]],
            [["ZULU"], ["TIME"]],
        ])
    }

    func testPhantomNodes() {
        let nodes = hierarchy.phantomNodes()
        XCTAssertEqual(nodes.count, 1)
        XCTAssertEqual(nodes, [
            [["ZULU"]],
        ])
    }

    func testLocalizedStringConvertible() {
        let syntax = hierarchy.syntaxTree()
        XCTAssertEqual(syntax, """
        import LocaleSupport

        enum LocalizedStrings: String, LocalizedStringConvertible {
            case greeting = "Hello World!"

            enum Application: String, LocalizedStringConvertible {
                case name = "Lingua"

                var prefix: String? {
                    "application"
                }
            }

            enum Hidden: String, LocalizedStringConvertible {
                case message = ""

                var prefix: String? {
                    "hidden"
                }
            }

            enum Platform: String, LocalizedStringConvertible {
                case android = "Android"
                case apple = "Apple"
                case web = "Web"

                var prefix: String? {
                    "platform"
                }

                enum Apple: String, LocalizedStringConvertible {
                    case mac = "macOS"

                    var prefix: String? {
                        "platformApple"
                    }
                }
            }

            enum Zulu {

                enum Time: String, LocalizedStringConvertible {
                    case definition

                    var prefix: String? {
                        "zuluTime"
                    }
                }
            }
        }
        """)
    }

    func testPhantomOnlyCompression() throws {
        let syntax = try hierarchy
            .compressed(mergeOrphans: false)
            .syntaxTree()
        XCTAssertEqual(syntax, """
        import LocaleSupport

        enum LocalizedStrings: String, LocalizedStringConvertible {
            case greeting = "Hello World!"

            enum Application: String, LocalizedStringConvertible {
                case name = "Lingua"

                var prefix: String? {
                    "application"
                }
            }

            enum Hidden: String, LocalizedStringConvertible {
                case message = ""

                var prefix: String? {
                    "hidden"
                }
            }

            enum Platform: String, LocalizedStringConvertible {
                case android = "Android"
                case apple = "Apple"
                case web = "Web"

                var prefix: String? {
                    "platform"
                }

                enum Apple: String, LocalizedStringConvertible {
                    case mac = "macOS"

                    var prefix: String? {
                        "platformApple"
                    }
                }
            }

            enum ZuluTime: String, LocalizedStringConvertible {
                case definition

                var prefix: String? {
                    "zuluTime"
                }
            }
        }
        """)
    }

    func testOrphanOnlyCompression() throws {
        let key = LocalizationKey(
            key: "ZULU_ZONE",
            defaultValue: "zone"
        )
        var test = try XCTUnwrap(hierarchy)
        try test.processKey(key, path: [["ZULU"], ["ZONE"]])
        let syntax = try test
            .compressed(mergePhantoms: false)
            .syntaxTree()
        XCTAssertEqual(syntax, """
        import LocaleSupport

        enum LocalizedStrings: String, LocalizedStringConvertible {
            case applicationName = "Lingua"
            case greeting = "Hello World!"
            case hiddenMessage = ""

            enum Platform: String, LocalizedStringConvertible {
                case android = "Android"
                case apple = "Apple"
                case appleMac = "macOS"
                case web = "Web"

                var prefix: String? {
                    "platform"
                }
            }

            enum Zulu: String, LocalizedStringConvertible {
                case timeDefinition = "definition"
                case zone

                var prefix: String? {
                    "zulu"
                }
            }
        }
        """)
    }

    func testCompression() throws {
        let syntax = try hierarchy
            .compressed()
            .syntaxTree()
        XCTAssertEqual(syntax, """
        import LocaleSupport

        enum LocalizedStrings: String, LocalizedStringConvertible {
            case applicationName = "Lingua"
            case greeting = "Hello World!"
            case hiddenMessage = ""
            case zuluTimeDefinition = "definition"

            enum Platform: String, LocalizedStringConvertible {
                case android = "Android"
                case apple = "Apple"
                case appleMac = "macOS"
                case web = "Web"

                var prefix: String? {
                    "platform"
                }
            }
        }
        """)
    }
}
