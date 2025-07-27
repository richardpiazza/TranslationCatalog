import Foundation
import LocaleSupport

/// Associated parameters for performing query operations
public protocol CatalogQuery {}

public enum GenericProjectQuery: CatalogQuery {
    case id(Project.ID)
    case named(String)
    case expressionId(Expression.ID)
}

public enum GenericExpressionQuery: CatalogQuery {
    case id(Expression.ID)
    case projectId(Project.ID)
    case key(String)
    case value(String)
    case named(String)
    /// Expressions with Translations that only match the provided LanguageCode. (Script == Null & Region == Null)
    case translationsHavingOnly(Locale.LanguageCode)
    /// Expressions with Translations the match the LanguageCode as well as the provided script/region.
    case translationsHaving(Locale.LanguageCode, Locale.Script?, Locale.Region?)

    @available(*, deprecated, message: "Use `Locale` variant.")
    public static func translationsHavingOnly(_ languageCode: LanguageCode) -> Self {
        translationsHavingOnly(Locale.LanguageCode(languageCode.rawValue))
    }

    @available(*, deprecated, message: "Use `Locale` variant.")
    public static func translationsHaving(_ languageCode: LanguageCode, _ scriptCode: ScriptCode?, _ regionCode: RegionCode?) -> Self {
        switch (scriptCode, regionCode) {
        case (.some(let script), .some(let region)):
            translationsHaving(Locale.LanguageCode(languageCode.rawValue), Locale.Script(script.rawValue), Locale.Region(region.rawValue))
        case (.some(let script), .none):
            translationsHaving(Locale.LanguageCode(languageCode.rawValue), Locale.Script(script.rawValue), nil)
        case (.none, .some(let region)):
            translationsHaving(Locale.LanguageCode(languageCode.rawValue), nil, Locale.Region(region.rawValue))
        default:
            translationsHaving(Locale.LanguageCode(languageCode.rawValue), Locale.Script?.none, Locale.Region?.none)
        }
    }
}

public enum GenericTranslationQuery: CatalogQuery {
    case id(Translation.ID)
    case expressionId(Expression.ID)
    /// Translations that match only the given parameters (Script == Null & Region == Null)
    case havingOnly(Expression.ID, Locale.LanguageCode)
    /// Translations that match all of the provided parameters
    case having(Expression.ID, Locale.LanguageCode, Locale.Script?, Locale.Region?)

    @available(*, deprecated, message: "Use `Locale` variant.")
    public static func havingOnly(_ id: Expression.ID, _ languageCode: LanguageCode) -> Self {
        havingOnly(id, Locale.LanguageCode(languageCode.rawValue))
    }

    @available(*, deprecated, message: "Use `Locale` variant.")
    public static func having(_ id: Expression.ID, _ languageCode: LanguageCode, _ scriptCode: ScriptCode?, _ regionCode: RegionCode?) -> Self {
        switch (scriptCode, regionCode) {
        case (.some(let script), .some(let region)):
            having(id, Locale.LanguageCode(languageCode.rawValue), Locale.Script(script.rawValue), Locale.Region(region.rawValue))
        case (.some(let script), .none):
            having(id, Locale.LanguageCode(languageCode.rawValue), Locale.Script(script.rawValue), nil)
        case (.none, .some(let region)):
            having(id, Locale.LanguageCode(languageCode.rawValue), nil, Locale.Region(region.rawValue))
        default:
            having(id, Locale.LanguageCode(languageCode.rawValue), Locale.Script?.none, Locale.Region?.none)
        }
    }
}
