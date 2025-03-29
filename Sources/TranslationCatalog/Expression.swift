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
    /// The language to be used when a `Translation` can not be found
    public let defaultLanguage: LanguageCode
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
        defaultLanguage: LanguageCode = .default,
        context: String? = nil,
        feature: String? = nil,
        translations: [Translation] = []
    ) {
        self.id = id
        self.key = key
        self.name = name
        self.defaultLanguage = defaultLanguage
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
        defaultLanguage = expression.defaultLanguage
        context = expression.context
        feature = expression.feature
        self.translations = translations
    }
    
    /// The `Translation` that matches the `defaultLanguage` code of this instance.
    public var defaultTranslation: Translation? {
        translations.first(where: { $0.languageCode == defaultLanguage })
    }
    
    /// The `Translation` that matches the provided `Locale.Identifier`.
    public func translation(with identifier: Locale.Identifier?) -> Translation? {
        translations.first(where: { $0.localeIdentifier == identifier })
    }
    
    /// The `Translation` matching the `Locale.Identifier` or `defaultTranslation` if no matches found.
    public func translationOrDefault(with identifier: Locale.Identifier?) -> Translation? {
        translation(with: identifier) ?? defaultTranslation
    }
    
    /// The `Translation` that best matches the provided identifier, default if none, or first in the collection.
    public func translationOrDefaultOrFirst(with identifier: Locale.Identifier?) -> Translation? {
        translationOrDefault(with: identifier) ?? translations.first
    }
}

public extension Expression {
    @available(*, deprecated, renamed: "id")
    var uuid: UUID { id }
    
    @available(*, deprecated, renamed: "init(id:key:name:defaultLanguage:context:feature:translations:)")
    init(
        uuid: UUID = .zero,
        key: String = "",
        name: String = "",
        defaultLanguage: LanguageCode = .default,
        context: String? = nil,
        feature: String? = nil,
        translations: [Translation] = []
    ) {
        self.id = uuid
        self.key = key
        self.name = name
        self.defaultLanguage = defaultLanguage
        self.context = context
        self.feature = feature
        self.translations = translations
    }
}
