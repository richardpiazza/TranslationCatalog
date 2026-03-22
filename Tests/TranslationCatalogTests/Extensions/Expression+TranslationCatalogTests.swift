import Foundation
@testable import TranslationCatalog

extension TranslationCatalog.Expression {
    static let expression1 = Expression(
        id: .expression1,
        key: "BUTTON_SAVE",
        value: "Save",
        languageCode: .english,
        context: "Button/Action Title",
        feature: "Buttons",
        translations: [
            .translation1,
            .translation2,
            .translation3,
            .translation14,
            .translation15,
            .translation16,
        ]
    )
    static let expression2 = Expression(
        id: .expression2,
        key: "BUTTON_DELETE",
        value: "Delete",
        languageCode: .english,
        context: "Button/Action Title",
        feature: "Buttons",
        translations: [
            .translation4,
            .translation5,
            .translation6,
        ]
    )
    static let expression3 = Expression(
        id: .expression3,
        key: "COMMON_PULL_TO_REFRESH",
        value: "Pull to Refresh",
        languageCode: .english,
        name: "Pull to Refresh",
        context: "Manual Refresh Action",
        feature: "Common",
        translations: [
            .translation7,
            .translation8,
            .translation9,
        ]
    )
    static let expression4 = Expression(
        id: .expression4,
        key: "GIT_FQDN",
        value: "Fully Qualified Domain Name",
        languageCode: .english,
        name: "Fully Qualified Domain Name",
        context: "Test Entry Prompt",
        feature: "Git,Internet",
        translations: [
            .translation10,
        ]
    )
    static let expression5 = Expression(
        id: .expression5,
        key: "AUTH_FAILURE_MESSAGE",
        value: "The server '%@' rejected the provided credentials.",
        languageCode: .english,
        name: "Authentication Failure Message",
        context: "Authentication Alert Message",
        feature: "Alert,Auth",
        translations: [
            .translation11,
            .translation12,
            .translation13,
        ]
    )
}
