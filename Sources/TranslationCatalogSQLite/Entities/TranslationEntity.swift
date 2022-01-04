import Statement
import TranslationCatalog
import LocaleSupport
import Foundation

struct TranslationEntity: Entity {
    
    let tableName: String = "translation"
    
    @Field("id", unique: true, primaryKey: true, autoIncrement: true)
    var id: Int = 0
    @Field("uuid", unique: true)
    var uuid: String = ""
    @Field("expression_id", foreignKey: ForeignKey("expression", "id"))
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
    static var id: Attribute { Self["id"]! }
    static var uuid: Attribute { Self["uuid"]! }
    static var expressionID: Attribute { Self["expression_id"]! }
    static var language: Attribute { Self["language_code"]! }
    static var script: Attribute { Self["script_code"]! }
    static var region: Attribute { Self["region_code"]! }
    static var value: Attribute { Self["value"]! }
    
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
