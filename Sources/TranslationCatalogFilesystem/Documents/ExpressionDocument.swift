import Foundation
import TranslationCatalog
import LocaleSupport

struct ExpressionDocument: Document {
    let id: UUID
    var key: String
    var name: String
    var defaultLanguage: LanguageCode
    var context: String?
    var feature: String?
    var translationIds: [TranslationDocument.ID]
}

extension Expression {
    init(document: ExpressionDocument, translations: [Translation]) {
        self.init(
            uuid: document.id,
            key: document.key,
            name: document.name,
            defaultLanguage: document.defaultLanguage,
            context: document.context,
            feature: document.feature,
            translations: translations
        )
    }
}
