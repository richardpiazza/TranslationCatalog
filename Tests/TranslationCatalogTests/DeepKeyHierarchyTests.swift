import LocaleSupport
import Testing
@testable import TranslationCatalog
@testable import TranslationCatalogIO

struct DeepKeyHierarchyTests {

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

    var hierarchy: KeyHierarchy

    init() throws {
        hierarchy = try KeyHierarchy.make(with: keys)
    }

    @Test func hierarchyGeneration() {
        #expect(hierarchy.contents.isEmpty)
        #expect(hierarchy.nodes.count == 1)
        #expect(hierarchy.nodes.map(\.id) == [
            ["PAYMENT"],
        ])
        #expect(!hierarchy.isOrphan)
        #expect(hierarchy.containsOrphans)
        #expect(hierarchy.isPhantom)
        #expect(hierarchy.containsPhantoms)
    }

    @Test func nodeAtPath() {
        var node = hierarchy.node(at: [["UNKNOWN"]])
        #expect(node == nil)
        node = hierarchy.node(at: [["PAYMENT"], ["METHOD"], ["EXPIRATION"]])
        #expect(node != nil)
        node = hierarchy.node(at: [["PAYMENT"], ["METHOD"], ["ADD"], ["CARD"], ["FAILURE"]])
        #expect(node != nil)
    }

    @Test func removeNodeAtPath() {
        var hierarchy = hierarchy
        let node = hierarchy.removeNode(at: [["PAYMENT"], ["METHOD"], ["CONFIRM"]])
        #expect(node != nil)
    }

    @Test func orphanNodes() {
        let nodes = hierarchy.orphanNodes()
        #expect(nodes.count == 8)
        #expect(nodes == [
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

    @Test func phantomNodes() {
        let nodes = hierarchy.phantomNodes()
        #expect(nodes.count == 2)
        #expect(nodes == [
            [["PAYMENT"]],
            [["PAYMENT"], ["METHOD"], ["REMOVE"]],
        ])
    }

    @Test func localizedStringConvertible() {
        let syntax = hierarchy.syntaxTree()
        #expect(syntax == """
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

    @Test func phantomOnlyCompression() throws {
        let syntax = try hierarchy
            .compressed(mergeOrphans: false)
            .syntaxTree()
        #expect(syntax == """
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

    @Test func orphanOnlyCompression() throws {
        let syntax = try hierarchy
            .compressed(mergePhantoms: false)
            .syntaxTree()
        #expect(syntax == """
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

    @Test func compression() throws {
        let syntax = try hierarchy
            .compressed()
            .syntaxTree()
        #expect(syntax == """
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
