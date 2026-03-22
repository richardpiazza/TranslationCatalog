import Foundation
import Testing
@testable @preconcurrency import TranslationCatalog
#if canImport(CoreData)
@testable import TranslationCatalogCoreData
#endif
@testable import TranslationCatalogFilesystem
@testable import TranslationCatalogSQLite

final class CatalogUpdateTests {

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

    /// Verify that a `Project` can be renamed.
    @Test(arguments: try Self.container.catalogs)
    func updateProjectName(catalog: any Catalog) throws {
        let projectId = try #require(UUID(uuidString: "2CF3BCAD-18A6-4839-9A26-3A3D1348156C"))
        let project = Project(
            id: projectId,
            name: "Example 1"
        )

        try catalog.createProject(project)

        var entity = try catalog.project(projectId)
        #expect(entity.name == "Example 1")

        try catalog.updateProject(projectId, action: GenericProjectUpdate.name("Example-2"))

        entity = try catalog.project(projectId)
        #expect(entity.name == "Example-2")
    }

    /// Verify that a `Expression` can be linked to a `Project`.
    @Test(arguments: try Self.container.catalogs)
    func updateProject_LinkExpression(catalog: any Catalog) throws {
        let projectId = try #require(UUID(uuidString: "305EFF45-DC61-4129-8BE7-D11FA03ABAA8"))
        let project = Project(
            id: projectId,
            name: "Project"
        )

        let expressionId = try #require(UUID(uuidString: "966D8BFF-607C-4C8D-9F84-59B21DD5B25E"))
        let expression = Expression(
            id: expressionId,
            key: "TEST_KEY",
            value: "Test",
            languageCode: .english
        )

        try catalog.createProject(project)
        try catalog.createExpression(expression)

        var expressions = try catalog.expressions(matching: GenericExpressionQuery.projectId(projectId))
        #expect(expressions.count == 0)

        try catalog.updateProject(projectId, action: GenericProjectUpdate.linkExpression(expressionId))

        expressions = try catalog.expressions(matching: GenericExpressionQuery.projectId(projectId))
        #expect(expressions.count == 1)
    }

    /// Verify that a `Expression` can be unlinked from a `Project`.
    @Test(arguments: try Self.container.catalogs)
    func updateProject_UnlinkExpression(catalog: any Catalog) throws {
        let expressionId = try #require(UUID(uuidString: "966D8BFF-607C-4C8D-9F84-59B21DD5B25E"))
        let expression = Expression(
            id: expressionId,
            key: "TEST_KEY",
            value: "Test",
            languageCode: .english
        )

        let projectId = try #require(UUID(uuidString: "305EFF45-DC61-4129-8BE7-D11FA03ABAA8"))
        let project = Project(
            id: projectId,
            name: "Project",
            expressions: [expression]
        )

        try catalog.createProject(project)

        var expressions = try catalog.expressions(matching: GenericExpressionQuery.projectId(projectId))
        #expect(expressions.count == 1)

        try catalog.updateProject(projectId, action: GenericProjectUpdate.unlinkExpression(expressionId))

        expressions = try catalog.expressions(matching: GenericExpressionQuery.projectId(projectId))
        #expect(expressions.count == 0)
    }

    /// Verify an `Expression.key` can be updated.
    @Test(arguments: try Self.container.catalogs)
    func updateExpressionKey(catalog: any Catalog) throws {
        let expressionId = try #require(UUID(uuidString: "966D8BFF-607C-4C8D-9F84-59B21DD5B25E"))
        let expression = Expression(
            id: expressionId,
            key: "TEST_KEY",
            value: "Test",
            languageCode: .english
        )

        try catalog.createExpression(expression)

        var entity = try catalog.expression(expressionId)
        #expect(entity.key == "TEST_KEY")

        try catalog.updateExpression(expressionId, action: GenericExpressionUpdate.key("KEY_ONE"))

        entity = try catalog.expression(expressionId)
        #expect(entity.key == "KEY_ONE")
    }

