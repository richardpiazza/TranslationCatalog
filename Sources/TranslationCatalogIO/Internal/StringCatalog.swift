import Foundation

struct StringCatalog: Hashable, Sendable {
    let sourceLanguage: Locale.LanguageCode
    let strings: [String: Expression]
    let version: Version
}

extension StringCatalog: Codable {}
