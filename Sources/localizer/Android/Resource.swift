import XMLCoder
import LocaleSupport
import TranslationCatalog

public struct Resource: Decodable, DynamicNodeDecoding {
    enum CodingKeys: String, CodingKey {
        case name
        case value = ""
    }
    
    public var name: String
    public var value: String
    
    public static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        switch key {
        case CodingKeys.name:
            return .attribute
        case CodingKeys.value:
            return .element
        default:
            return .elementOrAttribute
        }
    }
}

public extension Resource {
    func expression(
        uuid: Expression.ID,
        defaultLanguage: LanguageCode = .default,
        comment: String? = nil,
        feature: String? = nil,
        language: LanguageCode,
        script: ScriptCode? = nil,
        region: RegionCode? = nil
    ) -> Expression {
        var expression = Expression(
            uuid: uuid,
            key: name,
            name: name,
            defaultLanguage: defaultLanguage,
            context: comment,
            feature: feature)
        expression.translations = [
            Translation(uuid: .zero, expressionID: uuid, languageCode: language, scriptCode: script, regionCode: region, value: value)
        ]
        return expression
    }
}
