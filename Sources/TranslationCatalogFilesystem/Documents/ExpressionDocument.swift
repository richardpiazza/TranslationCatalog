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

    var locale: Locale { Locale(languageCode: defaultLanguage) }
}

extension TranslationCatalog.Expression {
    init(document: ExpressionDocument, translations: [Translation]) {
        self.init(
            id: document.id,
            key: document.key,
            name: document.name,
            defaultLanguageCode: document.defaultLanguage,
            defaultValue: document.defaultValue,
            context: document.context,
            feature: document.feature,
            translations: translations
        )
    }
}
