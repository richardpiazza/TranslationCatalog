import Foundation

extension StringCatalog {
    struct Substitution: Hashable, Sendable {
        let argNum: Int
        let formatSpecifier: String
        let variations: Variation
    }
}

extension StringCatalog.Substitution: Codable {}
