import Foundation
import LocaleSupport
import TranslationCatalog

public extension SQLiteCatalog {

    enum Error: Swift.Error {
        case invalidPrimaryKey(Int)
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
