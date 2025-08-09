import Foundation

/// A specific language/region variation of an `Expression`.
public struct Translation: Codable, Hashable, Identifiable, Sendable {
    /// Identifier that universally identifies this `Translation`
    public let id: UUID
    /// Identifier of the `Expression` that contains this `Translation`
    public let expressionId: Expression.ID
    /// The primary `Locale.LanguageCode` of the translated `value`
    public let language: Locale.LanguageCode
    /// `Locale.Script` that provides precise dialect differentiation.
    public let script: Locale.Script?
    /// `Locale.Region` that classifies a regional usage of the language.
    public let region: Locale.Region?
    /// The translated value
    public let value: String

    public init(
        id: UUID = .zero,
        expressionId: Expression.ID = .zero,
        language: Locale.LanguageCode = .default,
        script: Locale.Script? = nil,
        region: Locale.Region? = nil,
        value: String = ""
    ) {
        self.id = id
        self.expressionId = expressionId
        self.language = language
        self.script = script
        self.region = region
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
        language = translation.language
        script = translation.script
        region = translation.region
        value = translation.value
    }

    /// The `Locale` represented by this instance.
    public var locale: Locale {
        Locale(languageCode: language, script: script, languageRegion: region)
    }
}
