import Foundation

extension StringCatalog {
    struct Expression: Hashable, Sendable {
        let comment: String?
        let extractionState: ExtractionState?
        let localizations: [Locale: Localization]?
        let shouldTranslate: Bool?
    }
}

extension StringCatalog.Expression: Codable {
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        comment = try container.decodeIfPresent(String.self, forKey: .comment)
        extractionState = try container.decodeIfPresent(StringCatalog.ExtractionState.self, forKey: .extractionState)
        if let dictionary = try container.decodeIfPresent([String: StringCatalog.Localization].self, forKey: .localizations) {
            var localizations: [Locale: StringCatalog.Localization] = [:]
            for (key, value) in dictionary {
                let locale = Locale(identifier: key)
                localizations[locale] = value
            }
            self.localizations = localizations
        } else {
            localizations = nil
        }
        shouldTranslate = try container.decodeIfPresent(Bool.self, forKey: .shouldTranslate)
    }
}
