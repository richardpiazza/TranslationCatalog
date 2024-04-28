extension StringCatalog {
    struct Expression: Codable {
        let comment: String?
        let extractionState: ExtractionState?
        let localizations: [Language: Localization]?
    }
}
