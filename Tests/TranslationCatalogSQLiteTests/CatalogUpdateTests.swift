import XCTest
import LocaleSupport
import TranslationCatalog
import TranslationCatalogSQLite

final class CatalogUpdateTests: _CatalogTestCase {
    
    func testUpdateProjectName() throws {
        let id = UUID(uuidString: "2CF3BCAD-18A6-4839-9A26-3A3D1348156C")!
        let project = Project(uuid: id, name: "Example 1")
        
        func preConditions(catalog: SQLiteCatalog) throws {
            try catalog.createProject(project)
        }
        
        func postConditions(catalog: SQLiteCatalog) throws {
            let entity = try catalog.project(id)
            XCTAssertEqual(entity.name, "Example-2")
        }
        
        let catalog = try SQLiteCatalog(url: url)
        try preConditions(catalog: catalog)
        try catalog.updateProject(id, action: GenericProjectUpdate.name("Example-2"))
        try postConditions(catalog: catalog)
    }
    
    func testUpdateProject_LinkExpression() throws {
        let projectId = UUID(uuidString: "305EFF45-DC61-4129-8BE7-D11FA03ABAA8")!
        let project = Project(uuid: projectId, name: "Project")
        let expressionId = UUID(uuidString: "966D8BFF-607C-4C8D-9F84-59B21DD5B25E")!
        let expression = Expression(uuid: expressionId, key: "TEST_KEY", name: "Test", defaultLanguage: .en)
        
        func preConditions(catalog: SQLiteCatalog) throws {
            try catalog.createProject(project)
            try catalog.createExpression(expression)
        }
        
        func postConditions(catalog: SQLiteCatalog) throws {
            let expressions = try catalog.expressions(matching: GenericExpressionQuery.projectID(projectId))
            XCTAssertEqual(expressions.count, 1)
        }
        
        let catalog = try SQLiteCatalog(url: url)
        try preConditions(catalog: catalog)
        try catalog.updateProject(projectId, action: GenericProjectUpdate.linkExpression(expressionId))
        try postConditions(catalog: catalog)
    }
    
    func testUpdateProject_UnlinkExpression() throws {
        let projectId = UUID(uuidString: "305EFF45-DC61-4129-8BE7-D11FA03ABAA8")!
        let expressionId = UUID(uuidString: "966D8BFF-607C-4C8D-9F84-59B21DD5B25E")!
        let expression = Expression(uuid: expressionId, key: "TEST_KEY", name: "Test", defaultLanguage: .en)
        let project = Project(uuid: projectId, name: "Project", expressions: [expression])
        
        func preConditions(catalog: SQLiteCatalog) throws {
            try catalog.createProject(project)
        }
        
        func postConditions(catalog: SQLiteCatalog) throws {
            let expressions = try catalog.expressions(matching: GenericExpressionQuery.projectID(projectId))
            XCTAssertEqual(expressions.count, 0)
        }
        
        let catalog = try SQLiteCatalog(url: url)
        try preConditions(catalog: catalog)
        try catalog.updateProject(projectId, action: GenericProjectUpdate.unlinkExpression(expressionId))
        try postConditions(catalog: catalog)
    }
    
    func testUpdateExpressionKey() throws {
        let expressionId = UUID(uuidString: "966D8BFF-607C-4C8D-9F84-59B21DD5B25E")!
        let expression = Expression(uuid: expressionId, key: "TEST_KEY", name: "Test", defaultLanguage: .en)
        
        func preConditions(catalog: SQLiteCatalog) throws {
            try catalog.createExpression(expression)
        }
        
        func postConditions(catalog: SQLiteCatalog) throws {
            let entity = try catalog.expression(expressionId)
            XCTAssertEqual(entity.key, "KEY_ONE")
        }
        
        let catalog = try SQLiteCatalog(url: url)
        try preConditions(catalog: catalog)
        try catalog.updateExpression(expressionId, action: GenericExpressionUpdate.key("KEY_ONE"))
        try postConditions(catalog: catalog)
    }
    
    func testUpdateExpressionName() throws {
        let expressionId = UUID(uuidString: "966D8BFF-607C-4C8D-9F84-59B21DD5B25E")!
        let expression = Expression(uuid: expressionId, key: "TEST_KEY", name: "Test", defaultLanguage: .en)
        
        func preConditions(catalog: SQLiteCatalog) throws {
            try catalog.createExpression(expression)
        }
        
        func postConditions(catalog: SQLiteCatalog) throws {
            let entity = try catalog.expression(expressionId)
            XCTAssertEqual(entity.name, "Example")
        }
        
        let catalog = try SQLiteCatalog(url: url)
        try preConditions(catalog: catalog)
        try catalog.updateExpression(expressionId, action: GenericExpressionUpdate.name("Example"))
        try postConditions(catalog: catalog)
    }
    
