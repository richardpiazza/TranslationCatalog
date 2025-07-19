import Foundation
import TranslationCatalog

struct TranslationDocument: Document {
    let id: UUID
    let expressionID: ExpressionDocument.ID
    var languageCode: Locale.LanguageCode
    var scriptCode: Locale.Script?
    var regionCode: Locale.Region?
    var value: String
}

extension Translation {
    init(document: TranslationDocument) {
        self.init(
            id: document.id,
            expressionId: document.expressionID,
            language: document.languageCode,
            script: document.scriptCode,
            region: document.regionCode,
            value: document.value
        )
    }
}
