import Foundation
import TranslationCatalog
import XMLCoder

struct Resource: Codable, DynamicNodeDecoding, DynamicNodeEncoding {
    enum CodingKeys: String, CodingKey {
        case name
        case formatted
        case value = ""
    }

    var name: String
    var value: String
    var formatted: Bool?

    static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        switch key {
        case CodingKeys.name, CodingKeys.formatted:
            .attribute
        case CodingKeys.value:
            .element
        default:
            .elementOrAttribute
        }
    }
    
    static func nodeEncoding(for key: any CodingKey) -> XMLEncoder.NodeEncoding {
        switch key {
        case CodingKeys.name, CodingKeys.formatted:
            .attribute
        case CodingKeys.value:
            .element
        default:
            .both
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
