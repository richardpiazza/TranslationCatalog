import Foundation
import Testing
@testable @preconcurrency import TranslationCatalog
#if canImport(CoreData)
@testable import TranslationCatalogCoreData
#endif
@testable import TranslationCatalogFilesystem
@testable import TranslationCatalogSQLite

final class CatalogQueryTests {

    private static var container: TestContainer {
        get throws {
            try TestContainer(prepared: true)
        }
    }

    deinit {
        do {
            try Self.container.recycle()
        } catch {}
    }

    // MARK: Projects

    /// Verify an expected number of existing `Project`.
    @Test(arguments: try Self.container.catalogs)
    func queryProjects(catalog: any Catalog) throws {
        let projects = try catalog.projects()
        #expect(projects.count == 3)
    }

    /// Verify that existing `Project`s can be found loosely matching the `name`.
    @Test(arguments: try Self.container.catalogs)
    func queryProjectsNamed(catalog: any Catalog) throws {
        var projects = try catalog.projects(matching: GenericProjectQuery.named("shop"))
        #expect(projects.count == 2)
        projects = try catalog.projects(matching: GenericProjectQuery.named("class"))
        #expect(projects.count == 2)
    }

    /// Verify that a list of `Project`s can be found associated to an `Expression.ID`.
    @Test(arguments: try Self.container.catalogs)
    func queryProjectsExpressionID(catalog: any Catalog) throws {
        var projects = try catalog.projects(matching: GenericProjectQuery.expressionId(.expression2))
        #expect(projects.count == 2)
        projects = try catalog.projects(matching: GenericProjectQuery.expressionId(.expression5))
        #expect(projects.count == 1)
    }

    /// Verify that an existing `Project` can be found using its `id`.
    @Test(arguments: try Self.container.catalogs)
    func queryProjectsId(catalog: any Catalog) throws {
        let project = try catalog.project(.project2)
        #expect(project.name == "Shopclass")
    }

