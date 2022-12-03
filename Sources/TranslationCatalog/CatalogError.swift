public enum CatalogError: Error {
    case badQuery(CatalogQuery)
    case dataTypeConversion(String? = nil)
    case expressionExistingWithID(Expression.ID, Expression)
    case expressionExistingWithKey(String, Expression)
    case expressionID(Expression.ID)
    case projectExistingWithID(Project.ID, Project)
    case projectID(Project.ID)
    case translationExistingWithID(Translation.ID, Translation)
    case translationExistingWithValue(String, Translation)
    case translationID(Translation.ID)
    case unhandledQuery(CatalogQuery)
    case unhandledUpdate(CatalogUpdate)
}