    func testUpdateExpressionDefaultLanguage() throws {
        let expressionId = UUID(uuidString: "966D8BFF-607C-4C8D-9F84-59B21DD5B25E")!
        let expression = Expression(uuid: expressionId, key: "TEST_KEY", name: "Test", defaultLanguage: .en)
        
        func preConditions(catalog: SQLiteCatalog) throws {
            try catalog.createExpression(expression)
        }
        
        func postConditions(catalog: SQLiteCatalog) throws {
            let entity = try catalog.expression(expressionId)
            XCTAssertEqual(entity.defaultLanguage, .fr)
        }
        
        let catalog = try SQLiteCatalog(url: url)
        try preConditions(catalog: catalog)
        try catalog.updateExpression(expressionId, action: GenericExpressionUpdate.defaultLanguage(.fr))
        try postConditions(catalog: catalog)
    }
    
    func testUpdateExpressionContext() throws {
        let id1 = UUID(uuidString: "966D8BFF-607C-4C8D-9F84-59B21DD5B25E")!
        let id2 = UUID(uuidString: "0059A713-BDAD-4CEB-8D30-E0A9F332B151")!
        let id3 = UUID(uuidString: "BA8D479D-79F6-4A34-B17A-76446D44D408")!
        let expression1 = Expression(uuid: id1, key: "KEY_ONE", name: "Test 1", defaultLanguage: .en, context: nil)
        let expression2 = Expression(uuid: id2, key: "KEY_TWO", name: "Test 2", defaultLanguage: .en, context: "General")
        let expression3 = Expression(uuid: id3, key: "KEY_THREE", name: "Test 3", defaultLanguage: .en, context: "Common")
        
        func preConditions(catalog: SQLiteCatalog) throws {
            try catalog.createExpression(expression1)
            try catalog.createExpression(expression2)
            try catalog.createExpression(expression3)
        }
        
        func postConditions(catalog: SQLiteCatalog) throws {
            var entity = try catalog.expression(id1)
            XCTAssertEqual(entity.context, "Common")
            entity = try catalog.expression(id2)
            XCTAssertEqual(entity.context, nil)
            entity = try catalog.expression(id3)
            XCTAssertEqual(entity.context, "General")
        }
        
        let catalog = try SQLiteCatalog(url: url)
        try preConditions(catalog: catalog)
        try catalog.updateExpression(id1, action: GenericExpressionUpdate.context("Common"))
        try catalog.updateExpression(id2, action: GenericExpressionUpdate.context(nil))
        try catalog.updateExpression(id3, action: GenericExpressionUpdate.context("General"))
        try postConditions(catalog: catalog)
    }
    
    func testUpdateExpressionFeature() throws {
        let id1 = UUID(uuidString: "966D8BFF-607C-4C8D-9F84-59B21DD5B25E")!
        let id2 = UUID(uuidString: "0059A713-BDAD-4CEB-8D30-E0A9F332B151")!
        let id3 = UUID(uuidString: "BA8D479D-79F6-4A34-B17A-76446D44D408")!
        let expression1 = Expression(uuid: id1, key: "KEY_ONE", name: "Test 1", defaultLanguage: .en, feature: nil)
        let expression2 = Expression(uuid: id2, key: "KEY_TWO", name: "Test 2", defaultLanguage: .en, feature: "General")
        let expression3 = Expression(uuid: id3, key: "KEY_THREE", name: "Test 3", defaultLanguage: .en, feature: "Common")
        
        func preConditions(catalog: SQLiteCatalog) throws {
            try catalog.createExpression(expression1)
            try catalog.createExpression(expression2)
            try catalog.createExpression(expression3)
        }
        
        func postConditions(catalog: SQLiteCatalog) throws {
            var entity = try catalog.expression(id1)
            XCTAssertEqual(entity.feature, "Common")
            entity = try catalog.expression(id2)
            XCTAssertEqual(entity.feature, nil)
            entity = try catalog.expression(id3)
            XCTAssertEqual(entity.feature, "General")
        }
        
        let catalog = try SQLiteCatalog(url: url)
        try preConditions(catalog: catalog)
        try catalog.updateExpression(id1, action: GenericExpressionUpdate.feature("Common"))
        try catalog.updateExpression(id2, action: GenericExpressionUpdate.feature(nil))
        try catalog.updateExpression(id3, action: GenericExpressionUpdate.feature("General"))
        try postConditions(catalog: catalog)
    }
    
