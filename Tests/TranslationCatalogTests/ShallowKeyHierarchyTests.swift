import LocaleSupport
import Testing
@testable import TranslationCatalog
@testable import TranslationCatalogIO

struct ShallowKeyHierarchyTests {

    let keys: [LocalizationKey] = [
        LocalizationKey(
            key: "GREETING",
            defaultValue: "Hello World!",
        ),
        LocalizationKey(
            key: "APPLICATION_NAME",
            defaultValue: "Lingua",
        ),
        LocalizationKey(
            key: "HIDDEN_MESSAGE",
            defaultValue: "",
        ),
        LocalizationKey(
            key: "PLATFORM_ANDROID",
            defaultValue: "Android",
        ),
        LocalizationKey(
            key: "PLATFORM_APPLE",
            defaultValue: "Apple",
        ),
        LocalizationKey(
            key: "PLATFORM_APPLE_MAC",
            defaultValue: "macOS",
        ),
        LocalizationKey(
            key: "PLATFORM_WEB",
            defaultValue: "Web",
        ),
        LocalizationKey(
            key: "ZULU_TIME_DEFINITION",
            defaultValue: "definition",
        ),
    ]

    var hierarchy: KeyHierarchy

    init() throws {
        hierarchy = try KeyHierarchy.make(with: keys)
    }

