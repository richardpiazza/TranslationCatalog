import LocaleSupport
import Foundation

/// A word or phrase.
///
/// - note: Expressions can exist outside the context of a Project and a single expression can be associated with multiple projects.
public struct Expression {
    /// Identifier that universally identifies this `Expression`
    public var uuid: UUID
    /// Localization file unique key identifier
    public var key: String
    /// Description of this `Expression`
    public var name: String
    /// The language to be used when a `Translation` can not be found
    public var defaultLanguage: LanguageCode
    /// Comments and information around the usage of the `Expression`
    ///
    /// For instance, the word 'Start' could be used as a verb or a noun.
    public var context: String?
    /// Additional contextual information that further classifies the `Expression`
    public var feature: String?
    /// The translated values for the `Expression`
    public var translations: [Translation]
    
    public init(uuid: UUID = .zero, key: String = "", name: String = "", defaultLanguage: LanguageCode = .default, context: String? = nil, feature: String? = nil, translations: [Translation] = []) {
        self.uuid = uuid
        self.key = key
        self.name = name
        self.defaultLanguage = defaultLanguage
        self.context = context
        self.feature = feature
        self.translations = translations
    }
}

extension Expression: Codable {}
extension Expression: Hashable {}
extension Expression: Identifiable {
    public var id: UUID { uuid }
}
