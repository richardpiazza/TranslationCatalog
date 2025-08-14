import Foundation
import TranslationCatalog

struct TranslationDocument: Document {
    let id: UUID
    let expressionID: ExpressionDocument.ID
    var value: String
    var languageCode: Locale.LanguageCode
    var scriptCode: Locale.Script?
    var regionCode: Locale.Region?
    var state: TranslationState
}

extension Translation {
    init(document: TranslationDocument) {
        self.init(
            id: document.id,
            expressionId: document.expressionID,
            value: document.value,
            language: document.languageCode,
            script: document.scriptCode,
            region: document.regionCode,
            state: document.state
        )
    }
}
