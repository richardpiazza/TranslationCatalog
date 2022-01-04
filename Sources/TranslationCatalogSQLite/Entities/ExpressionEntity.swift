import Statement
import TranslationCatalog
import LocaleSupport
import Foundation

struct ExpressionEntity: Entity {
    
    let tableName: String = "expression"
    
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
    static var id: Attribute { Self["id"]! }
    static var uuid: Attribute { Self["uuid"]! }
    static var key: Attribute { Self["key"]! }
    static var name: Attribute { Self["name"]! }
    static var defaultLanguage: Attribute { Self["default_language"]! }
    static var context: Attribute { Self["context"]! }
    static var feature: Attribute { Self["feature"]! }
    
    init(_ expression: Expression) {
        uuid = expression.uuid.uuidString
        key = expression.key
        name = expression.name
        defaultLanguage = expression.defaultLanguage.rawValue
        context = expression.context
        feature = expression.feature
    }
    
    func expression(with translations: [TranslationCatalog.Translation] = []) throws -> Expression {
        guard let id = UUID(uuidString: uuid) else {
            throw SQLiteCatalog.Error.unhandledConversion
        }
        guard let languageCode = LanguageCode(rawValue: defaultLanguage) else {
            throw SQLiteCatalog.Error.unhandledConversion
        }
        
        return Expression(uuid: id, key: key, name: name, defaultLanguage: languageCode, context: context, feature: feature, translations: translations)
    }
}
