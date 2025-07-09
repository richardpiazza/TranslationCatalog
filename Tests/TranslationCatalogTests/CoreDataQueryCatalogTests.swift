#if canImport(CoreData)
import LocaleSupport
@testable import TranslationCatalog
@testable import TranslationCatalogCoreData
import XCTest

final class CoreDataQueryCatalogTests: QueryCatalogTestCase {
    override func setUpWithError() throws {
        catalog = try CoreDataCatalog()
        try super.setUpWithError()
    }
}
#endif
