import Foundation
import TranslationCatalog

struct TranslationDocumentV1: Document {
    let id: UUID
    let expressionID: ExpressionDocument.ID
    var languageCode: Locale.LanguageCode
    var scriptCode: Locale.Script?
    var regionCode: Locale.Region?
    var value: String
}
