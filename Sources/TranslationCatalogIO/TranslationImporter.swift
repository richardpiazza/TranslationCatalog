import Foundation
import AsyncPlus
import LocaleSupport
import TranslationCatalog

public class TranslationImporter {
    
    private let catalog: Catalog
    
    private var sequence: PassthroughAsyncThrowingSequence<CatalogIOOperation>?
    var stream: AsyncThrowingStream<CatalogIOOperation, Error> {
        sequence?.finish()
        let sequence = PassthroughAsyncThrowingSequence<CatalogIOOperation>()
        self.sequence = sequence
        return sequence.stream
    }
    
    public init(catalog: Catalog) {
        self.catalog = catalog
    }
    
    public func importTranslations(
        from expressions: [Expression]
    ) -> AsyncThrowingStream<CatalogIOOperation, Error> {
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
    
    private func importExpression(_ expression: Expression, into catalog: TranslationCatalog.Catalog) {
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
    
    private func importTranslations(_ expression: Expression, into catalog: TranslationCatalog.Catalog) {
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
    
    private func importTranslation(_ translation: TranslationCatalog.Translation, into catalog: TranslationCatalog.Catalog) {
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
