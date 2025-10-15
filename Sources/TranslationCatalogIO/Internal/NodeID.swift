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
public typealias KeyNodeID = [String]

struct NodeIDSortComparator: SortComparator {
    var order: SortOrder = .forward

    func compare(_ lhs: KeyNodeID, _ rhs: KeyNodeID) -> ComparisonResult {
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
        let comparison = left.removeFirst().compare(right.removeFirst())
        if comparison != .orderedSame {
            return comparison
        }

        return compare(left, right)
    }
}