    /// Verify an `Expression.name` can be updated.
    @Test(arguments: try Self.container.catalogs)
    func updateExpressionName(catalog: any Catalog) throws {
        let expressionId = try #require(UUID(uuidString: "966D8BFF-607C-4C8D-9F84-59B21DD5B25E"))
        let expression = Expression(
            id: expressionId,
            key: "TEST_KEY",
            value: "Test",
            languageCode: .english
        )

        try catalog.createExpression(expression)

        var entity = try catalog.expression(expressionId)
        #expect(entity.name == "")

        try catalog.updateExpression(expressionId, action: GenericExpressionUpdate.name("Example"))

        entity = try catalog.expression(expressionId)
        #expect(entity.name == "Example")
    }

    /// Verify an `Expression.defaultLanguage` can be updated.
    @Test(arguments: try Self.container.catalogs)
    func updateExpressionDefaultLanguage(catalog: any Catalog) throws {
        let expressionId = try #require(UUID(uuidString: "966D8BFF-607C-4C8D-9F84-59B21DD5B25E"))
        let expression = Expression(
            id: expressionId,
            key: "TEST_KEY",
            value: "Test",
            languageCode: .english
        )

        try catalog.createExpression(expression)

        var entity = try catalog.expression(expressionId)
        #expect(entity.defaultLanguageCode == .english)

        try catalog.updateExpression(expressionId, action: GenericExpressionUpdate.defaultLanguage(.french))

        entity = try catalog.expression(expressionId)
        #expect(entity.defaultLanguageCode == .french)
    }

    /// Verify an `Expression.context` can be updated.
    @Test(arguments: try Self.container.catalogs)
    func updateExpressionContext(catalog: any Catalog) throws {
        let id1 = try #require(UUID(uuidString: "966D8BFF-607C-4C8D-9F84-59B21DD5B25E"))
        let id2 = try #require(UUID(uuidString: "0059A713-BDAD-4CEB-8D30-E0A9F332B151"))
        let id3 = try #require(UUID(uuidString: "BA8D479D-79F6-4A34-B17A-76446D44D408"))
        let expression1 = Expression(
            id: id1,
            key: "KEY_ONE",
            value: "Test 1",
            languageCode: .english,
            context: nil
        )
        let expression2 = Expression(
            id: id2,
            key: "KEY_TWO",
            value: "Test 2",
            languageCode: .english,
            context: "General"
        )
        let expression3 = Expression(
            id: id3,
            key: "KEY_THREE",
            value: "Test 3",
            languageCode: .english,
            context: "Common"
        )

        try catalog.createExpression(expression1)
        try catalog.createExpression(expression2)
        try catalog.createExpression(expression3)

        var entity = try catalog.expression(id1)
        #expect(entity.context == nil)
        entity = try catalog.expression(id2)
        #expect(entity.context == "General")
        entity = try catalog.expression(id3)
        #expect(entity.context == "Common")

        try catalog.updateExpression(id1, action: GenericExpressionUpdate.context("Common"))
        try catalog.updateExpression(id2, action: GenericExpressionUpdate.context(nil))
        try catalog.updateExpression(id3, action: GenericExpressionUpdate.context("General"))

        entity = try catalog.expression(id1)
        #expect(entity.context == "Common")
        entity = try catalog.expression(id2)
        #expect(entity.context == nil)
        entity = try catalog.expression(id3)
        #expect(entity.context == "General")
    }

