@testable import TranslationCatalog
import XCTest

extension Catalog {
    /// Verify that a `Project` can be renamed.
    func assertUpdateProjectName() throws {
        let id = UUID(uuidString: "2CF3BCAD-18A6-4839-9A26-3A3D1348156C")!
        let project = Project(id: id, name: "Example 1")

        func preConditions(catalog: Catalog) throws {
            try catalog.createProject(project)
        }

        func postConditions(catalog: Catalog) throws {
            let entity = try catalog.project(id)
            XCTAssertEqual(entity.name, "Example-2")
        }

        try preConditions(catalog: self)
        try updateProject(id, action: GenericProjectUpdate.name("Example-2"))
        try postConditions(catalog: self)
    }

    /// Verify that a `Expression` can be linked to a `Project`.
    func assertUpdateProject_LinkExpression() throws {
        let projectId = UUID(uuidString: "305EFF45-DC61-4129-8BE7-D11FA03ABAA8")!
        let project = Project(id: projectId, name: "Project")
        let expressionId = UUID(uuidString: "966D8BFF-607C-4C8D-9F84-59B21DD5B25E")!
        let expression = Expression(id: expressionId, key: "TEST_KEY", name: "Test", defaultLanguageCode: .english)

        func preConditions(catalog: Catalog) throws {
            try catalog.createProject(project)
            try catalog.createExpression(expression)
        }

        func postConditions(catalog: Catalog) throws {
            let expressions = try catalog.expressions(matching: GenericExpressionQuery.projectId(projectId))
            XCTAssertEqual(expressions.count, 1)
        }

        try preConditions(catalog: self)
        try updateProject(projectId, action: GenericProjectUpdate.linkExpression(expressionId))
        try postConditions(catalog: self)
    }

    /// Verify that a `Expression` can be unlinked from a `Project`.
    func assertUpdateProject_UnlinkExpression() throws {
        let projectId = UUID(uuidString: "305EFF45-DC61-4129-8BE7-D11FA03ABAA8")!
        let expressionId = UUID(uuidString: "966D8BFF-607C-4C8D-9F84-59B21DD5B25E")!
        let expression = Expression(id: expressionId, key: "TEST_KEY", name: "Test", defaultLanguageCode: .english)
        let project = Project(id: projectId, name: "Project", expressions: [expression])

        func preConditions(catalog: Catalog) throws {
            try catalog.createProject(project)
        }

        func postConditions(catalog: Catalog) throws {
            let expressions = try catalog.expressions(matching: GenericExpressionQuery.projectId(projectId))
            XCTAssertEqual(expressions.count, 0)
        }

        try preConditions(catalog: self)
        try updateProject(projectId, action: GenericProjectUpdate.unlinkExpression(expressionId))
        try postConditions(catalog: self)
    }

    /// Verify an `Expression.key` can be updated.
    func assertUpdateExpressionKey() throws {
        let expressionId = UUID(uuidString: "966D8BFF-607C-4C8D-9F84-59B21DD5B25E")!
        let expression = Expression(id: expressionId, key: "TEST_KEY", name: "Test", defaultLanguageCode: .english)

        func preConditions(catalog: Catalog) throws {
            try catalog.createExpression(expression)
        }

        func postConditions(catalog: Catalog) throws {
            let entity = try catalog.expression(expressionId)
            XCTAssertEqual(entity.key, "KEY_ONE")
        }

        try preConditions(catalog: self)
        try updateExpression(expressionId, action: GenericExpressionUpdate.key("KEY_ONE"))
        try postConditions(catalog: self)
    }

    /// Verify an `Expression.name` can be updated.
    func assertUpdateExpressionName() throws {
        let expressionId = UUID(uuidString: "966D8BFF-607C-4C8D-9F84-59B21DD5B25E")!
        let expression = Expression(id: expressionId, key: "TEST_KEY", name: "Test", defaultLanguageCode: .english)

        func preConditions(catalog: Catalog) throws {
            try catalog.createExpression(expression)
        }

        func postConditions(catalog: Catalog) throws {
            let entity = try catalog.expression(expressionId)
            XCTAssertEqual(entity.name, "Example")
        }

        try preConditions(catalog: self)
        try updateExpression(expressionId, action: GenericExpressionUpdate.name("Example"))
        try postConditions(catalog: self)
    }

    /// Verify an `Expression.defaultLanguage` can be updated.
    func assertUpdateExpressionDefaultLanguage() throws {
        let expressionId = UUID(uuidString: "966D8BFF-607C-4C8D-9F84-59B21DD5B25E")!
        let expression = Expression(id: expressionId, key: "TEST_KEY", name: "Test", defaultLanguageCode: .english)

        func preConditions(catalog: Catalog) throws {
            try catalog.createExpression(expression)
        }

        func postConditions(catalog: Catalog) throws {
            let entity = try catalog.expression(expressionId)
            XCTAssertEqual(entity.defaultLanguageCode, .french)
        }

        try preConditions(catalog: self)
        try updateExpression(expressionId, action: GenericExpressionUpdate.defaultLanguage(.french))
        try postConditions(catalog: self)
    }

