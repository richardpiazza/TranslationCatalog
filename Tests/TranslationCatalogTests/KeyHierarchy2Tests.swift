import LocaleSupport
@testable import TranslationCatalog
@testable import TranslationCatalogIO
import XCTest

final class KeyHierarchy2Tests: XCTestCase {

    let expressions: [TranslationCatalog.Expression] = [
        Expression(
            id: UUID(uuidString: "0681BB4E-A63F-4E3C-AA15-5E152844B7EC")!,
            key: "PAYMENT_METHOD_ADD_ACTION",
            value: "Add payment method",
            languageCode: .english
        ),
        Expression(
            id: UUID(uuidString: "B7FA5A95-2FE5-4887-8619-566CDA83F23E")!,
            key: "PAYMENT_METHOD_ADD_CARD_FAILURE_MESSAGE",
            value: "Your payment method could not be added at this time.",
            languageCode: .english
        ),
        Expression(
            id: UUID(uuidString: "76C37D84-8AF3-4011-88B1-BCC80B2D6C6A")!,
            key: "PAYMENT_METHOD_ADD_CARD_SUCCESS_MESSAGE",
            value: "Your payment method has been added.",
            languageCode: .english
        ),
        Expression(
            id: UUID(uuidString: "52B6650F-F041-4CA3-ACE6-38E7930D026D")!,
            key: "PAYMENT_METHOD_CONFIRM_DELETE",
            value: "Are you sure you want to delete this payment method?",
            languageCode: .english
        ),
        Expression(
            id: UUID(uuidString: "943D6EF9-A37A-4BB6-8C93-05FECAD1DA8C")!,
            key: "PAYMENT_METHOD_EXPIRATION_ABBREVIATION",
            value: "Exp",
            languageCode: .english
        ),
        Expression(
            id: UUID(uuidString: "95C73B79-8111-43E7-85AC-EF4C74586594")!,
            key: "PAYMENT_METHOD_NAVIGATION_TITLE",
            value: "Manage Payments",
            languageCode: .english
        ),
        Expression(
            id: UUID(uuidString: "E5792937-3C63-4C10-8B58-0E405E76AB56")!,
            key: "PAYMENT_METHOD_REMOVE_CARD_FAILURE_MESSAGE",
            value: "Your payment method could not be deleted at this time.",
            languageCode: .english
        ),
        Expression(
            id: UUID(uuidString: "185CA880-88DB-4CA6-98A4-FD544B908900")!,
            key: "PAYMENT_METHOD_REMOVE_CARD_SUCCESS_MESSAGE",
            value: "Your payment method has been deleted.",
            languageCode: .english
        ),
        Expression(
            id: UUID(uuidString: "9E141C73-8D8C-40B6-AF56-AFD94C230752")!,
            key: "PAYMENT_METHOD_SECTION_TITLE",
            value: "Payment Methods",
            languageCode: .english
        ),
    ]

    var hierarchy: KeyHierarchy!

    override func setUpWithError() throws {
        try super.setUpWithError()
        hierarchy = try KeyHierarchy.make(with: expressions)
    }

    func testHierarchyGeneration() throws {
        XCTAssertTrue(hierarchy.contents.isEmpty)
        XCTAssertEqual(hierarchy.nodes.count, 1)
        XCTAssertEqual(hierarchy.nodes.map(\.id), [
            ["PAYMENT"],
        ])
        XCTAssertFalse(hierarchy.isOrphan)
        XCTAssertTrue(hierarchy.containsOrphans)
        XCTAssertTrue(hierarchy.isPhantom)
        XCTAssertTrue(hierarchy.containsPhantoms)
    }

    func testNodeAtPath() throws {
        var node = hierarchy.node(at: [["UNKNOWN"]])
        XCTAssertNil(node)
        node = hierarchy.node(at: [["PAYMENT"], ["METHOD"], ["EXPIRATION"]])
        XCTAssertNotNil(node)
        node = hierarchy.node(at: [["PAYMENT"], ["METHOD"], ["ADD"], ["CARD"], ["FAILURE"]])
        XCTAssertNotNil(node)
    }

