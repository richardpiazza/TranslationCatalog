extension StringCatalog {
    struct UnitState: Hashable, Sendable {
        let rawValue: StringLiteralType
        
        static let needsReview: Self = "needs_review"
        static let new: Self = "new"
        static let translated: Self = "translated"
    }
}

extension StringCatalog.UnitState: ExpressibleByStringLiteral {
    init(stringLiteral rawValue: String) {
        self.rawValue = rawValue
    }
}

extension StringCatalog.UnitState: CaseIterable {
    static let allCases: [StringCatalog.UnitState] = [
        .needsReview,
        .translated
    ]
}

extension StringCatalog.UnitState: Codable {
    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        rawValue = try container.decode(String.self)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

extension StringCatalog.UnitState: Identifiable {
    var id: String { rawValue }
}
