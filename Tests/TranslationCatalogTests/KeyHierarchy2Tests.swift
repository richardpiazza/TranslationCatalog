import LocaleSupport
@testable import TranslationCatalog
@testable import TranslationCatalogIO
import XCTest

final class KeyHierarchy2Tests: XCTestCase {

    let keys: [LocalizationKey] = [
        LocalizationKey(
            key: "PAYMENT_METHOD_ADD_ACTION",
            defaultValue: "Add payment method"
        ),
        LocalizationKey(
            key: "PAYMENT_METHOD_ADD_CARD_FAILURE_MESSAGE",
            defaultValue: "Your payment method could not be added at this time."
        ),
        LocalizationKey(
            key: "PAYMENT_METHOD_ADD_CARD_SUCCESS_MESSAGE",
            defaultValue: "Your payment method has been added."
        ),
        LocalizationKey(
            key: "PAYMENT_METHOD_CONFIRM_DELETE",
            defaultValue: "Are you sure you want to delete this payment method?"
        ),
        LocalizationKey(
            key: "PAYMENT_METHOD_EXPIRATION_ABBREVIATION",
            defaultValue: "Exp"
        ),
        LocalizationKey(
            key: "PAYMENT_METHOD_NAVIGATION_TITLE",
            defaultValue: "Manage Payments"
        ),
        LocalizationKey(
            key: "PAYMENT_METHOD_REMOVE_CARD_FAILURE_MESSAGE",
            defaultValue: "Your payment method could not be deleted at this time."
        ),
        LocalizationKey(
            key: "PAYMENT_METHOD_REMOVE_CARD_SUCCESS_MESSAGE",
            defaultValue: "Your payment method has been deleted."
        ),
        LocalizationKey(
            key: "PAYMENT_METHOD_SECTION_TITLE",
            defaultValue: "Payment Methods"
        ),
    ]

    var hierarchy: KeyHierarchy!

    override func setUpWithError() throws {
        try super.setUpWithError()
        hierarchy = try KeyHierarchy.make(with: keys)
    }

    func testHierarchyGeneration() {
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

    func testNodeAtPath() {
        var node = hierarchy.node(at: [["UNKNOWN"]])
        XCTAssertNil(node)
        node = hierarchy.node(at: [["PAYMENT"], ["METHOD"], ["EXPIRATION"]])
        XCTAssertNotNil(node)
        node = hierarchy.node(at: [["PAYMENT"], ["METHOD"], ["ADD"], ["CARD"], ["FAILURE"]])
        XCTAssertNotNil(node)
    }

    func testRemoveNodeAtPath() {
        let node = hierarchy.removeNode(at: [["PAYMENT"], ["METHOD"], ["CONFIRM"]])
        XCTAssertNotNil(node)
    }

    func testOrphanNodes() {
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

    func testPhantomNodes() {
        let nodes = hierarchy.phantomNodes()
        XCTAssertEqual(nodes.count, 2)
        XCTAssertEqual(nodes, [
            [["PAYMENT"]],
            [["PAYMENT"], ["METHOD"], ["REMOVE"]],
        ])
    }

    func testLocalizedStringConvertible() {
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
