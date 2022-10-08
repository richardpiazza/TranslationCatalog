import Statement
import TranslationCatalog
import LocaleSupport
import Foundation

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
    
    init(_ translation: TranslationCatalog.Translation) {
        uuid = translation.uuid.uuidString
        language = translation.languageCode.rawValue
        script = translation.scriptCode?.rawValue
        region = translation.regionCode?.rawValue
        value = translation.value
    }
    
    func translation(with expressionID: String) throws -> TranslationCatalog.Translation {
        guard let id = UUID(uuidString: uuid) else {
            throw SQLiteCatalog.Error.unhandledConversion
        }
        guard let foreignID = UUID(uuidString: expressionID) else {
            throw SQLiteCatalog.Error.unhandledConversion
        }
        guard let languageCode = LanguageCode(rawValue: language) else {
            throw SQLiteCatalog.Error.unhandledConversion
        }
        
        let scriptCode: ScriptCode?
        if let script = script {
            guard let code = ScriptCode(rawValue: script) else {
                throw SQLiteCatalog.Error.unhandledConversion
            }
            scriptCode = code
        } else {
            scriptCode = nil
        }
        
        let regionCode: RegionCode?
        if let region = region {
            guard let code = RegionCode(rawValue: region) else {
                throw SQLiteCatalog.Error.unhandledConversion
            }
            regionCode = code
        } else {
            regionCode = nil
        }
        
        return TranslationCatalog.Translation(uuid: id, expressionID: foreignID, languageCode: languageCode, scriptCode: scriptCode, regionCode: regionCode, value: value)
    }
}
