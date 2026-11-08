import TranslationCatalog

public extension KeyHierarchy {
    static func make(with expressions: [TranslationCatalog.Expression]) throws -> KeyHierarchy {
        let localizationKeys = try expressions
            .map {
                try AnyAnnotatedLocalizationReference(
                    key: $0.key,
                    value: $0.defaultValue.encodingDarwinStrings(),
                    comment: $0.context,
                )
            }

        return try make(with: localizationKeys)
    }
}
