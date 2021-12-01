import Statement
import TranslationCatalog
import LocaleSupport
import Foundation

struct ExpressionEntity: Table {
    
    enum CodingKeys: String, CodingKey {
        case id
        case uuid
        case key
        case name
        case defaultLanguage = "default_language"
        case context
        case feature
    }
    
    static var schema: Schema = { ExpressionEntity().schema }()
    static var id: AnyColumn { schema.columns[0] }
    static var uuid: AnyColumn { schema.columns[1] }
    static var key: AnyColumn { schema.columns[2] }
    static var name: AnyColumn { schema.columns[3] }
    static var defaultLanguage: AnyColumn { schema.columns[4] }
    static var context: AnyColumn { schema.columns[5] }
    static var feature: AnyColumn { schema.columns[6] }
    private var schema: Schema { Schema(name: "expression", columns: [_id, _uuid, _key, _name, _defaultLanguage, _context, _feature]) }
    
    @Column(table: ExpressionEntity.self, name: CodingKeys.id.rawValue, dataType: "INTEGER", notNull: true, unique: true, primaryKey: true, autoIncrement: true)
    var id: Int = 0
    @Column(table: ExpressionEntity.self, name: CodingKeys.uuid.rawValue, dataType: "TEXT", notNull: true, unique: true)
    var uuid: String = ""
    @Column(table: ExpressionEntity.self, name: CodingKeys.key.rawValue, dataType: "TEXT", notNull: true)
    var key: String = ""
    @Column(table: ExpressionEntity.self, name: CodingKeys.name.rawValue, dataType: "TEXT", notNull: true)
    var name: String = ""
    @Column(table: ExpressionEntity.self, name: CodingKeys.defaultLanguage.rawValue, dataType: "TEXT", notNull: true)
    var defaultLanguage: String = ""
    @Column(table: ExpressionEntity.self, name: CodingKeys.context.rawValue, dataType: "TEXT")
    var context: String? = nil
    @Column(table: ExpressionEntity.self, name: CodingKeys.feature.rawValue, dataType: "TEXT")
    var feature: String? = nil
}

extension ExpressionEntity {
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