    /// Verify that an existing `Project` can be found using its exact `name`.
    @Test(arguments: try Self.container.catalogs)
    func queryProjectNamed(catalog: any Catalog) throws {
        #expect(throws: CatalogError.self) {
            try catalog.project(matching: GenericProjectQuery.named("class"))
        }
        let project = try catalog.project(matching: GenericProjectQuery.named("Shopclass"))
        #expect(project.id == .project2)
    }

    // MARK: Expressions

    @Test(arguments: try Self.container.catalogs)
    func queryExpressions(catalog: any Catalog) throws {
        let expressions = try catalog.expressions()
        #expect(expressions.count == 5)
    }

    @Test(arguments: try Self.container.catalogs)
    func queryExpressionsProjectId(catalog: any Catalog) throws {
        let expressions = try catalog.expressions(matching: GenericExpressionQuery.projectId(.project3))
        #expect(expressions.count == 2)
    }

    @Test(arguments: try Self.container.catalogs)
    func queryExpressionsKeyed(catalog: any Catalog) throws {
        let expressions = try catalog.expressions(matching: GenericExpressionQuery.key("button"))
        #expect(expressions.count == 2)
    }

    @Test(arguments: try Self.container.catalogs)
    func queryExpressionsValued(catalog: any Catalog) throws {
        let expressions = try catalog.expressions(matching: GenericExpressionQuery.value("ull"))
        #expect(expressions.count == 2)
    }

    @Test(arguments: try Self.container.catalogs)
    func queryExpressionsHaving(catalog: any Catalog) throws {
        var expressions = try catalog.expressions(matching: GenericExpressionQuery.translationsHaving(.french, nil, nil))
        #expect(expressions.count == 3)
        expressions = try catalog.expressions(matching: GenericExpressionQuery.translationsHaving(.french, nil, .canada))
        #expect(expressions.count == 2)
    }

    @Test(arguments: try Self.container.catalogs)
    func queryExpressionsHavingOnly(catalog: any Catalog) throws {
        let expressions = try catalog.expressions(matching: GenericExpressionQuery.translationsHavingOnly(.french))
        #expect(expressions.count == 3)
    }

    @Test(arguments: try Self.container.catalogs)
    func queryExpressionsHavingState(catalog: any Catalog) throws {
        let expressions = try catalog.expressions(matching: GenericExpressionQuery.translationsHavingState(.needsReview))
        #expect(expressions.count == 4)
    }

    @Test(arguments: try Self.container.catalogs)
    func queryExpressionsWithoutAllLocales(catalog: any Catalog) throws {
        let locales = [
            "en",
            "en_GB",
            "es",
            "fr",
            "fr_CA",
            "pt_BR",
            "zh-Hans",
        ].map { Locale(identifier: $0) }
        let expressions = try catalog.expressions(matching: GenericExpressionQuery.withoutAllLocales(Set(locales)))
        #expect(expressions.count == 4)
    }

    @Test(arguments: try Self.container.catalogs)
    func queryExpressionId(catalog: any Catalog) throws {
        let expression = try catalog.expression(.expression4)
        #expect(expression.defaultValue == "Fully Qualified Domain Name")
    }

    @Test(arguments: try Self.container.catalogs)
    func queryExpressionKey(catalog: any Catalog) throws {
        let expression = try catalog.expression(matching: GenericExpressionQuery.key("GIT_FQDN"))
        #expect(expression.id == .expression4)
    }

    // MARK: Translation

    @Test(arguments: try Self.container.catalogs)
    func queryTranslations(catalog: any Catalog) throws {
        let translations = try catalog.translations()
        #expect(translations.count == 16)
    }

    @Test(arguments: try Self.container.catalogs)
    func queryTranslationsExpressionId(catalog: any Catalog) throws {
        let translations = try catalog.translations(matching: GenericTranslationQuery.expressionId(.expression3))
        #expect(translations.count == 3)
    }

    @Test(arguments: try Self.container.catalogs)
    func queryTranslationsHaving(catalog: any Catalog) throws {
        var translations = try catalog.translations(matching: GenericTranslationQuery.having(.expression5, .french, nil, nil))
        #expect(translations.count == 2)
        translations = try catalog.translations(matching: GenericTranslationQuery.having(.expression5, .french, nil, .canada))
        #expect(translations.count == 1)
    }

    @Test(arguments: try Self.container.catalogs)
    func queryTranslationsHavingOnly(catalog: any Catalog) throws {
        let translations = try catalog.translations(matching: GenericTranslationQuery.havingOnly(.expression5, .french))
        #expect(translations.count == 1)
    }

    @Test(arguments: try Self.container.catalogs)
    func queryTranslationId(catalog: any Catalog) throws {
        let translation = try catalog.translation(.translation8)
        #expect(translation.locale.identifier == "zh-Hans")
    }

    // MARK: Metadata

    @Test(arguments: try Self.container.catalogs)
    func queryLocales(catalog: any Catalog) throws {
        let localeIdentifiers = try catalog.locales().map(\.identifier)
        #expect(localeIdentifiers.count == 7)
        #expect(localeIdentifiers.sorted() == [
            "en",
            "en_GB",
            "es",
            "fr",
            "fr_CA",
            "pt_BR",
            "zh-Hans",
        ])
    }

    // MARK: SQLite Only

    @Test(arguments: try Self.container.catalogs)
    func queryProjectsHierarchy(catalog: any Catalog) throws {
        guard let sqliteCatalog = catalog as? SQLiteCatalog else {
            #if swift(>=6.3)
            try Test.cancel("Only valid with SQLiteCatalog")
            #else
            return
            #endif
        }

        let projects = try sqliteCatalog.projects(matching: SQLiteCatalog.ProjectQuery.hierarchy)
        #expect(projects.count == 3)
        let p1 = try #require(projects.first(where: { $0.id == .project1 }))
        let p2 = try #require(projects.first(where: { $0.id == .project2 }))
        let p3 = try #require(projects.first(where: { $0.id == .project3 }))
        #expect(p1.expressions.count == 2)
        #expect(p2.expressions.count == 3)
        #expect(p3.expressions.count == 2)
        #expect(p1.expressions[0] == p3.expressions[0])
    }

    @Test(arguments: try Self.container.catalogs)
    func queryProjectPrimaryKey(catalog: any Catalog) throws {
        guard let sqliteCatalog = catalog as? SQLiteCatalog else {
            #if swift(>=6.3)
            try Test.cancel("Only valid with SQLiteCatalog")
            #else
            return
            #endif
        }

        let project = try sqliteCatalog.project(matching: SQLiteCatalog.ProjectQuery.primaryKey(3))
        #expect(project.name == Project.project3.name)
    }

    @Test(arguments: try Self.container.catalogs)
    func queryExpressionsHierarchy(catalog: any Catalog) throws {
        guard let sqliteCatalog = catalog as? SQLiteCatalog else {
            #if swift(>=6.3)
            try Test.cancel("Only valid with SQLiteCatalog")
            #else
            return
            #endif
        }

        let expressions = try sqliteCatalog.expressions(matching: SQLiteCatalog.ExpressionQuery.hierarchy)
        #expect(expressions.count == 5)
        let e1 = try #require(expressions.first(where: { $0.id == .expression1 }))
        let e2 = try #require(expressions.first(where: { $0.id == .expression2 }))
        let e3 = try #require(expressions.first(where: { $0.id == .expression3 }))
        let e4 = try #require(expressions.first(where: { $0.id == .expression4 }))
        let e5 = try #require(expressions.first(where: { $0.id == .expression5 }))
        #expect(e1.translations.count == 6)
        #expect(e2.translations.count == 3)
        #expect(e3.translations.count == 3)
        #expect(e4.translations.count == 1)
        #expect(e5.translations.count == 3)
    }

    @Test(arguments: try Self.container.catalogs)
    func queryExpressionPrimaryKey(catalog: any Catalog) throws {
        guard let sqliteCatalog = catalog as? SQLiteCatalog else {
            #if swift(>=6.3)
            try Test.cancel("Only valid with SQLiteCatalog")
            #else
            return
            #endif
        }

        let expression = try sqliteCatalog.expression(matching: SQLiteCatalog.ExpressionQuery.primaryKey(2))
        #expect(expression.key == "BUTTON_DELETE")
    }

    @Test(arguments: try Self.container.catalogs)
    func queryTranslationPrimaryKey(catalog: any Catalog) throws {
        guard let sqliteCatalog = catalog as? SQLiteCatalog else {
            #if swift(>=6.3)
            try Test.cancel("Only valid with SQLiteCatalog")
            #else
            return
            #endif
        }

        let translation = try sqliteCatalog.translation(matching: SQLiteCatalog.TranslationQuery.primaryKey(12))
        #expect(translation.region == .brazil)
    }
}
