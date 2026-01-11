extension StringCatalog {
    struct Localization: Hashable, Sendable {
        let stringUnit: Unit?
        let substitutions: [String: Substitution]?
        let variations: Variation?
    }
}

extension StringCatalog.Localization: Codable {
//    enum CodingKeys: String, CodingKey {
//        case stringUnit
//        case variations
//    }
//    
//    init(from decoder: any Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        if container.contains(.stringUnit) {
//            let unit = try container.decode(StringCatalog.Unit.self, forKey: .stringUnit)
//            self = .unit(unit: unit)
//        } else if container.contains(.variations) {
//            let variation = try container.decode(StringCatalog.Variation.self, forKey: .variations)
//            self = .variation(variation: variation)
//        } else {
//            let context = DecodingError.Context(
//                codingPath: [CodingKeys.stringUnit, CodingKeys.variations],
//                debugDescription: "Could not decode `Localization` from keys: \(container.allKeys)"
//            )
//            throw DecodingError.dataCorrupted(context)
//        }
//    }
//    
//    func encode(to encoder: any Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        switch self {
//        case .unit(let unit):
//            try container.encode(unit, forKey: .stringUnit)
//        case .variation(let variation):
//            try container.encode(variation, forKey: .variations)
//        }
//    }
}
