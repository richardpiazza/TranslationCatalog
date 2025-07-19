import Foundation
import LocaleSupport

/// A specific language/region variation of an `Expression`.
public struct Translation: Codable, Hashable, Identifiable, LocaleRepresentable, Sendable {
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

    @available(*, deprecated, renamed: "init(id:expressionId:language:script:region:value:)")
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
        language = Locale.LanguageCode(languageCode.rawValue)
        if let scriptCode {
            script = Locale.Script(scriptCode.rawValue)
        } else {
            script = nil
        }
        if let regionCode {
            region = Locale.Region(regionCode.rawValue)
        } else {
            region = nil
        }
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

    /// The primary `LanguageCode` of the translated `value`
    public var languageCode: LanguageCode {
        LanguageCode(rawValue: language.identifier) ?? .default
    }

    /// `ScriptCode` that provides precise dialect differentiation.
    public var scriptCode: ScriptCode? {
        guard let script else {
            return nil
        }

        return ScriptCode(rawValue: script.identifier)
    }

    /// `RegionCode` that classifies a regional usage of the language.
    public var regionCode: RegionCode? {
        guard let region else {
            return nil
        }

        return RegionCode(rawValue: region.identifier)
    }
}
