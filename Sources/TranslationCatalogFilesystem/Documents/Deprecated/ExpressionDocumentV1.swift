import Foundation
import TranslationCatalog

struct ExpressionDocumentV1: Document {
    let id: UUID
    var key: String
    var name: String
    var defaultLanguage: Locale.LanguageCode
    var context: String?
    var feature: String?
}
