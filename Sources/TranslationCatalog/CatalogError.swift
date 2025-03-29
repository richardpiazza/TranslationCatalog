public enum CatalogError: Error {
    case badQuery(CatalogQuery)
    case dataTypeConversion(String? = nil)
    case expressionExistingWithId(Expression.ID, Expression)
    case expressionExistingWithKey(String, Expression)
    case expressionId(Expression.ID)
    case projectExistingWithId(Project.ID, Project)
    case projectId(Project.ID)
    case translationExistingWithId(Translation.ID, Translation)
    case translationExistingWithValue(String, Translation)
    case translationId(Translation.ID)
    case unhandledQuery(CatalogQuery)
    case unhandledUpdate(CatalogUpdate)
}

public extension CatalogError {
    @available(*, deprecated, renamed: "expressionExistingWithId()")
    static func expressionExistingWithID(_ id: Expression.ID, _ expression: Expression) -> Self { .expressionExistingWithId(id, expression) }
    @available(*, deprecated, renamed: "expressionId()")
    static func expressionID(_ id: Expression.ID) -> Self { .expressionId(id) }
    @available(*, deprecated, renamed: "projectId()")
    static func projectID(_ id: Project.ID) -> Self { .projectId(id) }
    @available(*, deprecated, renamed: "translationExistingWithId()")
    static func translationExistingWithID(_ id: Translation.ID, _ translation: Translation) -> Self { .translationExistingWithId(id, translation) }
    @available(*, deprecated, renamed: "translationId()")
    static func translationID(_ id: Translation.ID) -> Self { .translationId(id) }
}
