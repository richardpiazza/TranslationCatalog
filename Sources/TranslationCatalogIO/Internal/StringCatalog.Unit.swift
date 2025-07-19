extension StringCatalog {
    struct Unit: Hashable, Sendable {
        let state: UnitState
        let value: String
    }
}

extension StringCatalog.Unit: Codable {}