    /// Verify an `Expression.context` can be updated.
    func assertUpdateExpressionContext() throws {
        let id1 = UUID(uuidString: "966D8BFF-607C-4C8D-9F84-59B21DD5B25E")!
        let id2 = UUID(uuidString: "0059A713-BDAD-4CEB-8D30-E0A9F332B151")!
        let id3 = UUID(uuidString: "BA8D479D-79F6-4A34-B17A-76446D44D408")!
        let expression1 = Expression(id: id1, key: "KEY_ONE", name: "Test 1", defaultLanguageCode: .english, context: nil)
        let expression2 = Expression(id: id2, key: "KEY_TWO", name: "Test 2", defaultLanguageCode: .english, context: "General")
        let expression3 = Expression(id: id3, key: "KEY_THREE", name: "Test 3", defaultLanguageCode: .english, context: "Common")

        func preConditions(catalog: Catalog) throws {
            try catalog.createExpression(expression1)
            try catalog.createExpression(expression2)
            try catalog.createExpression(expression3)
        }

        func postConditions(catalog: Catalog) throws {
            var entity = try catalog.expression(id1)
            XCTAssertEqual(entity.context, "Common")
            entity = try catalog.expression(id2)
            XCTAssertEqual(entity.context, nil)
            entity = try catalog.expression(id3)
            XCTAssertEqual(entity.context, "General")
        }

        try preConditions(catalog: self)
        try updateExpression(id1, action: GenericExpressionUpdate.context("Common"))
        try updateExpression(id2, action: GenericExpressionUpdate.context(nil))
        try updateExpression(id3, action: GenericExpressionUpdate.context("General"))
        try postConditions(catalog: self)
    }

    /// Verify an `Expression.feature` can be updated.
    func assertUpdateExpressionFeature() throws {
        let id1 = UUID(uuidString: "966D8BFF-607C-4C8D-9F84-59B21DD5B25E")!
        let id2 = UUID(uuidString: "0059A713-BDAD-4CEB-8D30-E0A9F332B151")!
        let id3 = UUID(uuidString: "BA8D479D-79F6-4A34-B17A-76446D44D408")!
        let expression1 = Expression(id: id1, key: "KEY_ONE", name: "Test 1", defaultLanguageCode: .english, feature: nil)
        let expression2 = Expression(id: id2, key: "KEY_TWO", name: "Test 2", defaultLanguageCode: .english, feature: "General")
        let expression3 = Expression(id: id3, key: "KEY_THREE", name: "Test 3", defaultLanguageCode: .english, feature: "Common")

        func preConditions(catalog: Catalog) throws {
            try catalog.createExpression(expression1)
            try catalog.createExpression(expression2)
            try catalog.createExpression(expression3)
        }

        func postConditions(catalog: Catalog) throws {
            var entity = try catalog.expression(id1)
            XCTAssertEqual(entity.feature, "Common")
            entity = try catalog.expression(id2)
            XCTAssertEqual(entity.feature, nil)
            entity = try catalog.expression(id3)
            XCTAssertEqual(entity.feature, "General")
        }

        try preConditions(catalog: self)
        try updateExpression(id1, action: GenericExpressionUpdate.feature("Common"))
        try updateExpression(id2, action: GenericExpressionUpdate.feature(nil))
        try updateExpression(id3, action: GenericExpressionUpdate.feature("General"))
        try postConditions(catalog: self)
    }

    /// Verify that a `Translation.language` can be updated.
    func assertUpdateTranslationLanguage() throws {
        let expressionId = UUID(uuidString: "CC8AB0A7-E786-4789-A239-9EB958F8E803")!
        let translationId = UUID(uuidString: "83238FAC-5AFB-4F3A-85E8-B72153FAE5C8")!
        let translation = TranslationCatalog.Translation(id: translationId, expressionId: expressionId, language: .english, script: nil, region: nil, value: "Test")
        let expression = Expression(id: expressionId, key: "TEST_KEY", name: "A Expression", defaultLanguageCode: .english, translations: [translation])

        func preConditions(catalog: Catalog) throws {
            try catalog.createExpression(expression)
        }

        func postConditions(catalog: Catalog) throws {
            let entity = try catalog.translation(translationId)
            XCTAssertEqual(entity.languageCode, .fr)
        }

        try preConditions(catalog: self)
        try updateTranslation(translationId, action: GenericTranslationUpdate.language(.french))
        try postConditions(catalog: self)
    }

