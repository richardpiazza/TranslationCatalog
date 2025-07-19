import Foundation

public extension UUID {
    /// A uuid with all zeros. Used as a default (invalid) reference.
    static let zero: UUID = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
}
