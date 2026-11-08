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
