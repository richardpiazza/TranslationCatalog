import TranslationCatalog

public enum CatalogIOOperation: CustomStringConvertible {
    case createdExpression(Expression)
    case skippedExpression(Expression)
    case failedExpression(Expression, Error)
    case createdTranslation(Translation)
    case skippedTranslation(Translation)
    case failedTranslation(Translation, Error)
    
    public var description: String {
        switch self {
        case .createdExpression(let expression):
            return "Expression Created '\(expression.name)'"
        case .skippedExpression(let expression):
            return "Expression Exists with Key '\(expression.key)'; checking translations…"
        case .failedExpression(let expression, let error):
            return "Expression Failure '\(expression.key)'; \(error.localizedDescription)"
        case .createdTranslation(let translation):
            return "Translation Created '\(translation.value)'"
        case .skippedTranslation(let translation):
            return "Translation Skipped '\(translation.value)'"
        case .failedTranslation(let translation, let error):
            return "Translation Failure '\(translation.value)'; \(error.localizedDescription)"
        }
    }
}
