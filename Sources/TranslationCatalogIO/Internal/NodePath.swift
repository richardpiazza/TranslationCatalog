import Foundation

/// Represents a path of multi-part strings.
///
/// The human readable path `Strings > EnumName > SubType > Category` would be represented by:
/// ```swift
/// [
///   ["Strings"],
///   ["Enum", "Name"],
///   ["Sub", "Type"],
///   ["Category"]
/// ]
/// ```
public typealias KeyNodePath = [KeyNodeID]

struct NodePathSortComparator: SortComparator {

    var order: SortOrder = .forward
    let elementSort = NodeIDSortComparator()

    func compare(_ lhs: KeyNodePath, _ rhs: KeyNodePath) -> ComparisonResult {
        switch (lhs.isEmpty, rhs.isEmpty) {
        case (true, true):
            return .orderedSame
        case (true, false):
            return order == .forward ? .orderedAscending : .orderedDescending
        case (false, true):
            return order == .forward ? .orderedDescending : .orderedAscending
        default:
            break
        }

        var left = lhs
        var right = rhs

        let comparison = elementSort.compare(left.removeFirst(), right.removeFirst())
        if comparison != .orderedSame {
            return comparison
        }

        return compare(left, right)
    }
}