    func testRemoveNodeAtPath() throws {
        let node = hierarchy.removeNode(at: [["PAYMENT"], ["METHOD"], ["CONFIRM"]])
        XCTAssertNotNil(node)
    }

    func testOrphanNodes() throws {
        let nodes = hierarchy.orphanNodes()
        XCTAssertEqual(nodes.count, 8)
        XCTAssertEqual(nodes, [
            [["PAYMENT"], ["METHOD"], ["ADD"], ["CARD"], ["FAILURE"]],
            [["PAYMENT"], ["METHOD"], ["ADD"], ["CARD"], ["SUCCESS"]],
            [["PAYMENT"], ["METHOD"], ["CONFIRM"]],
            [["PAYMENT"], ["METHOD"], ["EXPIRATION"]],
            [["PAYMENT"], ["METHOD"], ["NAVIGATION"]],
            [["PAYMENT"], ["METHOD"], ["REMOVE"], ["CARD"], ["FAILURE"]],
            [["PAYMENT"], ["METHOD"], ["REMOVE"], ["CARD"], ["SUCCESS"]],
            [["PAYMENT"], ["METHOD"], ["SECTION"]],
        ])
    }

    func testPhantomNodes() throws {
        let nodes = hierarchy.phantomNodes()
        XCTAssertEqual(nodes.count, 2)
        XCTAssertEqual(nodes, [
            [["PAYMENT"]],
            [["PAYMENT"], ["METHOD"], ["REMOVE"]],
        ])
    }

    func testLocalizedStringConvertible() throws {
        let syntax = hierarchy.syntaxTree()
        XCTAssertEqual(syntax, """
        import LocaleSupport

        enum LocalizedStrings {

            enum Payment {

                enum Method {

                    enum Add: String, LocalizedStringConvertible {
                        case action = "Add payment method"

                        var prefix: String? {
                            "paymentMethodAdd"
                        }

                        enum Card {

                            enum Failure: String, LocalizedStringConvertible {
                                case message = "Your payment method could not be added at this time."

                                var prefix: String? {
                                    "paymentMethodAddCardFailure"
                                }
                            }

                            enum Success: String, LocalizedStringConvertible {
                                case message = "Your payment method has been added."

                                var prefix: String? {
                                    "paymentMethodAddCardSuccess"
                                }
                            }
                        }
                    }

                    enum Confirm: String, LocalizedStringConvertible {
                        case delete = "Are you sure you want to delete this payment method?"

                        var prefix: String? {
                            "paymentMethodConfirm"
                        }
                    }

                    enum Expiration: String, LocalizedStringConvertible {
                        case abbreviation = "Exp"

                        var prefix: String? {
                            "paymentMethodExpiration"
                        }
                    }

                    enum Navigation: String, LocalizedStringConvertible {
                        case title = "Manage Payments"

                        var prefix: String? {
                            "paymentMethodNavigation"
                        }
                    }

                    enum Remove {

                        enum Card {

                            enum Failure: String, LocalizedStringConvertible {
                                case message = "Your payment method could not be deleted at this time."

                                var prefix: String? {
                                    "paymentMethodRemoveCardFailure"
                                }
                            }

                            enum Success: String, LocalizedStringConvertible {
                                case message = "Your payment method has been deleted."

                                var prefix: String? {
                                    "paymentMethodRemoveCardSuccess"
                                }
                            }
                        }
                    }

                    enum Section: String, LocalizedStringConvertible {
                        case title = "Payment Methods"

                        var prefix: String? {
                            "paymentMethodSection"
                        }
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

        enum LocalizedStrings {

            enum PaymentMethod {

                enum Add: String, LocalizedStringConvertible {
                    case action = "Add payment method"

                    var prefix: String? {
                        "paymentMethodAdd"
                    }

                    enum Card {

                        enum Failure: String, LocalizedStringConvertible {
                            case message = "Your payment method could not be added at this time."

                            var prefix: String? {
                                "paymentMethodAddCardFailure"
                            }
                        }

                        enum Success: String, LocalizedStringConvertible {
                            case message = "Your payment method has been added."

                            var prefix: String? {
                                "paymentMethodAddCardSuccess"
                            }
                        }
                    }
                }

                enum Confirm: String, LocalizedStringConvertible {
                    case delete = "Are you sure you want to delete this payment method?"

                    var prefix: String? {
                        "paymentMethodConfirm"
                    }
                }

                enum Expiration: String, LocalizedStringConvertible {
                    case abbreviation = "Exp"

                    var prefix: String? {
                        "paymentMethodExpiration"
                    }
                }

                enum Navigation: String, LocalizedStringConvertible {
                    case title = "Manage Payments"

                    var prefix: String? {
                        "paymentMethodNavigation"
                    }
                }

                enum RemoveCard {

                    enum Failure: String, LocalizedStringConvertible {
                        case message = "Your payment method could not be deleted at this time."

                        var prefix: String? {
                            "paymentMethodRemoveCardFailure"
                        }
                    }

                    enum Success: String, LocalizedStringConvertible {
                        case message = "Your payment method has been deleted."

                        var prefix: String? {
                            "paymentMethodRemoveCardSuccess"
                        }
                    }
                }

                enum Section: String, LocalizedStringConvertible {
                    case title = "Payment Methods"

                    var prefix: String? {
                        "paymentMethodSection"
                    }
                }
            }
        }
        """)
    }

