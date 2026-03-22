import Foundation
import Testing
@testable @preconcurrency import TranslationCatalog
#if canImport(CoreData)
@testable import TranslationCatalogCoreData
#endif
@testable import TranslationCatalogFilesystem
@testable import TranslationCatalogSQLite

final class CatalogInsertTests {

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

    /// Verify that a `Project` can be added to the catalog.
    @Test(arguments: try Self.container.catalogs)
    func insertProject(catalog: any Catalog) throws {
        var projects = try catalog.projects()
        #expect(projects.count == 0)

        let projectId = try #require(UUID(uuidString: "64BBF2A8-0423-4545-B3E1-4A373F6359AF"))
        let projectName = "Project 1"
        let project = Project(
            id: projectId,
            name: projectName
        )

        try catalog.createProject(project)

        projects = try catalog.projects()
        #expect(projects.count == 1)

        let entity = try #require(projects.first)
        #expect(entity.id == projectId)
        #expect(entity.name == projectName)
    }

    /// Verify that a `Expression` can be added to the catalog.
    @Test(arguments: try Self.container.catalogs)
    func insertExpression(catalog: any Catalog) throws {
        var expressions = try catalog.expressions()
        #expect(expressions.count == 0)

        let expressionId = try #require(UUID(uuidString: "A2A5A62D-D532-4FEB-8905-9DBFFC77C07E"))
        let expression = Expression(
            id: expressionId,
            key: "EXP_1",
            value: "Test Expression",
            languageCode: .english,
            context: "Generic Message",
            feature: "Settings"
        )

        try catalog.createExpression(expression)

        expressions = try catalog.expressions()
        #expect(expressions.count == 1)

        let entity = try #require(expressions.first)
        #expect(entity.id == expressionId)
        #expect(entity.key == "EXP_1")
        #expect(entity.defaultValue == "Test Expression")
        #expect(entity.defaultLanguageCode == .english)
        #expect(entity.context == "Generic Message")
        #expect(entity.feature == "Settings")
    }

    /// Verify that a `Translation` can be added to the catalog.
    @Test(arguments: try Self.container.catalogs)
    func insertTranslation(catalog: any Catalog) throws {
        var translations = try catalog.translations()
        #expect(translations.count == 0)

        let expressionId = try #require(UUID(uuidString: "A2A5A62D-D532-4FEB-8905-9DBFFC77C07E"))
        let expression = Expression(
            id: expressionId,
            key: "EXP_1",
            value: "Test Expression",
            languageCode: .english,
            context: "Generic Message",
            feature: "Settings"
        )

        try catalog.createExpression(expression)

        let translationId = try #require(UUID(uuidString: "80F9B7D4-BFF5-41CC-8BB6-28A990864046"))
        let translation = TranslationCatalog.Translation(
            id: translationId,
            expressionId: expressionId,
            value: "Party-on Wayne!",
            language: .english,
            script: nil,
            region: .unitedStates,
            state: .translated
        )

        try catalog.createTranslation(translation)

        translations = try catalog.translations()
        #expect(translations.count == 1)

        let entity = try #require(translations.first)
        #expect(entity.id == translationId)
        #expect(entity.expressionId == expressionId)
        #expect(entity.language == .english)
        #expect(entity.script == nil)
        #expect(entity.region == .unitedStates)
        #expect(entity.value == "Party-on Wayne!")
    }

    /// Verify that a `Project` can be added to the catalog, and the
    /// related `Expression`s are created as well.
    @Test(arguments: try Self.container.catalogs)
    func insertProject_CascadeExpressions(catalog: any Catalog) throws {
        var projects = try catalog.projects()
        #expect(projects.count == 0)

        var expressions = try catalog.expressions()
        #expect(expressions.count == 0)

        let expressionId = try #require(UUID(uuidString: "1721B307-9A67-4FC1-A529-3A128695E802"))
        let expression = Expression(
            id: expressionId,
            key: "BUTTON_NEXT",
            value: "Next",
            languageCode: .english,
            context: "Button Title",
            feature: "Buttons"
        )

        let projectId = try #require(UUID(uuidString: "CB3900B9-C4A8-4953-9CF7-C737323954E9"))
        let project = Project(
            id: projectId,
            name: "",
            expressions: [expression]
        )

        try catalog.createProject(project)

        projects = try catalog.projects()
        #expect(projects.count == 1)

        expressions = try catalog.expressions()
        #expect(expressions.count == 1)
    }

    /// Verify that a `Expression` can be added to the catalog, and the
    /// related `Translation`s are created as well.
    @Test(arguments: try Self.container.catalogs)
    func insertExpression_CascadeTranslations(catalog: any Catalog) throws {
        var expressions = try catalog.expressions()
        #expect(expressions.count == 0)

        var translations = try catalog.translations()
        #expect(translations.count == 0)

        let translationId = try #require(UUID(uuidString: "1C013C96-AEC7-4F05-AC24-F5DF547B77AA"))
        // It shouldn't matter that the correct expressionId is set here... the catalog will auto-override
        let translation = TranslationCatalog.Translation(
            id: translationId,
            expressionId: .zero,
            value: "Next",
            language: .english,
            script: nil,
            region: .unitedStates,
            state: .translated
        )

        let expressionId = try #require(UUID(uuidString: "1721B307-9A67-4FC1-A529-3A128695E802"))
        let expression = Expression(
            id: expressionId,
            key: "BUTTON_NEXT",
            value: "Next",
            languageCode: .english,
            context: "Button Title",
            feature: "Buttons",
            translations: [translation]
        )

        try catalog.createExpression(expression)

        expressions = try catalog.expressions()
        #expect(expressions.count == 1)

        translations = try catalog.translations()
        #expect(translations.count == 1)
    }
}
