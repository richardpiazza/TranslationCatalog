import Foundation
import Testing
@testable import TranslationCatalogIO

struct NodeSortTests {

    typealias Node = [[String]]

    let comparator = NodePathSortComparator()

    @Test func sorting() {
        let nodes: [Node] = [
            [["Account"], ["New"]],
            [["Account"], ["Add"]],
            [["Account"], ["Add"], ["Patient"]],
            [["Account"], ["Holder"], ["Relationship"]],
            [["Billing"], ["Status"]],
            [["Billing"]],
        ]
        let sorted = nodes.sorted(using: comparator)
        #expect(sorted == [
            [["Account"], ["Add"]],
            [["Account"], ["Add"], ["Patient"]],
            [["Account"], ["Holder"], ["Relationship"]],
            [["Account"], ["New"]],
            [["Billing"]],
            [["Billing"], ["Status"]],
        ])
    }
}