    func testUpdateExpression_LinkProject() throws {
        let projectId = UUID(uuidString: "305EFF45-DC61-4129-8BE7-D11FA03ABAA8")!
        let project = Project(uuid: projectId, name: "Project")
        let expressionId = UUID(uuidString: "966D8BFF-607C-4C8D-9F84-59B21DD5B25E")!
        let expression = Expression(uuid: expressionId, key: "TEST_KEY", name: "Test", defaultLanguage: .en)
        
        func preConditions(catalog: SQLiteCatalog) throws {
            try catalog.createProject(project)
            try catalog.createExpression(expression)
        }
        
        func postConditions(catalog: SQLiteCatalog) throws {
            let expressions = try catalog.expressions(matching: GenericExpressionQuery.projectID(projectId))
            XCTAssertEqual(expressions.count, 1)
        }
        
        let catalog = try SQLiteCatalog(url: url)
        try preConditions(catalog: catalog)
        try catalog.updateProject(projectId, action: GenericProjectUpdate.linkExpression(expressionId))
        try postConditions(catalog: catalog)
    }
    
    func testUpdateExpression_UnlinkProject() throws {
        let projectId = UUID(uuidString: "305EFF45-DC61-4129-8BE7-D11FA03ABAA8")!
        let expressionId = UUID(uuidString: "966D8BFF-607C-4C8D-9F84-59B21DD5B25E")!
        let expression = Expression(uuid: expressionId, key: "TEST_KEY", name: "Test", defaultLanguage: .en)
        let project = Project(uuid: projectId, name: "Project", expressions: [expression])
        
        func preConditions(catalog: SQLiteCatalog) throws {
            try catalog.createProject(project)
        }
        
        func postConditions(catalog: SQLiteCatalog) throws {
            let expressions = try catalog.expressions(matching: GenericExpressionQuery.projectID(projectId))
            XCTAssertEqual(expressions.count, 0)
        }
        
        let catalog = try SQLiteCatalog(url: url)
        try preConditions(catalog: catalog)
        try catalog.updateProject(projectId, action: GenericProjectUpdate.unlinkExpression(expressionId))
        try postConditions(catalog: catalog)
    }
    
    func testUpdateTranslationLanguage() throws {
        let expressionId = UUID(uuidString: "CC8AB0A7-E786-4789-A239-9EB958F8E803")!
        let translationId = UUID(uuidString: "83238FAC-5AFB-4F3A-85E8-B72153FAE5C8")!
        let translation = TranslationCatalog.Translation(uuid: translationId, expressionID: expressionId, languageCode: .en, scriptCode: nil, regionCode: nil, value: "Test")
        let expression = Expression(uuid: expressionId, key: "TEST_KEY", name: "A Expression", defaultLanguage: .en, translations: [translation])
        
        func preConditions(catalog: SQLiteCatalog) throws {
            try catalog.createExpression(expression)
        }
        
        func postConditions(catalog: SQLiteCatalog) throws {
            let entity = try catalog.translation(translationId)
            XCTAssertEqual(entity.languageCode, .fr)
        }
        
        let catalog = try SQLiteCatalog(url: url)
        try preConditions(catalog: catalog)
        try catalog.updateTranslation(translationId, action: GenericTranslationUpdate.language(.fr))
        try postConditions(catalog: catalog)
    }
    
