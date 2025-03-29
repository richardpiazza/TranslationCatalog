import Foundation

/// A grouping of `Expression`s used for a common purpose, such as an application or service.
public struct Project: Codable, Hashable, Identifiable, Sendable {
    /// Identifier that universally identifies this `Project`
    public let id: UUID
    /// A custom description
    public let name: String
    /// The `Expression`s associated with this `Project`
    public let expressions: [Expression]
    
    public init(
        id: UUID = .zero,
        name: String = "",
        expressions: [Expression] = []
    ) {
        self.id = id
        self.name = name
        self.expressions = expressions
    }
}

public extension Project {
    @available(*, deprecated, renamed: "id")
    var uuid: UUID { id }
    
    @available(*, deprecated, renamed: "init(id:name:expressions:)")
    init(
        uuid: UUID,
        name: String = "",
        expressions: [Expression] = []
    ) {
        self.id = uuid
        self.name = name
        self.expressions = expressions
    }
}
