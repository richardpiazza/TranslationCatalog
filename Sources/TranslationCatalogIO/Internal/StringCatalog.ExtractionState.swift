extension StringCatalog {
    struct ExtractionState: ExpressibleByStringLiteral, Hashable, Identifiable, Codable, CaseIterable {
        let rawValue: StringLiteralType
        
        var id: String { rawValue }
        
        init(stringLiteral rawValue: String) {
            self.rawValue = rawValue
        }
        
        init(from decoder: any Decoder) throws {
            let container = try decoder.singleValueContainer()
            rawValue = try container.decode(String.self)
        }
        
        func encode(to encoder: any Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(rawValue)
        }
        
        static let automatic: Self = "automatic"
        static let manual: Self = "manual"
        static let migrated: Self = "migrated"
        
        static let allCases: [StringCatalog.ExtractionState] = [
            .automatic,
            .manual,
            .migrated
        ]
    }
}