    func testUpdateTranslationScript() throws {
        let expressionId = UUID(uuidString: "CC8AB0A7-E786-4789-A239-9EB958F8E803")!
        let id1 = UUID(uuidString: "83238FAC-5AFB-4F3A-85E8-B72153FAE5C8")!
        let id2 = UUID(uuidString: "F6A31A8E-325A-4DFC-B499-CE32725D2C37")!
        let id3 = UUID(uuidString: "C60193F0-C412-4405-A57A-8669E449307A")!
        let t1 = TranslationCatalog.Translation(uuid: id1, expressionID: expressionId, languageCode: .en, scriptCode: nil, regionCode: nil, value: "Test")
        let t2 = TranslationCatalog.Translation(uuid: id2, expressionID: expressionId, languageCode: .en, scriptCode: .Arab, regionCode: nil, value: "Test")
        let t3 = TranslationCatalog.Translation(uuid: id3, expressionID: expressionId, languageCode: .en, scriptCode: .Hans, regionCode: nil, value: "Test")
        let expression = Expression(uuid: expressionId, key: "TEST_KEY", name: "A Expression", defaultLanguage: .en, translations: [t1, t2, t3])
        
        func preConditions(catalog: SQLiteCatalog) throws {
            try catalog.createExpression(expression)
        }
        
        func postConditions(catalog: SQLiteCatalog) throws {
            var entity = try catalog.translation(id1)
            XCTAssertEqual(entity.scriptCode, .Deva)
            entity = try catalog.translation(id2)
            XCTAssertEqual(entity.scriptCode, nil)
            entity = try catalog.translation(id3)
            XCTAssertEqual(entity.scriptCode, .Hant)
        }
        
        let catalog = try SQLiteCatalog(url: url)
        try preConditions(catalog: catalog)
        try catalog.updateTranslation(id1, action: GenericTranslationUpdate.script(.Deva))
        try catalog.updateTranslation(id2, action: GenericTranslationUpdate.script(nil))
        try catalog.updateTranslation(id3, action: GenericTranslationUpdate.script(.Hant))
        try postConditions(catalog: catalog)
    }
    
    func testUpdateTranslationRegion() throws {
        let expressionId = UUID(uuidString: "CC8AB0A7-E786-4789-A239-9EB958F8E803")!
        let id1 = UUID(uuidString: "83238FAC-5AFB-4F3A-85E8-B72153FAE5C8")!
        let id2 = UUID(uuidString: "F6A31A8E-325A-4DFC-B499-CE32725D2C37")!
        let id3 = UUID(uuidString: "C60193F0-C412-4405-A57A-8669E449307A")!
        let t1 = TranslationCatalog.Translation(uuid: id1, expressionID: expressionId, languageCode: .en, regionCode: nil, value: "Test")
        let t2 = TranslationCatalog.Translation(uuid: id2, expressionID: expressionId, languageCode: .en, regionCode: .GB, value: "Test")
        let t3 = TranslationCatalog.Translation(uuid: id3, expressionID: expressionId, languageCode: .en, regionCode: .AU, value: "Test")
        let expression = Expression(uuid: expressionId, key: "TEST_KEY", name: "A Expression", defaultLanguage: .en, translations: [t1, t2, t3])
        
        func preConditions(catalog: SQLiteCatalog) throws {
            try catalog.createExpression(expression)
        }
        
        func postConditions(catalog: SQLiteCatalog) throws {
            var entity = try catalog.translation(id1)
            XCTAssertEqual(entity.regionCode, .AU)
            entity = try catalog.translation(id2)
            XCTAssertEqual(entity.regionCode, nil)
            entity = try catalog.translation(id3)
            XCTAssertEqual(entity.regionCode, .GB)
        }
        
        let catalog = try SQLiteCatalog(url: url)
        try preConditions(catalog: catalog)
        try catalog.updateTranslation(id1, action: GenericTranslationUpdate.region(.AU))
        try catalog.updateTranslation(id2, action: GenericTranslationUpdate.region(nil))
        try catalog.updateTranslation(id3, action: GenericTranslationUpdate.region(.GB))
        try postConditions(catalog: catalog)
    }
    
    func testUpdateTranslationValue() throws {
        let expressionId = UUID(uuidString: "CF4964F5-B074-40FF-AB2F-F943DFB78276")!
        let translationId = UUID(uuidString: "55C175DC-3DE8-4783-9CA1-1A970B63C9C7")!
        let translation = TranslationCatalog.Translation(uuid: translationId, expressionID: expressionId, languageCode: .en, value: "Initial")
        let expression = Expression(uuid: expressionId, key: "KEY", name: "Name", defaultLanguage: .en, translations: [translation])
        
        func preConditions(catalog: SQLiteCatalog) throws {
            try catalog.createExpression(expression)
        }
        
        func postConditions(catalog: SQLiteCatalog) throws {
            let entity = try catalog.translation(translationId)
            XCTAssertEqual(entity.value, "Updated")
        }
        
        let catalog = try SQLiteCatalog(url: url)
        try preConditions(catalog: catalog)
        try catalog.updateTranslation(translationId, action: GenericTranslationUpdate.value("Updated"))
        try postConditions(catalog: catalog)
    }
}
