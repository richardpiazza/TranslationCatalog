import Foundation

/// A fragment of an `Expression` that is intended to be replaced by another value.
public enum Substitution: Codable, Hashable, Sendable {
    case double(position: UInt, argument: String?)
    case int(position: UInt, argument: String?)
    case string(position: UInt, argument: String?)
    case unsignedInt(position: UInt, argument: String?)
    
    public var position: UInt {
        switch self {
        case .double(let position, _), .int(let position, _), .string(let position, _), .unsignedInt(let position, _):
            position
        }
    }
    
    public var argument: String? {
        switch self {
        case .double(_, let argument), .int(_, let argument), .string(_, let argument), .unsignedInt(_, let argument):
            argument
        }
    }
    
    func formatSpecifier(for interface: Interface) -> String {
        var format = "%\(position)"
        
        if let argument, interface == .darwin {
            format.append("$(\(argument))")
        }
        
        switch self {
        case .double:
            format.append("lf")
        case .int:
            format.append("lld")
        case .string:
            format.append(interface == .darwin ? "@" : "s")
        case .unsignedInt:
            format.append("llu")
        }
        
        return format
    }
}
