import Foundation
import Plot
import TranslationCatalog

extension TranslationCatalog.Expression {
    func replacingId(_ id: TranslationCatalog.Expression.ID) -> TranslationCatalog.Expression {
        Expression(
            id: id,
            key: key,
            value: defaultValue,
            languageCode: defaultLanguageCode,
            name: name,
            context: context,
            feature: feature,
            translations: translations.map { Translation(translation: $0, expressionId: id) }
        )
    }
}

extension [TranslationCatalog.Expression] {
    /// Has value for the `locale` or should fallback
    func compactMap(
        locale: Locale,
        fallback: Bool
    ) -> [TranslationCatalog.Expression] {
        compactMap { expression -> TranslationCatalog.Expression? in
            if expression.value(for: locale) != nil || fallback {
                return expression
            } else {
                return nil
            }
        }
    }
}
