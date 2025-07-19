import Foundation
import TranslationCatalog

struct ExpressionDocument: Document {
    let id: UUID
    var key: String
    var name: String
    var defaultLanguage: Locale.LanguageCode
    var context: String?
    var feature: String?
}

extension TranslationCatalog.Expression {
    init(document: ExpressionDocument, translations: [Translation]) {
        self.init(
            id: document.id,
            key: document.key,
            name: document.name,
            defaultLanguageCode: document.defaultLanguage,
            context: document.context,
            feature: document.feature,
            translations: translations
        )
    }
}
