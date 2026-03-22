import Foundation
import TranslationCatalog

public extension SQLiteCatalog {

    enum Error: Swift.Error {
        case invalidPrimaryKey(Int)
        @available(*, deprecated, message: "Use CatalogError.badQuery()")
        case invalidStringValue(String)
    }

    enum ProjectQuery: CatalogQuery {
        case hierarchy
        case primaryKey(Int)
    }

    enum ExpressionQuery: CatalogQuery {
        case hierarchy
        case primaryKey(Int)
    }

    enum TranslationQuery: CatalogQuery {
        case primaryKey(Int)
    }
}
