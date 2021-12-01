import Statement
import TranslationCatalog
import LocaleSupport
import Foundation

struct TranslationEntity: Table {
    
    enum CodingKeys: String, CodingKey {
        case id
        case uuid
        case expressionID = "expression_id"
        case language = "language_code"
        case script = "script_code"
        case region = "region_code"
        case value
    }
    
    static var schema: Schema = { TranslationEntity().schema }()
    static var id: AnyColumn { schema.columns[0] }
    static var uuid: AnyColumn { schema.columns[1] }
    static var expressionID: AnyColumn { schema.columns[2] }
    static var language: AnyColumn { schema.columns[3] }
    static var script: AnyColumn { schema.columns[4] }
    static var region: AnyColumn { schema.columns[5] }
    static var value: AnyColumn { schema.columns[6] }
    private var schema: Schema { Schema(name: "translation", columns: [_id, _uuid, _expressionID, _language, _script, _region, _value]) }
    
    @Column(table: TranslationEntity.self, name: CodingKeys.id.rawValue, dataType: "INTEGER", notNull: true, unique: true, primaryKey: true, autoIncrement: true)
    var id: Int = 0
    @Column(table: TranslationEntity.self, name: CodingKeys.uuid.rawValue, dataType: "TEXT", notNull: true, unique: true)
    var uuid: String = ""
    @Column(table: TranslationEntity.self, name: CodingKeys.expressionID.rawValue, dataType: "INTEGER", notNull: true, foreignKey: ExpressionEntity.id)
    var expressionID: Int = 0
    @Column(table: TranslationEntity.self, name: CodingKeys.language.rawValue, dataType: "TEXT", notNull: true)
    var language: String = ""
    @Column(table: TranslationEntity.self, name: CodingKeys.script.rawValue, dataType: "TEXT")
    var script: String? = nil
    @Column(table: TranslationEntity.self, name: CodingKeys.region.rawValue, dataType: "TEXT")
    var region: String? = nil
    @Column(table: TranslationEntity.self, name: CodingKeys.value.rawValue, dataType: "TEXT", notNull: true)
    var value: String = ""
}

extension TranslationEntity {
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
