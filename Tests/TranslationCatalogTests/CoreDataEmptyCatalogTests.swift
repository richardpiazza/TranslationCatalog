#if canImport(CoreData)
import LocaleSupport
@testable import TranslationCatalog
@testable import TranslationCatalogCoreData
import XCTest

final class CoreDataEmptyCatalogTests: EmptyCatalogTestCase {
    override func setUpWithError() throws {
        catalog = try CoreDataCatalog()
        try super.setUpWithError()
    }
}
#endif
