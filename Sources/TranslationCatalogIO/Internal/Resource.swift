import LocaleSupport
import TranslationCatalog
import XMLCoder

struct Resource: Decodable, DynamicNodeDecoding {
    enum CodingKeys: String, CodingKey {
        case name
        case value = ""
    }

    var name: String
    var value: String

    static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        switch key {
        case CodingKeys.name:
            .attribute
        case CodingKeys.value:
            .element
        default:
            .elementOrAttribute
        }
    }
}

extension Resource {
    func expression(
        uuid: Expression.ID,
        defaultLanguage: LanguageCode = .default,
        comment: String? = nil,
        feature: String? = nil,
        language: LanguageCode,
        script: ScriptCode? = nil,
        region: RegionCode? = nil
    ) -> Expression {
        Expression(
            id: uuid,
            key: name,
            name: name,
            defaultLanguage: defaultLanguage,
            context: comment,
            feature: feature,
            translations: [
                Translation(
                    id: .zero,
                    expressionId: uuid,
                    languageCode: language,
                    scriptCode: script,
                    regionCode: region,
                    value: value
                ),
            ]
        )
    }
}