    /// Verify an `Expression.feature` can be updated.
    @Test(arguments: try Self.container.catalogs)
    func updateExpressionFeature(catalog: any Catalog) throws {
        let id1 = try #require(UUID(uuidString: "966D8BFF-607C-4C8D-9F84-59B21DD5B25E"))
        let id2 = try #require(UUID(uuidString: "0059A713-BDAD-4CEB-8D30-E0A9F332B151"))
        let id3 = try #require(UUID(uuidString: "BA8D479D-79F6-4A34-B17A-76446D44D408"))
        let expression1 = Expression(
            id: id1,
            key: "KEY_ONE",
            value: "Test 1",
            languageCode: .english,
            feature: nil
        )
        let expression2 = Expression(
            id: id2,
            key: "KEY_TWO",
            value: "Test 2",
            languageCode: .english,
            feature: "General"
        )
        let expression3 = Expression(
            id: id3,
            key: "KEY_THREE",
            value: "Test 3",
            languageCode: .english,
            feature: "Common"
        )

        try catalog.createExpression(expression1)
        try catalog.createExpression(expression2)
        try catalog.createExpression(expression3)

        var entity = try catalog.expression(id1)
        #expect(entity.feature == nil)
        entity = try catalog.expression(id2)
        #expect(entity.feature == "General")
        entity = try catalog.expression(id3)
        #expect(entity.feature == "Common")

        try catalog.updateExpression(id1, action: GenericExpressionUpdate.feature("Common"))
        try catalog.updateExpression(id2, action: GenericExpressionUpdate.feature(nil))
        try catalog.updateExpression(id3, action: GenericExpressionUpdate.feature("General"))

        entity = try catalog.expression(id1)
        #expect(entity.feature == "Common")
        entity = try catalog.expression(id2)
        #expect(entity.feature == nil)
        entity = try catalog.expression(id3)
        #expect(entity.feature == "General")
    }

    /// Verify that a `Translation.language` can be updated.
    @Test(arguments: try Self.container.catalogs)
    func updateTranslationLanguage(catalog: any Catalog) throws {
        let expressionId = try #require(UUID(uuidString: "CC8AB0A7-E786-4789-A239-9EB958F8E803"))
        let translationId = try #require(UUID(uuidString: "83238FAC-5AFB-4F3A-85E8-B72153FAE5C8"))
        let translation = TranslationCatalog.Translation(
            id: translationId,
            expressionId: expressionId,
            value: "Test",
            language: .english,
            script: nil,
            region: nil,
            state: .translated
        )
        let expression = Expression(
            id: expressionId,
            key: "TEST_KEY",
            value: "A Expression",
            languageCode: .english,
            translations: [translation]
        )

        try catalog.createExpression(expression)

        var entity = try catalog.translation(translationId)
        #expect(entity.language == .english)

        try catalog.updateTranslation(translationId, action: GenericTranslationUpdate.language(.french))

        entity = try catalog.translation(translationId)
        #expect(entity.language == .french)
    }

    /// Verify that a `Translation.script` can be updated.
    @Test(arguments: try Self.container.catalogs)
    func updateTranslationScript(catalog: any Catalog) throws {
        let expressionId = try #require(UUID(uuidString: "CC8AB0A7-E786-4789-A239-9EB958F8E803"))
        let id1 = try #require(UUID(uuidString: "83238FAC-5AFB-4F3A-85E8-B72153FAE5C8"))
        let id2 = try #require(UUID(uuidString: "F6A31A8E-325A-4DFC-B499-CE32725D2C37"))
        let id3 = try #require(UUID(uuidString: "C60193F0-C412-4405-A57A-8669E449307A"))
        let t1 = TranslationCatalog.Translation(
            id: id1,
            expressionId: expressionId,
            value: "Test",
            language: .english,
            script: nil,
            region: nil,
            state: .translated
        )
        let t2 = TranslationCatalog.Translation(
            id: id2,
            expressionId: expressionId,
            value: "Test",
            language: .english,
            script: .arabic,
            region: nil,
            state: .translated
        )
        let t3 = TranslationCatalog.Translation(
            id: id3,
            expressionId: expressionId,
            value: "Test",
            language: .english,
            script: .hanSimplified,
            region: nil,
            state: .translated
        )
        let expression = Expression(
            id: expressionId,
            key: "TEST_KEY",
            value: "A Expression",
            languageCode: .english,
            translations: [t1, t2, t3]
        )

        try catalog.createExpression(expression)

        var entity = try catalog.translation(id1)
        #expect(entity.script == nil)
        entity = try catalog.translation(id2)
        #expect(entity.script == .arabic)
        entity = try catalog.translation(id3)
        #expect(entity.script == .hanSimplified)

        try catalog.updateTranslation(id1, action: GenericTranslationUpdate.script(.devanagari))
        try catalog.updateTranslation(id2, action: GenericTranslationUpdate.script(Locale.Script?.none))
        try catalog.updateTranslation(id3, action: GenericTranslationUpdate.script(.hanTraditional))

        entity = try catalog.translation(id1)
        #expect(entity.script == .devanagari)
        entity = try catalog.translation(id2)
        #expect(entity.script == nil)
        entity = try catalog.translation(id3)
        #expect(entity.script == .hanTraditional)
    }

