import Foundation
import TranslationCatalog

struct ExpressionDocument: Document {
    let id: UUID
    var key: String
    var name: String
    var defaultLanguage: Locale.LanguageCode
    var defaultValue: String
    var context: String?
    var feature: String?
    
    init(
        id: UUID,
        key: String,
        name: String,
        defaultLanguage: Locale.LanguageCode,
        defaultValue: String,
        context: String? = nil,
        feature: String? = nil
    ) {
        self.id = id
        self.key = key
        self.name = name
        self.defaultLanguage = defaultLanguage
        self.defaultValue = defaultValue
        self.context = context
        self.feature = feature
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.key = try container.decode(String.self, forKey: .key)
        self.name = try container.decode(String.self, forKey: .name)
        self.defaultLanguage = try container.decode(Locale.LanguageCode.self, forKey: .defaultLanguage)
        self.defaultValue = try container.decodeIfPresent(String.self, forKey: .defaultValue) ?? ""
        self.context = try container.decodeIfPresent(String.self, forKey: .context)
        self.feature = try container.decodeIfPresent(String.self, forKey: .feature)
    }
    
    var locale: Locale { Locale(languageCode: defaultLanguage) }
}

extension TranslationCatalog.Expression {
    init(document: ExpressionDocument, translations: [Translation]) {
        var value = ""
        var filteredTranslations: [Translation] = translations
        
        if !document.defaultValue.isEmpty {
            value = document.defaultValue
        } else if let index = filteredTranslations.firstIndex(where: { $0.locale == document.locale }) {
            let translation = filteredTranslations.remove(at: index)
            value = translation.value
        }
        
        self.init(
            id: document.id,
            key: document.key,
            name: document.name,
            defaultLanguageCode: document.defaultLanguage,
            defaultValue: value,
            context: document.context,
            feature: document.feature,
            translations: filteredTranslations
        )
    }
}
