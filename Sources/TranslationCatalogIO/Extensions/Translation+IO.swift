import TranslationCatalog

extension Translation {
    @available(*, deprecated, message: "Use `Translation(translation:expressionId:)")
    func replacingExpressionId(_ id: Expression.ID) -> Translation {
        Translation(
            uuid: uuid,
            expressionID: id,
            languageCode: languageCode,
            scriptCode: scriptCode,
            regionCode: regionCode,
            value: value
        )
    }
}
