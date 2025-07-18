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
