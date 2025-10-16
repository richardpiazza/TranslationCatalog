import LocaleSupport
@testable import TranslationCatalog
@testable import TranslationCatalogIO
import XCTest

final class KeyHierarchyTests: XCTestCase {

    let expressions: [TranslationCatalog.Expression] = [
        Expression(
            id: UUID(uuidString: "0681BB4E-A63F-4E3C-AA15-5E152844B7EC")!,
            key: "GREETING",
            value: "Hello World!",
            languageCode: .english
        ),
        Expression(
            id: UUID(uuidString: "B7FA5A95-2FE5-4887-8619-566CDA83F23E")!,
            key: "APPLICATION_NAME",
            value: "Lingua",
            languageCode: .english
        ),
        Expression(
            id: UUID(uuidString: "76C37D84-8AF3-4011-88B1-BCC80B2D6C6A")!,
            key: "HIDDEN_MESSAGE",
            value: "",
            languageCode: .english
        ),
        Expression(
            id: UUID(uuidString: "52B6650F-F041-4CA3-ACE6-38E7930D026D")!,
            key: "PLATFORM_ANDROID",
            value: "Android",
            languageCode: .english
        ),
        Expression(
            id: UUID(uuidString: "943D6EF9-A37A-4BB6-8C93-05FECAD1DA8C")!,
            key: "PLATFORM_APPLE",
            value: "Apple",
            languageCode: .english
        ),
        Expression(
            id: UUID(uuidString: "95C73B79-8111-43E7-85AC-EF4C74586594")!,
            key: "PLATFORM_APPLE_MAC",
            value: "macOS",
            languageCode: .english
        ),
        Expression(
            id: UUID(uuidString: "E5792937-3C63-4C10-8B58-0E405E76AB56")!,
            key: "PLATFORM_WEB",
            value: "Web",
            languageCode: .english
        ),
        Expression(
            id: UUID(uuidString: "185CA880-88DB-4CA6-98A4-FD544B908900")!,
            key: "ZULU_TIME_DEFINITION",
            value: "definition",
            languageCode: .english
        ),
    ]

    var hierarchy: KeyHierarchy!

    override func setUpWithError() throws {
        try super.setUpWithError()
        hierarchy = try KeyHierarchy.make(with: expressions)
    }

    func testHierarchyGeneration() throws {
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

    func testNodeAtPath() throws {
        var node = hierarchy.node(at: [["UNKNOWN"]])
        XCTAssertNil(node)
        node = hierarchy.node(at: [["HIDDEN"]])
        XCTAssertNotNil(node)
        node = hierarchy.node(at: [["PLATFORM"], ["APPLE"]])
        XCTAssertNotNil(node)
    }

    func testRemoveNodeAtPath() throws {
        let node = hierarchy.removeNode(at: [["PLATFORM"], ["APPLE"]])
        XCTAssertNotNil(node)
    }

    func testOrphanNodes() throws {
        let nodes = hierarchy.orphanNodes()
        XCTAssertEqual(nodes.count, 4)
        XCTAssertEqual(nodes, [
            [["APPLICATION"]],
            [["HIDDEN"]],
            [["PLATFORM"], ["APPLE"]],
            [["ZULU"], ["TIME"]],
        ])
    }

    func testPhantomNodes() throws {
        let nodes = hierarchy.phantomNodes()
        XCTAssertEqual(nodes.count, 1)
        XCTAssertEqual(nodes, [
            [["ZULU"]],
        ])
    }

    func testLocalizedStringConvertible() throws {
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
        var test = hierarchy!
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
