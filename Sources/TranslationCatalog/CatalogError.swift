public enum CatalogError: Error {
    case badQuery(CatalogQuery)
    case expressionID(Expression.ID)
    case projectID(Project.ID)
    case translationID(Translation.ID)
    case unhandledQuery(CatalogQuery)
}