    /// Verify that a `Translation.region` can be updated.
    @Test(arguments: try Self.container.catalogs)
    func updateTranslationRegion(catalog: any Catalog) throws {
        let expressionId = try #require(UUID(uuidString: "CC8AB0A7-E786-4789-A239-9EB958F8E803"))
        let id1 = try #require(UUID(uuidString: "83238FAC-5AFB-4F3A-85E8-B72153FAE5C8"))
        let id2 = try #require(UUID(uuidString: "F6A31A8E-325A-4DFC-B499-CE32725D2C37"))
        let id3 = try #require(UUID(uuidString: "C60193F0-C412-4405-A57A-8669E449307A"))
        let t1 = TranslationCatalog.Translation(
            id: id1,
            expressionId: expressionId,
            value: "Test",
            language: .english,
            region: nil,
            state: .translated
        )
        let t2 = TranslationCatalog.Translation(
            id: id2,
            expressionId: expressionId,
            value: "Test",
            language: .english,
            region: .unitedKingdom,
            state: .translated
        )
        let t3 = TranslationCatalog.Translation(
            id: id3,
            expressionId: expressionId,
            value: "Test",
            language: .english,
            region: .australia,
            state: .translated
        )
        let expression = Expression(
            id: expressionId,
            key: "TEST_KEY",
            value: "A Expression",
            languageCode: .english,
            translations: [t1, t2, t3]
        )

        try catalog.createExpression(expression)

        var entity = try catalog.translation(id1)
        #expect(entity.region == nil)
        entity = try catalog.translation(id2)
        #expect(entity.region == .unitedKingdom)
        entity = try catalog.translation(id3)
        #expect(entity.region == .australia)

        try catalog.updateTranslation(id1, action: GenericTranslationUpdate.region(.australia))
        try catalog.updateTranslation(id2, action: GenericTranslationUpdate.region(Locale.Region?.none))
        try catalog.updateTranslation(id3, action: GenericTranslationUpdate.region(.unitedKingdom))

        entity = try catalog.translation(id1)
        #expect(entity.region == .australia)
        entity = try catalog.translation(id2)
        #expect(entity.region == nil)
        entity = try catalog.translation(id3)
        #expect(entity.region == .unitedKingdom)
    }

    /// Verify that a `Translation.value` can be updated.
    @Test(arguments: try Self.container.catalogs)
    func updateTranslationValue(catalog: any Catalog) throws {
        let expressionId = try #require(UUID(uuidString: "CF4964F5-B074-40FF-AB2F-F943DFB78276"))
        let translationId = try #require(UUID(uuidString: "55C175DC-3DE8-4783-9CA1-1A970B63C9C7"))
        let translation = TranslationCatalog.Translation(
            id: translationId,
            expressionId: expressionId,
            value: "Initial",
            language: .english,
            state: .translated
        )
        let expression = Expression(
            id: expressionId,
            key: "KEY",
            value: "Name",
            languageCode: .english,
            translations: [translation]
        )

        try catalog.createExpression(expression)

        var entity = try catalog.translation(translationId)
        #expect(entity.value == "Initial")

        try catalog.updateTranslation(translationId, action: GenericTranslationUpdate.value("Updated"))

        entity = try catalog.translation(translationId)
        #expect(entity.value == "Updated")
    }
}
