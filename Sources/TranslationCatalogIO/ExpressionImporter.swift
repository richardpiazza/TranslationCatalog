import Foundation
import AsyncPlus
import LocaleSupport
import TranslationCatalog

public class ExpressionImporter {
    
    public enum Operation: CustomStringConvertible {
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
    
    private let catalog: Catalog
    
    private var sequence: PassthroughAsyncThrowingSequence<Operation>?
    var stream: AsyncThrowingStream<Operation, Error> {
        sequence?.finish()
        let sequence = PassthroughAsyncThrowingSequence<Operation>()
        self.sequence = sequence
        return sequence.stream
    }
    
    public init(catalog: Catalog) {
        self.catalog = catalog
    }
    
    public func importTranslations(
        from expressions: [Expression]
    ) -> AsyncThrowingStream<Operation, Error> {
        defer {
            expressions
                .sorted(by: { $0.name < $1.name })
                .forEach {
                    importExpression($0, into: catalog)
                }
            
            sequence?.finish()
        }
        
        return stream
    }
    
    private func importExpression(_ expression: Expression, into catalog: Catalog) {
        do {
            try catalog.createExpression(expression)
            sequence?.yield(.createdExpression(expression))
        } catch CatalogError.expressionExistingWithKey(_, let existing) {
            sequence?.yield(.skippedExpression(existing))
            importTranslations(expression.replacingId(existing.id), into: catalog)
        } catch {
            sequence?.yield(.failedExpression(expression, error))
        }
    }
    
    private func importTranslations(_ expression: Expression, into catalog: Catalog) {
        guard let id = try? catalog.expression(matching: GenericExpressionQuery.key(expression.key)).id else {
            return
        }
        
        expression
            .translations
            .sorted(by: { $0.value < $1.value })
            .forEach { translation in
                var t = translation
                t.expressionID = id
                importTranslation(t, into: catalog)
            }
    }
    
    private func importTranslation(_ translation: Translation, into catalog: Catalog) {
        do {
            try catalog.createTranslation(translation)
            sequence?.yield(.createdTranslation(translation))
        } catch CatalogError.translationExistingWithValue {
            sequence?.yield(.skippedTranslation(translation))
        } catch {
            sequence?.yield(.failedTranslation(translation, error))
        }
    }
}