    /// Verify that a `Translation.script` can be updated.
    func assertUpdateTranslationScript() throws {
        let expressionId = UUID(uuidString: "CC8AB0A7-E786-4789-A239-9EB958F8E803")!
        let id1 = UUID(uuidString: "83238FAC-5AFB-4F3A-85E8-B72153FAE5C8")!
        let id2 = UUID(uuidString: "F6A31A8E-325A-4DFC-B499-CE32725D2C37")!
        let id3 = UUID(uuidString: "C60193F0-C412-4405-A57A-8669E449307A")!
        let t1 = TranslationCatalog.Translation(id: id1, expressionId: expressionId, language: .english, script: nil, region: nil, value: "Test")
        let t2 = TranslationCatalog.Translation(id: id2, expressionId: expressionId, language: .english, script: .arabic, region: nil, value: "Test")
        let t3 = TranslationCatalog.Translation(id: id3, expressionId: expressionId, language: .english, script: .hanSimplified, region: nil, value: "Test")
        let expression = Expression(id: expressionId, key: "TEST_KEY", name: "A Expression", defaultLanguageCode: .english, translations: [t1, t2, t3])

        func preConditions(catalog: Catalog) throws {
            try catalog.createExpression(expression)
        }

        func postConditions(catalog: Catalog) throws {
            var entity = try catalog.translation(id1)
            XCTAssertEqual(entity.scriptCode, .Deva)
            entity = try catalog.translation(id2)
            XCTAssertEqual(entity.scriptCode, nil)
            entity = try catalog.translation(id3)
            XCTAssertEqual(entity.scriptCode, .Hant)
        }

        try preConditions(catalog: self)
        try updateTranslation(id1, action: GenericTranslationUpdate.script(.devanagari))
        try updateTranslation(id2, action: GenericTranslationUpdate.script(Locale.Script?.none))
        try updateTranslation(id3, action: GenericTranslationUpdate.script(.hanTraditional))
        try postConditions(catalog: self)
    }

    /// Verify that a `Translation.region` can be updated.
    func assertUpdateTranslationRegion() throws {
        let expressionId = UUID(uuidString: "CC8AB0A7-E786-4789-A239-9EB958F8E803")!
        let id1 = UUID(uuidString: "83238FAC-5AFB-4F3A-85E8-B72153FAE5C8")!
        let id2 = UUID(uuidString: "F6A31A8E-325A-4DFC-B499-CE32725D2C37")!
        let id3 = UUID(uuidString: "C60193F0-C412-4405-A57A-8669E449307A")!
        let t1 = TranslationCatalog.Translation(id: id1, expressionId: expressionId, language: .english, region: nil, value: "Test")
        let t2 = TranslationCatalog.Translation(id: id2, expressionId: expressionId, language: .english, region: .unitedKingdom, value: "Test")
        let t3 = TranslationCatalog.Translation(id: id3, expressionId: expressionId, language: .english, region: .australia, value: "Test")
        let expression = Expression(id: expressionId, key: "TEST_KEY", name: "A Expression", defaultLanguageCode: .english, translations: [t1, t2, t3])

        func preConditions(catalog: Catalog) throws {
            try catalog.createExpression(expression)
        }

        func postConditions(catalog: Catalog) throws {
            var entity = try catalog.translation(id1)
            XCTAssertEqual(entity.regionCode, .AU)
            entity = try catalog.translation(id2)
            XCTAssertEqual(entity.regionCode, nil)
            entity = try catalog.translation(id3)
            XCTAssertEqual(entity.regionCode, .GB)
        }

        try preConditions(catalog: self)
        try updateTranslation(id1, action: GenericTranslationUpdate.region(.australia))
        try updateTranslation(id2, action: GenericTranslationUpdate.region(Locale.Region?.none))
        try updateTranslation(id3, action: GenericTranslationUpdate.region(.unitedKingdom))
        try postConditions(catalog: self)
    }

    /// Verify that a `Translation.value` can be updated.
    func assertUpdateTranslationValue() throws {
        let expressionId = UUID(uuidString: "CF4964F5-B074-40FF-AB2F-F943DFB78276")!
        let translationId = UUID(uuidString: "55C175DC-3DE8-4783-9CA1-1A970B63C9C7")!
        let translation = TranslationCatalog.Translation(id: translationId, expressionId: expressionId, language: .english, value: "Initial")
        let expression = Expression(id: expressionId, key: "KEY", name: "Name", defaultLanguageCode: .english, translations: [translation])

        func preConditions(catalog: Catalog) throws {
            try catalog.createExpression(expression)
        }

        func postConditions(catalog: Catalog) throws {
            let entity = try catalog.translation(translationId)
            XCTAssertEqual(entity.value, "Updated")
        }

        try preConditions(catalog: self)
        try updateTranslation(translationId, action: GenericTranslationUpdate.value("Updated"))
        try postConditions(catalog: self)
    }
}
