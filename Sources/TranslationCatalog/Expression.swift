import Foundation
import LocaleSupport

/// A word or phrase.
///
/// - note: Expressions can exist outside the context of a Project
/// and a single expression can be associated with multiple projects.
public struct Expression: Codable, Hashable, Identifiable, Sendable {
    /// Identifier that universally identifies this `Expression`
    public let id: UUID
    /// Localization file unique key identifier
    public let key: String
    /// Value used as a base translation, expressed in the `defaultLanguageCode`
    public let defaultValue: String
    /// The language from which the original `Translation` value is expressed.
    public let defaultLanguageCode: Locale.LanguageCode
    /// Description of this `Expression`
    public let name: String
    /// Comments and information around the usage of the `Expression`
    ///
    /// For instance, the word 'Start' could be used as a verb or a noun.
    public let context: String?
    /// Additional contextual information that further classifies the `Expression`
    public let feature: String?
    /// The translated values for the `Expression`
    public let translations: [Translation]

    public init(
        id: UUID,
        key: String,
        value: String,
        languageCode: Locale.LanguageCode,
        name: String = "",
        context: String? = nil,
        feature: String? = nil,
        translations: [Translation] = []
    ) {
        self.id = id
        self.key = key
        defaultValue = value
        defaultLanguageCode = languageCode
        self.name = name
        self.context = context
        self.feature = feature
        self.translations = translations
    }

    public init(
        expression: Expression,
        translations: [Translation]
    ) {
        id = expression.id
        key = expression.key
        name = expression.name
        defaultLanguageCode = expression.defaultLanguageCode
        defaultValue = expression.defaultValue
        context = expression.context
        feature = expression.feature
        self.translations = translations
    }

    @available(*, deprecated, renamed: "init(id:key:value:languageCode:name:context:feature:translations:)")
    public init(
        id: UUID = .zero,
        key: String = "",
        name: String = "",
        defaultLanguageCode: Locale.LanguageCode = .default,
        defaultValue: String = "",
        context: String? = nil,
        feature: String? = nil,
        translations: [Translation] = []
    ) {
        self.id = id
        self.key = key
        self.name = name
        self.defaultLanguageCode = defaultLanguageCode
        self.defaultValue = defaultValue
        self.context = context
        self.feature = feature
        self.translations = translations
    }

    @available(*, deprecated, renamed: "init(id:key:name:defaultLanguageCode:context:feature:translations:)")
    public init(
        id: UUID = .zero,
        key: String = "",
        name: String = "",
        defaultLanguage: LanguageCode = .default,
        context: String? = nil,
        feature: String? = nil,
        translations: [Translation] = []
    ) {
        self.id = id
        self.key = key
        self.name = name
        defaultLanguageCode = Locale.LanguageCode(defaultLanguage.rawValue)
        defaultValue = translations.first(where: { $0.languageCode == defaultLanguage })?.value ?? ""
        self.context = context
        self.feature = feature
        self.translations = translations
    }

    /// `Locale` representing the `defaultLanguageCode`.
    public var locale: Locale {
        Locale(languageCode: defaultLanguageCode)
    }

    /// The `Translation` that matches the provided `Locale.Identifier`.
    public func translation(with locale: Locale?) -> Translation? {
        translations.first(where: { $0.locale == locale })
    }

    /// The translation string for the provided `Locale`.
    public func value(for locale: Locale?) -> String? {
        guard let locale else {
            return nil
        }

        if locale == self.locale {
            return defaultValue
        }

        return translation(with: locale)?.value
    }

    /// The translation string for the provided `Locale`. Fallback to the `defaultValue`.
    public func valueOrDefault(for locale: Locale) -> String {
        guard locale != self.locale else {
            return defaultValue
        }

        guard let translation = translation(with: locale) else {
            return defaultValue
        }

        return translation.value
    }
}

public extension Expression {
    /// The language to be used when a `Translation` can not be found
    @available(*, deprecated, renamed: "defaultLanguageCode")
    var defaultLanguage: LanguageCode {
        LanguageCode(rawValue: defaultLanguageCode.identifier) ?? .default
    }

    /// The `Translation` that matches the `defaultLanguage` code of this instance.
    @available(*, deprecated, message: "Use `defaultValue` for the base expression value.")
    var defaultTranslation: Translation? {
        translations.first(where: { $0.language == defaultLanguageCode })
    }

    @available(*, deprecated, message: "Use `with: Locale?` variant.")
    func translation(with identifier: Locale.Identifier?) -> Translation? {
        translations.first(where: { $0.locale.identifier == identifier })
    }

    @available(*, deprecated)
    func translationOrDefault(with identifier: Locale.Identifier?) -> Translation? {
        translation(with: identifier) ?? defaultTranslation
    }

    @available(*, deprecated)
    func translationOrDefaultOrFirst(with identifier: Locale.Identifier?) -> Translation? {
        translationOrDefault(with: identifier) ?? translations.first
    }

    /// The `Translation` matching the `Locale.Identifier` or `defaultTranslation` if no matches found.
    @available(*, deprecated)
    func translationOrDefault(with locale: Locale?) -> Translation? {
        translation(with: locale) ?? defaultTranslation
    }

    /// The `Translation` that best matches the provided identifier, default if none, or first in the collection.
    @available(*, deprecated)
    func translationOrDefaultOrFirst(with locale: Locale?) -> Translation? {
        translationOrDefault(with: locale) ?? translations.first
    }
}
