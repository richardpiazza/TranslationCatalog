extension StringCatalog {
    struct Version: Hashable, Sendable {
        let rawValue: StringLiteralType
        
        static let v1_0: Self = "1.0"
        static let v1_1: Self = "1.1"
    }
}

extension StringCatalog.Version: ExpressibleByStringLiteral {
    init(stringLiteral rawValue: String) {
        self.rawValue = rawValue
    }
}

extension StringCatalog.Version: CaseIterable {
    static let allCases: [StringCatalog.Version] = [
        .v1_0,
        .v1_1,
    ]
}

extension StringCatalog.Version: Codable {
    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        rawValue = try container.decode(String.self)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

extension StringCatalog.Version: Identifiable {
    var id: String { rawValue }
}
