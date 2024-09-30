import Foundation
import LocaleSupport
import TranslationCatalog
import Plot

extension TranslationCatalog.Expression {
    func replacingId(_ id: TranslationCatalog.Expression.ID) -> TranslationCatalog.Expression {
        let translations = self.translations.map { $0.replacingExpressionId(id) }
        
        return Expression(
            uuid: id,
            key: key,
            name: name,
            defaultLanguage: defaultLanguage,
            context: context,
            feature: feature,
            translations: translations
        )
    }
}

extension Array where Element == TranslationCatalog.Expression {
    func compactMap(localeIdentifier: Locale.Identifier?, defaultOrFirst: Bool) -> [TranslationCatalog.Expression] {
        self.compactMap { expression -> TranslationCatalog.Expression? in
            let translation = defaultOrFirst ? expression.translationOrDefaultOrFirst(with: localeIdentifier) : expression.translation(with: localeIdentifier)
            guard let translation = translation else {
                return nil
            }
            
            var mappedExpression = expression
            mappedExpression.translations = [translation]
            return mappedExpression
        }
    }
}
