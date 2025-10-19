import Foundation

/// A specific language/region variation of an `Expression`.
public struct Translation: Hashable, Sendable, Identifiable, Codable {
    /// Identifier that universally identifies this `Translation`
    public let id: UUID
    /// Identifier of the `Expression` that contains this `Translation`
    public let expressionId: Expression.ID
    /// The translated value
    public let value: String
    /// The primary `Locale.LanguageCode` of the translated `value`
    public let language: Locale.LanguageCode
    /// `Locale.Script` that provides precise dialect differentiation.
    public let script: Locale.Script?
    /// `Locale.Region` that classifies a regional usage of the language.
    public let region: Locale.Region?
    /// Indication of potential actions to be complete.
    public let state: TranslationState

    public init(
        id: UUID,
        expressionId: Expression.ID,
        value: String,
        language: Locale.LanguageCode,
        script: Locale.Script? = nil,
        region: Locale.Region? = nil,
        state: TranslationState = .new
    ) {
        self.id = id
        self.expressionId = expressionId
        self.value = value
        self.language = language
        self.script = script
        self.region = region
        self.state = state
    }

    /// Convenience initializer to assigns all values from the provided `Translation`,
    /// while overriding the `Expression.ID`.
    public init(
        translation: Translation,
        expressionId: Expression.ID
    ) {
        id = translation.id
        self.expressionId = expressionId
        language = translation.language
        script = translation.script
        region = translation.region
        value = translation.value
        state = translation.state
    }

    /// The `Locale` represented by this instance.
    public var locale: Locale {
        Locale(languageCode: language, script: script, languageRegion: region)
    }
}
