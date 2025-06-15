import Foundation
import LocaleSupport

/// A specific language/region variation of an `Expression`.
public struct Translation: Codable, Hashable, Identifiable, LocaleRepresentable, Sendable {
    /// Identifier that universally identifies this `Translation`
    public let id: UUID
    /// Identifier of the `Expression` that contains this `Translation`
    public let expressionId: Expression.ID
    /// The primary `LanguageCode` of the translated `value`
    public let languageCode: LanguageCode
    /// `ScriptCode` that provides precise dialect differentiation.
    public let scriptCode: ScriptCode?
    /// `RegionCode` that classifies a regional usage of the language.
    public let regionCode: RegionCode?
    /// The translated value
    public let value: String

    public init(
        id: UUID = .zero,
        expressionId: Expression.ID = .zero,
        languageCode: LanguageCode = .default,
        scriptCode: ScriptCode? = nil,
        regionCode: RegionCode? = nil,
        value: String = ""
    ) {
        self.id = id
        self.expressionId = expressionId
        self.languageCode = languageCode
        self.scriptCode = scriptCode
        self.regionCode = regionCode
        self.value = value
    }

    /// Convenience initializer to assigns all values from the provided `Translation`,
    /// while overriding the `Expression.ID`.
    public init(
        translation: Translation,
        expressionId: Expression.ID
    ) {
        id = translation.id
        self.expressionId = expressionId
        languageCode = translation.languageCode
        scriptCode = translation.scriptCode
        regionCode = translation.regionCode
        value = translation.value
    }
}

public extension Translation {
    @available(*, deprecated, renamed: "id")
    var uuid: UUID { id }

    @available(*, deprecated, renamed: "expressionId")
    var expressionID: Expression.ID { expressionId }

    @available(*, deprecated, renamed: "init(id:expressionId:languageCode:scriptCode:regionCode:value:)")
    init(
        uuid: UUID,
        expressionID: Expression.ID = .zero,
        languageCode: LanguageCode = .default,
        scriptCode: ScriptCode? = nil,
        regionCode: RegionCode? = nil,
        value: String = ""
    ) {
        id = uuid
        expressionId = expressionID
        self.languageCode = languageCode
        self.scriptCode = scriptCode
        self.regionCode = regionCode
        self.value = value
    }
}
