import Foundation

/// Represents a multi-part identifier.
///
/// A 'node' is represented by a series of strings (words).
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
