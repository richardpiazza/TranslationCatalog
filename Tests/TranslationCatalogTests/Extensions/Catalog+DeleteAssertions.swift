@testable import TranslationCatalog
import XCTest

extension Catalog {
    /// Verify that a `Project` can be removed from the catalog.
    func assertDeleteProject() throws {
        let projectId = UUID(uuidString: "06937A10-2E46-4FFD-A2E7-60A3F03ED007")!
        let project = Project(id: projectId, name: "Example Project")

        func preConditions(catalog: Catalog) throws {
            try catalog.createProject(project)
            let projects = try catalog.projects()
            XCTAssertEqual(projects.count, 1)
        }

        func postConditions(catalog: Catalog) throws {
            let projects = try catalog.projects()
            XCTAssertEqual(projects.count, 0)
        }

        try preConditions(catalog: self)
        try deleteProject(projectId)
        try postConditions(catalog: self)
    }

    /// Verify that a `Expression` can be removed from the catalog.
    func assertDeleteExpression() throws {
        let expressionId = UUID(uuidString: "0503A67E-EAC5-4612-A91A-559477283C56")!
        let expression = Expression(
            id: expressionId,
            key: "TEST_EXPRESSION",
            value: "Test Expression",
            languageCode: .english
        )

        func preConditions(catalog: Catalog) throws {
            try catalog.createExpression(expression)
            let expressions = try catalog.expressions()
            XCTAssertEqual(expressions.count, 1)
        }

        func postConditions(catalog: Catalog) throws {
            let expressions = try catalog.expressions()
            XCTAssertEqual(expressions.count, 0)
        }

        try preConditions(catalog: self)
        try deleteExpression(expressionId)
        try postConditions(catalog: self)
    }

    /// Verify that a `Translation` can be removed from the catalog.
    func assertDeleteTranslation() throws {
        let expressionId = UUID(uuidString: "F590AA58-626D-4EAB-AEDA-21F047B9BA42")!
        let expression = Expression(
            id: expressionId,
            key: "TRACK_TITLE",
            value: "Track Title",
            languageCode: .english
        )
        let translationId = UUID(uuidString: "A93E74CD-58F2-4D00-BA6B-F722FFCCCFBF")!
        let translation = TranslationCatalog.Translation(
            id: translationId,
            expressionId: expressionId,
            value: "Overture to Egmont, Op. 84",
            language: .english,
            region: .unitedStates,
            state: .translated
        )

        func preConditions(catalog: Catalog) throws {
            try catalog.createExpression(expression)
            try catalog.createTranslation(translation)
            let translations = try catalog.translations()
            XCTAssertEqual(translations.count, 1)
        }

        func postConditions(catalog: Catalog) throws {
            let translations = try catalog.translations()
            XCTAssertEqual(translations.count, 0)
        }

        try preConditions(catalog: self)
        try deleteTranslation(translationId)
        try postConditions(catalog: self)
    }

    /// Verify that a `Expression` can be removed from the catalog, and it's related `Translation` entities are also removed.
    func assertDeleteExpression_CascadeTranslation() throws {
        let expressionId = UUID(uuidString: "F590AA58-626D-4EAB-AEDA-21F047B9BA42")!
        let expression = Expression(
            id: expressionId,
            key: "TRACK_TITLE",
            value: "Track Title",
            languageCode: .english
        )
        let translationId = UUID(uuidString: "A93E74CD-58F2-4D00-BA6B-F722FFCCCFBF")!
        let translation = TranslationCatalog.Translation(
            id: translationId,
            expressionId: expressionId,
            value: "Overture to Egmont, Op. 84",
            language: .english,
            region: .unitedStates,
            state: .translated
        )

        func preConditions(catalog: Catalog) throws {
            try catalog.createExpression(expression)
            try catalog.createTranslation(translation)
            let expressions = try catalog.expressions()
            XCTAssertEqual(expressions.count, 1)
            let translations = try catalog.translations()
            XCTAssertEqual(translations.count, 1)
        }

        func postConditions(catalog: Catalog) throws {
            let expressions = try catalog.expressions()
            XCTAssertEqual(expressions.count, 0)
            let translations = try catalog.translations()
            XCTAssertEqual(translations.count, 0)
        }

        try preConditions(catalog: self)
        try deleteExpression(expressionId)
        try postConditions(catalog: self)
    }

    /// Verify that a `Project` can be removed from the catalog, and it's related `Expression` entities remain intact.
    func assertDeleteProject_NullifyExpression() throws {
        let projectId = UUID(uuidString: "06937A10-2E46-4FFD-A2E7-60A3F03ED007")!
        let project = Project(id: projectId, name: "Example Project")
        let expressionId = UUID(uuidString: "F590AA58-626D-4EAB-AEDA-21F047B9BA42")!
        let expression = Expression(
            id: expressionId,
            key: "TRACK_TITLE",
            value: "Track Title",
            languageCode: .english
        )

        func preConditions(catalog: Catalog) throws {
            try catalog.createProject(project)
            try catalog.createExpression(expression)
            try catalog.updateProject(projectId, action: GenericProjectUpdate.linkExpression(expressionId))
            let projects = try catalog.projects()
            XCTAssertEqual(projects.count, 1)
            let expressions = try catalog.expressions()
            XCTAssertEqual(expressions.count, 1)
        }

        func postConditions(catalog: Catalog) throws {
            let projects = try catalog.projects()
            XCTAssertEqual(projects.count, 0)
            let expressions = try catalog.expressions()
            XCTAssertEqual(expressions.count, 1)
        }

        try preConditions(catalog: self)
        try deleteProject(projectId)
        try postConditions(catalog: self)
    }
}
