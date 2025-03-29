import Foundation
import TranslationCatalog
import LocaleSupport

struct TranslationDocument: Document {
    let id: UUID
    let expressionID: ExpressionDocument.ID
    var languageCode: LanguageCode
    var scriptCode: ScriptCode?
    var regionCode: RegionCode?
    var value: String
}

extension Translation {
    init(document: TranslationDocument) {
        self.init(
            id: document.id,
            expressionId: document.expressionID,
            languageCode: document.languageCode,
            scriptCode: document.scriptCode,
            regionCode: document.regionCode,
            value: document.value
        )
    }
}

extension TranslationDocument: LocaleRepresentable {}
