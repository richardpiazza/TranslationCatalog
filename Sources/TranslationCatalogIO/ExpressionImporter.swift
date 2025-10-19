import Foundation
import TranslationCatalog

public class ExpressionImporter {

    public enum Operation: CustomStringConvertible {
        case createdExpression(TranslationCatalog.Expression)
        case skippedExpression(TranslationCatalog.Expression)
        case failedExpression(TranslationCatalog.Expression, any Error)
        case createdTranslation(Translation)
        case skippedTranslation(Translation)
        case failedTranslation(Translation, any Error)

        public var description: String {
            switch self {
            case .createdExpression(let expression):
                "Expression Created '\(expression.key)'"
            case .skippedExpression(let expression):
                "Expression Exists with Key '\(expression.key)'"
            case .failedExpression(let expression, let error):
                "Expression Failure '\(expression.key)'; \(error.localizedDescription)"
            case .createdTranslation(let translation):
                "Translation Created '\(translation.value)'"
            case .skippedTranslation(let translation):
                "Translation Skipped '\(translation.value)'"
            case .failedTranslation(let translation, let error):
                "Translation Failure '\(translation.value)'; \(error.localizedDescription)"
            }
        }
    }

    private let catalog: any Catalog
    private let sequence = AsyncStream.makeStream(of: Operation.self)

    public init(catalog: any Catalog) {
        self.catalog = catalog
    }

    public func importTranslations(
        from expressions: [TranslationCatalog.Expression]
    ) async -> AsyncStream<Operation> {
        defer {
            importExpressions(expressions)
        }

        return sequence.stream
    }

    private func importExpressions(_ expressions: [TranslationCatalog.Expression]) {
        let sortedExpressions = expressions.sorted(by: { $0.key < $1.key })
        for expression in sortedExpressions {
            importExpression(expression, into: catalog)
        }

        sequence.continuation.finish()
    }

    private func importExpression(_ expression: TranslationCatalog.Expression, into catalog: any Catalog) {
        do {
            try catalog.createExpression(expression)
            sequence.continuation.yield(.createdExpression(expression))
        } catch CatalogError.expressionExistingWithKey(_, let existing) {
            sequence.continuation.yield(.skippedExpression(existing))
            importTranslations(expression.replacingId(existing.id), into: catalog)
        } catch {
            sequence.continuation.yield(.failedExpression(expression, error))
        }
    }

    private func importTranslations(_ expression: TranslationCatalog.Expression, into catalog: any Catalog) {
        guard let id = try? catalog.expression(matching: GenericExpressionQuery.key(expression.key)).id else {
            return
        }

        let translations = expression.translations.sorted(by: { $0.value < $1.value })
        for translation in translations {
            let expressionTranslation = Translation(
                translation: translation,
                expressionId: id
            )
            importTranslation(expressionTranslation, into: catalog)
        }
    }

    private func importTranslation(_ translation: Translation, into catalog: any Catalog) {
        do {
            try catalog.createTranslation(translation)
            sequence.continuation.yield(.createdTranslation(translation))
        } catch CatalogError.translationExistingWithValue {
            sequence.continuation.yield(.skippedTranslation(translation))
        } catch {
            sequence.continuation.yield(.failedTranslation(translation, error))
        }
    }
}
