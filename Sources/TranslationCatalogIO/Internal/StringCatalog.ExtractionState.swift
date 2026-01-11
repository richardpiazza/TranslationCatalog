extension StringCatalog {
    struct ExtractionState: Hashable, Sendable {
        let rawValue: StringLiteralType
        
        static let automatic: Self = "automatic"
        static let manual: Self = "manual"
        static let migrated: Self = "migrated"
    }
}

extension StringCatalog.ExtractionState: ExpressibleByStringLiteral {
    init(stringLiteral rawValue: String) {
        self.rawValue = rawValue
    }
}

extension StringCatalog.ExtractionState: CaseIterable {
    static let allCases: [StringCatalog.ExtractionState] = [
        .automatic,
        .manual,
        .migrated
    ]
}

extension StringCatalog.ExtractionState: Codable {
    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        rawValue = try container.decode(String.self)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

extension StringCatalog.ExtractionState: Identifiable {
    var id: String { rawValue }
}
