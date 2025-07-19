extension StringCatalog {
    enum Variation: Hashable, Sendable {
        case device(variations: [Device: Localization])
        case plural(variations: [Pluralization: Localization])
    }
}

extension StringCatalog.Variation: Codable {
    enum CodingKeys: String, CodingKey {
        case device
        case plural
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if container.contains(.device) {
            let dictionary = try container.decode([String: StringCatalog.Localization].self, forKey: .device)
            var variations: [StringCatalog.Device: StringCatalog.Localization] = [:]
            for (key, value) in dictionary {
                variations[StringCatalog.Device(stringLiteral: key)] = value
            }
            self = .device(variations: variations)
        } else if container.contains(.plural) {
            let dictionary = try container.decode([String: StringCatalog.Localization].self, forKey: .plural)
            var variations: [StringCatalog.Pluralization: StringCatalog.Localization] = [:]
            for (key, value) in dictionary {
                variations[StringCatalog.Pluralization(stringLiteral: key)] = value
            }
            self = .plural(variations: variations)
        } else {
            let context = DecodingError.Context(
                codingPath: [CodingKeys.device, CodingKeys.plural],
                debugDescription: "Could not decode `Variation` from keys: \(container.allKeys)"
            )
            throw DecodingError.dataCorrupted(context)
        }
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .device(let variations):
            try container.encode(variations, forKey: .device)
        case .plural(let variations):
            try container.encode(variations, forKey: .plural)
        }
    }
}
