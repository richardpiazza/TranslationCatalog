import TranslationCatalog

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
