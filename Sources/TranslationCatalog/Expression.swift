import Foundation
import LocaleSupport

/// A word or phrase.
///
/// - note: Expressions can exist outside the context of a Project and a single expression can be associated with multiple projects.
public struct Expression: Codable, Hashable, Identifiable, Sendable {
    /// Identifier that universally identifies this `Expression`
    public let id: UUID
    /// Localization file unique key identifier
    public let key: String
    /// Description of this `Expression`
    public let name: String
    /// The language from which the original `Translation` value is expressed.
    public let defaultLanguageCode: Locale.LanguageCode
    /// Comments and information around the usage of the `Expression`
    ///
    /// For instance, the word 'Start' could be used as a verb or a noun.
    public let context: String?
    /// Additional contextual information that further classifies the `Expression`
    public let feature: String?
    /// The translated values for the `Expression`
    public let translations: [Translation]

    public init(
        id: UUID = .zero,
        key: String = "",
        name: String = "",
        defaultLanguageCode: Locale.LanguageCode = .default,
        context: String? = nil,
        feature: String? = nil,
        translations: [Translation] = []
    ) {
        self.id = id
        self.key = key
        self.name = name
        self.defaultLanguageCode = defaultLanguageCode
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
        context = expression.context
        feature = expression.feature
        self.translations = translations
    }

    /// The language to be used when a `Translation` can not be found
    @available(*, deprecated, renamed: "defaultLanguageCode")
    public var defaultLanguage: LanguageCode {
        LanguageCode(rawValue: defaultLanguageCode.identifier) ?? .default
    }

    /// The `Translation` that matches the `defaultLanguage` code of this instance.
    public var defaultTranslation: Translation? {
        translations.first(where: { $0.language == defaultLanguageCode })
    }

    /// The `Translation` that matches the provided `Locale.Identifier`.
    public func translation(with locale: Locale?) -> Translation? {
        translations.first(where: { $0.locale == locale })
    }

    @available(*, deprecated, message: "Use `with: Locale?` variant.")
    public func translation(with identifier: Locale.Identifier?) -> Translation? {
        translations.first(where: { $0.locale.identifier == identifier })
    }

    /// The `Translation` matching the `Locale.Identifier` or `defaultTranslation` if no matches found.
    public func translationOrDefault(with locale: Locale?) -> Translation? {
        translation(with: locale) ?? defaultTranslation
    }

    @available(*, deprecated, message: "Use `with: Locale?` variant.")
    public func translationOrDefault(with identifier: Locale.Identifier?) -> Translation? {
        translation(with: identifier) ?? defaultTranslation
    }

    /// The `Translation` that best matches the provided identifier, default if none, or first in the collection.
    public func translationOrDefaultOrFirst(with locale: Locale?) -> Translation? {
        translationOrDefault(with: locale) ?? translations.first
    }

    @available(*, deprecated, message: "Use `with: Locale?` variant.")
    public func translationOrDefaultOrFirst(with identifier: Locale.Identifier?) -> Translation? {
        translationOrDefault(with: identifier) ?? translations.first
    }
}
