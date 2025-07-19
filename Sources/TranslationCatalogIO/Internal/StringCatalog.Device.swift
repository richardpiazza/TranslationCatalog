extension StringCatalog {
    struct Device: Hashable, Sendable {
        let rawValue: StringLiteralType
        
        static let appleTV: Self = "appletv"
        static let appleVision: Self = "applevision"
        static let appleWatch: Self = "applewatch"
        static let iPad: Self = "ipad"
        static let iPhone: Self = "iphone"
        static let iPod: Self = "ipod"
        static let mac: Self = "mac"
        static let other: Self = "other"
    }
}

extension StringCatalog.Device: ExpressibleByStringLiteral {
    init(stringLiteral rawValue: String) {
        self.rawValue = rawValue
    }
}

extension StringCatalog.Device: CaseIterable {
    static let allCases: [StringCatalog.Device] = [
        .iPhone,
        .iPod,
        .iPad,
        .appleWatch,
        .appleTV,
        .appleVision,
        .mac,
        .other
    ]
}

extension StringCatalog.Device: Codable {
    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        rawValue = try container.decode(String.self)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

extension StringCatalog.Device: Identifiable {
    var id: String { rawValue }
}
