@testable import TranslationCatalogIO
import XCTest

final class NodeSortTests: XCTestCase {

    typealias Node = [[String]]

    let comparator = NodePathSortComparator()

    func testSorting() throws {
        let nodes: [Node] = [
            [["Account"], ["New"]],
            [["Account"], ["Add"]],
            [["Account"], ["Add"], ["Patient"]],
            [["Account"], ["Holder"], ["Relationship"]],
            [["Billing"], ["Status"]],
            [["Billing"]],
        ]
        let sorted = nodes.sorted(using: comparator)
        XCTAssertEqual(sorted, [
            [["Account"], ["Add"]],
            [["Account"], ["Add"], ["Patient"]],
            [["Account"], ["Holder"], ["Relationship"]],
            [["Account"], ["New"]],
            [["Billing"]],
            [["Billing"], ["Status"]],
        ])
    }
}
