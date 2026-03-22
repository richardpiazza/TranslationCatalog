import Foundation
import Testing
@testable @preconcurrency import TranslationCatalog
#if canImport(CoreData)
@testable import TranslationCatalogCoreData
#endif
@testable import TranslationCatalogFilesystem
@testable import TranslationCatalogSQLite

final class CatalogDeleteTests {

    private static var container: TestContainer {
        get throws {
            try TestContainer()
        }
    }

    deinit {
        do {
            try Self.container.recycle()
        } catch {}
    }

    /// Verify that a `Project` can be removed from the catalog.
    @Test(arguments: try Self.container.catalogs)
    func deleteProject(catalog: any Catalog) throws {
        let projectId = try #require(UUID(uuidString: "06937A10-2E46-4FFD-A2E7-60A3F03ED007"))
        let project = Project(
            id: projectId,
            name: "Example Project"
        )

        try catalog.createProject(project)

        var projects = try catalog.projects()
        #expect(projects.count == 1)

        try catalog.deleteProject(projectId)

        projects = try catalog.projects()
        #expect(projects.count == 0)
    }

    /// Verify that a `Expression` can be removed from the catalog.
    @Test(arguments: try Self.container.catalogs)
    func deleteExpression(catalog: any Catalog) throws {
        let expressionId = try #require(UUID(uuidString: "0503A67E-EAC5-4612-A91A-559477283C56"))
        let expression = Expression(
            id: expressionId,
            key: "TEST_EXPRESSION",
            value: "Test Expression",
            languageCode: .english
        )

        try catalog.createExpression(expression)

        var expressions = try catalog.expressions()
        #expect(expressions.count == 1)

        try catalog.deleteExpression(expressionId)

        expressions = try catalog.expressions()
        #expect(expressions.count == 0)
    }

    /// Verify that a `Translation` can be removed from the catalog.
    @Test(arguments: try Self.container.catalogs)
    func deleteTranslation(catalog: any Catalog) throws {
        let expressionId = try #require(UUID(uuidString: "F590AA58-626D-4EAB-AEDA-21F047B9BA42"))
        let expression = Expression(
            id: expressionId,
            key: "TRACK_TITLE",
            value: "Track Title",
            languageCode: .english
        )

        let translationId = try #require(UUID(uuidString: "A93E74CD-58F2-4D00-BA6B-F722FFCCCFBF"))
        let translation = TranslationCatalog.Translation(
            id: translationId,
            expressionId: expressionId,
            value: "Overture to Egmont, Op. 84",
            language: .english,
            region: .unitedStates,
            state: .translated
        )

        try catalog.createExpression(expression)
        try catalog.createTranslation(translation)

        var expressions = try catalog.expressions()
        #expect(expressions.count == 1)

        var translations = try catalog.translations()
        #expect(translations.count == 1)

        try catalog.deleteTranslation(translationId)

        expressions = try catalog.expressions()
        #expect(expressions.count == 1)

        translations = try catalog.translations()
        #expect(translations.count == 0)
    }

    /// Verify that a `Expression` can be removed from the catalog, and it's related
    /// `Translation` entities are also removed.
    @Test(arguments: try Self.container.catalogs)
    func deleteExpression_CascadeTranslation(catalog: any Catalog) throws {
        let expressionId = try #require(UUID(uuidString: "F590AA58-626D-4EAB-AEDA-21F047B9BA42"))
        let expression = Expression(
            id: expressionId,
            key: "TRACK_TITLE",
            value: "Track Title",
            languageCode: .english
        )

        let translationId = try #require(UUID(uuidString: "A93E74CD-58F2-4D00-BA6B-F722FFCCCFBF"))
        let translation = TranslationCatalog.Translation(
            id: translationId,
            expressionId: expressionId,
            value: "Overture to Egmont, Op. 84",
            language: .english,
            region: .unitedStates,
            state: .translated
        )

        try catalog.createExpression(expression)
        try catalog.createTranslation(translation)

        var expressions = try catalog.expressions()
        #expect(expressions.count == 1)

        var translations = try catalog.translations()
        #expect(translations.count == 1)

        try catalog.deleteExpression(expressionId)

        expressions = try catalog.expressions()
        #expect(expressions.count == 0)

        translations = try catalog.translations()
        #expect(translations.count == 0)
    }

    /// Verify that a `Project` can be removed from the catalog, and it's related
    /// `Expression` entities remain intact.
    @Test(arguments: try Self.container.catalogs)
    func deleteProject_NullifyExpression(catalog: any Catalog) throws {
        let projectId = try #require(UUID(uuidString: "06937A10-2E46-4FFD-A2E7-60A3F03ED007"))
        let project = Project(
            id: projectId,
            name: "Example Project"
        )

        let expressionId = try #require(UUID(uuidString: "F590AA58-626D-4EAB-AEDA-21F047B9BA42"))
        let expression = Expression(
            id: expressionId,
            key: "TRACK_TITLE",
            value: "Track Title",
            languageCode: .english
        )

        try catalog.createProject(project)
        try catalog.createExpression(expression)
        try catalog.updateProject(projectId, action: GenericProjectUpdate.linkExpression(expressionId))

        var projects = try catalog.projects()
        #expect(projects.count == 1)

        var expressions = try catalog.expressions()
        #expect(expressions.count == 1)

        try catalog.deleteProject(projectId)

        projects = try catalog.projects()
        #expect(projects.count == 0)

        expressions = try catalog.expressions()
        #expect(expressions.count == 1)
    }
}
