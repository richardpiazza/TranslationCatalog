extension StringCatalog {
    struct Pluralization: ExpressibleByStringLiteral, Hashable, Identifiable, Codable, CaseIterable {
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
        
        static let few: Self = "few"
        static let many: Self = "many"
        static let one: Self = "one"
        static let other: Self = "other"
        static let two: Self = "two"
        static let zero: Self = "zero"
        
        static let allCases: [StringCatalog.Pluralization] = [
            .zero,
            .one,
            .two,
            .few,
            .many,
            .other
        ]
    }
}