    @Test func hierarchyGeneration() {
        #expect(hierarchy.contents.count == 1)
        #expect(Array(hierarchy.contents.keys) == [
            ["GREETING"],
        ])
        #expect(hierarchy.nodes.count == 4)
        #expect(hierarchy.nodes.map(\.id) == [
            ["APPLICATION"],
            ["HIDDEN"],
            ["PLATFORM"],
            ["ZULU"],
        ])
        #expect(!hierarchy.isOrphan)
        #expect(hierarchy.containsOrphans)
        #expect(!hierarchy.isPhantom)
        #expect(hierarchy.containsPhantoms)
    }

    @Test func nodeAtPath() {
        var node = hierarchy.node(at: [["UNKNOWN"]])
        #expect(node == nil)
        node = hierarchy.node(at: [["HIDDEN"]])
        #expect(node != nil)
        node = hierarchy.node(at: [["PLATFORM"], ["APPLE"]])
        #expect(node != nil)
    }

    @Test func removeNodeAtPath() {
        var hierarchy = hierarchy
        let node = hierarchy.removeNode(at: [["PLATFORM"], ["APPLE"]])
        #expect(node != nil)
    }

    @Test func orphanNodes() {
        let nodes = hierarchy.orphanNodes()
        #expect(nodes.count == 4)
        #expect(nodes == [
            [["APPLICATION"]],
            [["HIDDEN"]],
            [["PLATFORM"], ["APPLE"]],
            [["ZULU"], ["TIME"]],
        ])
    }

    @Test func phantomNodes() {
        let nodes = hierarchy.phantomNodes()
        #expect(nodes.count == 1)
        #expect(nodes == [
            [["ZULU"]],
        ])
    }

    @Test func localizedStringConvertible() {
        let syntax = hierarchy.syntaxTree()
        #expect(syntax == """
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

    @Test func localizedStringConvertiblePhantomOnlyCompression() throws {
        let syntax = try hierarchy
            .compressed(mergeOrphans: false)
            .syntaxTree()
        #expect(syntax == """
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

    @Test func localizedStringConvertibleOrphanOnlyCompression() throws {
        let key = LocalizationKey(
            key: "ZULU_ZONE",
            defaultValue: "zone",
        )
        var test = hierarchy
        try test.processKey(key, path: [["ZULU"], ["ZONE"]])
        let syntax = try test
            .compressed(mergePhantoms: false)
            .syntaxTree()
        #expect(syntax == """
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

    @Test func localizedStringConvertibleCompression() throws {
        let syntax = try hierarchy
            .compressed()
            .syntaxTree()
        #expect(syntax == """
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

    @Test func localizedStringKey() {
        let syntax = hierarchy.syntaxTree(style: .swiftUI)
        #expect(syntax == """
        import SwiftUI

        @MainActor extension LocalizedStringKey {
            /// Hello World!
            static let greeting: LocalizedStringKey = "GREETING"

            enum Application {
                /// Lingua
                static let name: LocalizedStringKey = "APPLICATION_NAME"
            }

            enum Hidden {
                static let message: LocalizedStringKey = "HIDDEN_MESSAGE"
            }

            enum Platform {
                /// Android
                static let android: LocalizedStringKey = "PLATFORM_ANDROID"
                /// Apple
                static let apple: LocalizedStringKey = "PLATFORM_APPLE"
                /// Web
                static let web: LocalizedStringKey = "PLATFORM_WEB"

                enum Apple {
                    /// macOS
                    static let mac: LocalizedStringKey = "PLATFORM_APPLE_MAC"
                }
            }

            enum Zulu {

                enum Time {
                    /// definition
                    static let definition: LocalizedStringKey = "ZULU_TIME_DEFINITION"
                }
            }
        }
        """)
    }

    @Test func localizedStringKeyPhantomOnlyCompression() throws {
        let syntax = try hierarchy
            .compressed(mergeOrphans: false)
            .syntaxTree(style: .swiftUI)
        #expect(syntax == """
        import SwiftUI

        @MainActor extension LocalizedStringKey {
            /// Hello World!
            static let greeting: LocalizedStringKey = "GREETING"

            enum Application {
                /// Lingua
                static let name: LocalizedStringKey = "APPLICATION_NAME"
            }

            enum Hidden {
                static let message: LocalizedStringKey = "HIDDEN_MESSAGE"
            }

            enum Platform {
                /// Android
                static let android: LocalizedStringKey = "PLATFORM_ANDROID"
                /// Apple
                static let apple: LocalizedStringKey = "PLATFORM_APPLE"
                /// Web
                static let web: LocalizedStringKey = "PLATFORM_WEB"

                enum Apple {
                    /// macOS
                    static let mac: LocalizedStringKey = "PLATFORM_APPLE_MAC"
                }
            }

            enum ZuluTime {
                /// definition
                static let definition: LocalizedStringKey = "ZULU_TIME_DEFINITION"
            }
        }
        """)
    }

    @Test func localizedStringKeyOrphanOnlyCompression() throws {
        let key = LocalizationKey(
            key: "ZULU_ZONE",
            defaultValue: "zone",
        )
        var test = hierarchy
        try test.processKey(key, path: [["ZULU"], ["ZONE"]])
        let syntax = try test
            .compressed(mergePhantoms: false)
            .syntaxTree(style: .swiftUI)
        #expect(syntax == """
        import SwiftUI

        @MainActor extension LocalizedStringKey {
            /// Lingua
            static let applicationName: LocalizedStringKey = "APPLICATION_NAME"
            /// Hello World!
            static let greeting: LocalizedStringKey = "GREETING"
            static let hiddenMessage: LocalizedStringKey = "HIDDEN_MESSAGE"

            enum Platform {
                /// Android
                static let android: LocalizedStringKey = "PLATFORM_ANDROID"
                /// Apple
                static let apple: LocalizedStringKey = "PLATFORM_APPLE"
                /// macOS
                static let appleMac: LocalizedStringKey = "PLATFORM_APPLE_MAC"
                /// Web
                static let web: LocalizedStringKey = "PLATFORM_WEB"
            }

            enum Zulu {
                /// definition
                static let timeDefinition: LocalizedStringKey = "ZULU_TIME_DEFINITION"
                /// zone
                static let zone: LocalizedStringKey = "ZULU_ZONE"
            }
        }
        """)
    }

    @Test func localizedStringKeyCompression() throws {
        let syntax = try hierarchy
            .compressed()
            .syntaxTree(style: .swiftUI)
        #expect(syntax == """
        import SwiftUI

        @MainActor extension LocalizedStringKey {
            /// Lingua
            static let applicationName: LocalizedStringKey = "APPLICATION_NAME"
            /// Hello World!
            static let greeting: LocalizedStringKey = "GREETING"
            static let hiddenMessage: LocalizedStringKey = "HIDDEN_MESSAGE"
            /// definition
            static let zuluTimeDefinition: LocalizedStringKey = "ZULU_TIME_DEFINITION"

            enum Platform {
                /// Android
                static let android: LocalizedStringKey = "PLATFORM_ANDROID"
                /// Apple
                static let apple: LocalizedStringKey = "PLATFORM_APPLE"
                /// macOS
                static let appleMac: LocalizedStringKey = "PLATFORM_APPLE_MAC"
                /// Web
                static let web: LocalizedStringKey = "PLATFORM_WEB"
            }
        }
        """)
    }
}
