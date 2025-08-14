import Foundation
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
        uuid: TranslationCatalog.Expression.ID,
        defaultLanguage: Locale.LanguageCode,
        comment: String? = nil,
        feature: String? = nil,
        language: Locale.LanguageCode,
        script: Locale.Script? = nil,
        region: Locale.Region? = nil
    ) -> TranslationCatalog.Expression {
        if defaultLanguage == language, script == nil, region == nil {
            TranslationCatalog.Expression(
                id: uuid,
                key: name,
                value: value,
                languageCode: defaultLanguage,
                name: name,
                context: comment,
                feature: feature
            )
        } else {
            TranslationCatalog.Expression(
                id: uuid,
                key: name,
                value: "",
                languageCode: defaultLanguage,
                name: name,
                context: comment,
                feature: feature,
                translations: [
                    Translation(
                        id: .zero,
                        expressionId: uuid,
                        value: value,
                        language: language,
                        script: script,
                        region: region,
                        state: .new
                    ),
                ]
            )
        }
    }
}
