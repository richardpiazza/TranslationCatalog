import TranslationCatalog

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

extension Translation {
    func replacingExpressionId(_ id: Expression.ID) -> Translation {
        return Translation(
            uuid: uuid,
            expressionID: id,
            languageCode: languageCode,
            scriptCode: scriptCode,
            regionCode: regionCode,
            value: value
        )
    }
}
