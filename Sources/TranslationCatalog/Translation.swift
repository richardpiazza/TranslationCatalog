import LocaleSupport
import Foundation

/// A specific language/region variation of an `Expression`.
public struct Translation {
    /// Identifier that universally identifies this `Translation`
    public var uuid: UUID
    /// Identifier of the `Expression` that contains this `Translation`
    public var expressionID: Expression.ID
    /// The primary `LanguageCode` of the translated `value`
    public var languageCode: LanguageCode
    /// `ScriptCode` that provides precise dialect differentiation.
    public var scriptCode: ScriptCode?
    /// `RegionCode` that classifies a regional usage of the language.
    public var regionCode: RegionCode?
    /// The translated value
    public var value: String
    
    public init(uuid: UUID = .zero, expressionID: Expression.ID = .zero, languageCode: LanguageCode = .default, scriptCode: ScriptCode? = nil, regionCode: RegionCode? = nil, value: String = "") {
        self.uuid = uuid
        self.expressionID = expressionID
        self.languageCode = languageCode
        self.scriptCode = scriptCode
        self.regionCode = regionCode
        self.value = value
    }
}

extension Translation: Codable {}
extension Translation: Hashable {}
extension Translation: Identifiable {
    public var id: UUID { uuid }
}
extension Translation: LocaleRepresentable {}
