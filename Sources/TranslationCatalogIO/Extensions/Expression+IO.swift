import Foundation
import LocaleSupport
import TranslationCatalog
import Plot

extension TranslationCatalog.Expression {
    func replacingId(_ id: TranslationCatalog.Expression.ID) -> TranslationCatalog.Expression {
        Expression(
            id: id,
            key: key,
            name: name,
            defaultLanguage: defaultLanguage,
            context: context,
            feature: feature,
            translations: translations.map { Translation(translation: $0, expressionId: id) }
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
            
            return Expression(
                id: expression.id,
                key: expression.key,
                name: expression.name,
                defaultLanguage: expression.defaultLanguage,
                context: expression.context,
                feature: expression.feature,
                translations: [translation]
            )
        }
    }
}
