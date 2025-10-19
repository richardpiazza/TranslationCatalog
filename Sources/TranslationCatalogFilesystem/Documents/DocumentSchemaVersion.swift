enum DocumentSchemaVersion: Int {
    case v1 = 1
    /// Expression Default Value
    case v2 = 2
    /// Translation State
    case v3 = 3

    static var current: Self { .v3 }
}

extension DocumentSchemaVersion: Comparable {
    static func < (lhs: DocumentSchemaVersion, rhs: DocumentSchemaVersion) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