    func testOrphanOnlyCompression() throws {
        let syntax = try hierarchy
            .compressed(mergePhantoms: false)
            .syntaxTree()
        XCTAssertEqual(syntax, """
        import LocaleSupport

        enum LocalizedStrings {

            enum Payment {

                enum Method: String, LocalizedStringConvertible {
                    case confirmDelete = "Are you sure you want to delete this payment method?"
                    case expirationAbbreviation = "Exp"
                    case navigationTitle = "Manage Payments"
                    case sectionTitle = "Payment Methods"

                    var prefix: String? {
                        "paymentMethod"
                    }

                    enum Add: String, LocalizedStringConvertible {
                        case action = "Add payment method"

                        var prefix: String? {
                            "paymentMethodAdd"
                        }

                        enum Card: String, LocalizedStringConvertible {
                            case failureMessage = "Your payment method could not be added at this time."
                            case successMessage = "Your payment method has been added."

                            var prefix: String? {
                                "paymentMethodAddCard"
                            }
                        }
                    }

                    enum Remove {

                        enum Card: String, LocalizedStringConvertible {
                            case failureMessage = "Your payment method could not be deleted at this time."
                            case successMessage = "Your payment method has been deleted."

                            var prefix: String? {
                                "paymentMethodRemoveCard"
                            }
                        }
                    }
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

        enum LocalizedStrings {

            enum PaymentMethod: String, LocalizedStringConvertible {
                case confirmDelete = "Are you sure you want to delete this payment method?"
                case expirationAbbreviation = "Exp"
                case navigationTitle = "Manage Payments"
                case sectionTitle = "Payment Methods"

                var prefix: String? {
                    "paymentMethod"
                }

                enum Add: String, LocalizedStringConvertible {
                    case action = "Add payment method"

                    var prefix: String? {
                        "paymentMethodAdd"
                    }

                    enum Card: String, LocalizedStringConvertible {
                        case failureMessage = "Your payment method could not be added at this time."
                        case successMessage = "Your payment method has been added."

                        var prefix: String? {
                            "paymentMethodAddCard"
                        }
                    }
                }

                enum RemoveCard: String, LocalizedStringConvertible {
                    case failureMessage = "Your payment method could not be deleted at this time."
                    case successMessage = "Your payment method has been deleted."

                    var prefix: String? {
                        "paymentMethodRemoveCard"
                    }
                }
            }
        }
        """)
    }
}
