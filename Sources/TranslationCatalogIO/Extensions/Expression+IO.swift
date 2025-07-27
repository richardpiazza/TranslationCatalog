import Foundation
import LocaleSupport
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

    @available(*, deprecated, renamed: "compactMap(locale:fallback:)")
    func compactMap(
        locale: Locale?,
        defaultOrFirst: Bool
    ) -> [TranslationCatalog.Expression] {
        compactMap { expression -> TranslationCatalog.Expression? in
            let translation = defaultOrFirst ? expression.translationOrDefaultOrFirst(with: locale) : expression.translation(with: locale)
            guard let translation else {
                return nil
            }

            return Expression(
                id: expression.id,
                key: expression.key,
                name: expression.name,
                defaultLanguageCode: expression.defaultLanguageCode,
                context: expression.context,
                feature: expression.feature,
                translations: [translation]
            )
        }
    }

    @available(*, deprecated, renamed: "compactMap(locale:defaultOrFirst:)")
    func compactMap(localeIdentifier: Locale.Identifier?, defaultOrFirst: Bool) -> [TranslationCatalog.Expression] {
        compactMap { expression -> TranslationCatalog.Expression? in
            let translation = defaultOrFirst ? expression.translationOrDefaultOrFirst(with: localeIdentifier) : expression.translation(with: localeIdentifier)
            guard let translation else {
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
