import LocaleSupport

struct StringCatalog: Codable {
    let version: String
    let sourceLanguage: Language
    let strings: [String: Expression]
}
