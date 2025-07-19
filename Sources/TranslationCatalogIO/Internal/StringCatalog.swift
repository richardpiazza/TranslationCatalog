struct StringCatalog: Hashable, Sendable {
    let sourceLanguage: Language
    let strings: [String: Expression]
    let version: Version
}

extension StringCatalog: Codable {}
