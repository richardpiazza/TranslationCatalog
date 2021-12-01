import Foundation

/// A grouping of `Expression`s used for a common purpose, such as an application or service.
public struct Project {
    /// Identifier that universally identifies this `Project`
    public var uuid: UUID
    /// A custom description
    public var name: String
    /// The `Expression`s associated with this `Project`
    public var expressions: [Expression]
    
    public init(uuid: UUID = .zero, name: String = "", expressions: [Expression] = []) {
        self.uuid = uuid
        self.name = name
        self.expressions = expressions
    }
}

extension Project: Codable {}
extension Project: Equatable {}
extension Project: Identifiable {
    public var id: UUID { uuid }
}
