extension StringCatalog {
    struct UnitState: ExpressibleByStringLiteral, Hashable, Identifiable, Codable, CaseIterable {
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
        
        static let needsReview: Self = "needs_review"
        static let translated: Self = "translated"
        
        static let allCases: [StringCatalog.UnitState] = [
            .needsReview,
            .translated
        ]
    }
}
