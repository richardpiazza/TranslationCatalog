extension StringCatalog {
    struct Variations: Codable {
        let device: [Device: Variation]?
        let plural: [Pluralization: Variation]?
    }
}
