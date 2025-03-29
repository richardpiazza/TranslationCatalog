import Statement
import TranslationCatalog
import LocaleSupport
import Foundation

struct ExpressionEntity: Entity {
    
    static let identifier: String = "expression"
    
    @Field("id", unique: true, primaryKey: true, autoIncrement: true)
    var id: Int = 0
    @Field("uuid", unique: true)
    var uuid: String = ""
    @Field("key")
    var key: String = ""
    @Field("name")
    var name: String = ""
    @Field("default_language")
    var defaultLanguage: String = ""
    @Field("context")
    var context: String? = nil
    @Field("feature")
    var feature: String? = nil
}

extension ExpressionEntity {
    static let entity = ExpressionEntity()
    static var id: Attribute { entity["id"]! }
    static var uuid: Attribute { entity["uuid"]! }
    static var key: Attribute { entity["key"]! }
    static var name: Attribute { entity["name"]! }
    static var defaultLanguage: Attribute { entity["default_language"]! }
    static var context: Attribute { entity["context"]! }
    static var feature: Attribute { entity["feature"]! }
    
    init(_ expression: TranslationCatalog.Expression) {
        uuid = expression.id.uuidString
        key = expression.key
        name = expression.name
        defaultLanguage = expression.defaultLanguage.rawValue
        context = expression.context
        feature = expression.feature
    }
    
    func expression(with translations: [TranslationCatalog.Translation] = []) throws -> TranslationCatalog.Expression {
        guard let id = UUID(uuidString: uuid) else {
            throw CatalogError.dataTypeConversion("Invalid UUID '\(uuid)'")
        }
        guard let languageCode = LanguageCode(rawValue: defaultLanguage) else {
            throw CatalogError.dataTypeConversion("Invalid LangaugeCode '\(defaultLanguage)'")
        }
        
        return Expression(id: id, key: key, name: name, defaultLanguage: languageCode, context: context, feature: feature, translations: translations)
    }
}
