import TranslationCatalog
import Plot

extension Expression {
    func replacingId(_ id: Expression.ID) -> Expression {
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
