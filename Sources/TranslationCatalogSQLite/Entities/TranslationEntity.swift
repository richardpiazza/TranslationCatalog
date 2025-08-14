import Foundation
import Statement
import TranslationCatalog

struct TranslationEntity: Entity {

    static let identifier: String = "translation"

    @Field("id", unique: true, primaryKey: true, autoIncrement: true)
    var id: Int = 0
    @Field("uuid", unique: true)
    var uuid: String = ""
    @Field("expression_id", foreignKey: ForeignKey(ExpressionEntity.self, "id"))
    var expressionID: Int = 0
    @Field("language_code")
    var language: String = ""
    @Field("script_code")
    var script: String? = nil
    @Field("region_code")
    var region: String? = nil
    @Field("value")
    var value: String = ""
    @Field("state_raw_value")
    var stateRawValue: String = ""
}

extension TranslationEntity {
    static let entity = TranslationEntity()
    static var id: Attribute { entity["id"]! }
    static var uuid: Attribute { entity["uuid"]! }
    static var expressionID: Attribute { entity["expression_id"]! }
    static var language: Attribute { entity["language_code"]! }
    static var script: Attribute { entity["script_code"]! }
    static var region: Attribute { entity["region_code"]! }
    static var value: Attribute { entity["value"]! }
    static var stateRawValue: Attribute { entity["state_raw_value"]! }

    init(_ translation: TranslationCatalog.Translation) {
        uuid = translation.id.uuidString
        language = translation.language.identifier
        script = translation.script?.identifier
        region = translation.region?.identifier
        value = translation.value
        stateRawValue = translation.state.rawValue
    }

    func translation(with expressionID: String) throws -> TranslationCatalog.Translation {
        guard let id = UUID(uuidString: uuid) else {
            throw CatalogError.dataTypeConversion("Invalid UUID '\(uuid)'")
        }
        guard let foreignID = UUID(uuidString: expressionID) else {
            throw CatalogError.dataTypeConversion("Invalid UUID '\(expressionID)'")
        }

        return TranslationCatalog.Translation(
            id: id,
            expressionId: foreignID,
            value: value,
            language: languageCode,
            script: scriptCode,
            region: regionCode,
            state: state
        )
    }
}

extension TranslationEntity {
    var languageCode: Locale.LanguageCode {
        Locale.LanguageCode(language)
    }

    var scriptCode: Locale.Script? {
        guard let script else {
            return nil
        }

        return Locale.Script(script)
    }

    var regionCode: Locale.Region? {
        guard let region else {
            return nil
        }

        return Locale.Region(region)
    }

    var state: TranslationState {
        TranslationState(stringLiteral: stateRawValue)
    }
}
