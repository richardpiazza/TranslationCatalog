extension StringCatalog {
    struct Substitution: Codable {
        let argNum: Int
        let formatSpecifier: Unit
        let variations: Variations?
    }
}
