extension StringCatalog {
    struct Pluralization: Hashable, Sendable {
        let rawValue: StringLiteralType
        
        static let few: Self = "few"
        static let many: Self = "many"
        static let one: Self = "one"
        static let other: Self = "other"
        static let two: Self = "two"
        static let zero: Self = "zero"
    }
}

extension StringCatalog.Pluralization: ExpressibleByStringLiteral {
    init(stringLiteral rawValue: String) {
        self.rawValue = rawValue
    }
}

extension StringCatalog.Pluralization: CaseIterable {
    static let allCases: [StringCatalog.Pluralization] = [
        .zero,
        .one,
        .two,
        .few,
        .many,
        .other
    ]
}

extension StringCatalog.Pluralization: Codable {
    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        rawValue = try container.decode(String.self)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

extension StringCatalog.Pluralization: Identifiable {
    var id: String { rawValue }
}
