import Foundation
@testable import TranslationCatalog

extension Translation {
    static let translation1 = TranslationCatalog.Translation(
        id: .translation1,
        expressionId: .expression1,
        value: "Save",
        language: .english,
        script: nil,
        region: .unitedKingdom,
        state: .translated
    )
    static let translation2 = TranslationCatalog.Translation(
        id: .translation2,
        expressionId: .expression1,
        value: "Guardar",
        language: .spanish,
        script: nil,
        region: nil,
        state: .translated
    )
    static let translation3 = TranslationCatalog.Translation(
        id: .translation3,
        expressionId: .expression1,
        value: "Sauvegarder",
        language: .french,
        script: nil,
        region: nil,
        state: .needsReview
    )
    static let translation4 = TranslationCatalog.Translation(
        id: .translation4,
        expressionId: .expression2,
        value: "Delete",
        language: .english,
        script: nil,
        region: .unitedKingdom,
        state: .translated
    )
    static let translation5 = TranslationCatalog.Translation(
        id: .translation5,
        expressionId: .expression2,
        value: "Eliminar",
        language: .spanish,
        script: nil,
        region: nil,
        state: .translated
    )
    static let translation6 = TranslationCatalog.Translation(
        id: .translation6,
        expressionId: .expression2,
        value: "Effacer",
        language: .french,
        script: nil,
        region: nil,
        state: .needsReview
    )
    static let translation7 = TranslationCatalog.Translation(
        id: .translation7,
        expressionId: .expression3,
        value: "Pull to Refresh",
        language: .english,
        script: nil,
        region: .unitedKingdom,
        state: .translated
    )
    static let translation8 = TranslationCatalog.Translation(
        id: .translation8,
        expressionId: .expression3,
        value: "拉刷新",
        language: .chinese,
        script: .hanSimplified,
        region: nil,
        state: .needsReview
    )
    static let translation9 = TranslationCatalog.Translation(
        id: .translation9,
        expressionId: .expression3,
        value: "Puxe para Atualizar",
        language: .portuguese,
        script: nil,
        region: .brazil,
        state: .needsReview
    )
    static let translation10 = TranslationCatalog.Translation(
        id: .translation10,
        expressionId: .expression4,
        value: "Fully Qualified Domain Name",
        language: .english,
        script: nil,
        region: .unitedKingdom,
        state: .translated
    )
    static let translation11 = TranslationCatalog.Translation(
        id: .translation11,
        expressionId: .expression5,
        value: "The server '%@' rejected the provided credentials.",
        language: .english,
        script: nil,
        region: .unitedKingdom,
        state: .translated
    )
    static let translation12 = TranslationCatalog.Translation(
        id: .translation12,
        expressionId: .expression5,
        value: "Le serveur '%@' a rejeté les informations d'identification fournies.",
        language: .french,
        script: nil,
        region: nil,
        state: .needsReview
    )
    static let translation13 = TranslationCatalog.Translation(
        id: .translation13,
        expressionId: .expression5,
        value: "Le serveur '%@' a rejeté les informations d'identification fournies, eh.",
        language: .french,
        script: nil,
        region: .canada,
        state: .needsReview
    )
    static let translation14 = TranslationCatalog.Translation(
        id: .translation14,
        expressionId: .expression1,
        value: "sauver",
        language: .french,
        script: nil,
        region: .canada,
        state: .needsReview
    )
    static let translation15 = TranslationCatalog.Translation(
        id: .translation15,
        expressionId: .expression1,
        value: "Guardar",
        language: .portuguese,
        script: nil,
        region: .brazil,
        state: .needsReview
    )
    static let translation16 = TranslationCatalog.Translation(
        id: .translation16,
        expressionId: .expression1,
        value: "保存",
        language: .chinese,
        script: .hanSimplified,
        region: nil,
        state: .needsReview
    )
}
