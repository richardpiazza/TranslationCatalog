public enum CatalogError: Error {
    case badQuery(CatalogQuery)
    case expressionExistingWithKey(String, Expression)
    case expressionID(Expression.ID)
    case projectID(Project.ID)
    case translationExistingWithValue(String, Translation)
    case translationID(Translation.ID)
    case unhandledQuery(CatalogQuery)
    case unhandledUpdate(CatalogUpdate)
}
