import Foundation
import LocaleSupport

/// Associated parameters when performing update operations
public protocol CatalogUpdate {}

public enum GenericProjectUpdate: CatalogUpdate {
    case name(String)
    case linkExpression(Expression.ID)
    case unlinkExpression(Expression.ID)
}

public enum GenericExpressionUpdate: CatalogUpdate {
    case key(String)
    case name(String)
    case defaultLanguage(Locale.LanguageCode)
    case context(String?)
    case feature(String?)

    @available(*, deprecated, message: "Use `Locale` variant.")
    public static func defaultLanguage(_ languageCode: LanguageCode) -> Self {
        defaultLanguage(Locale.LanguageCode(languageCode.rawValue))
    }
}

public enum GenericTranslationUpdate: CatalogUpdate {
    case language(Locale.LanguageCode)
    case script(Locale.Script?)
    case region(Locale.Region?)
    case value(String)

    @available(*, deprecated, message: "Use `Locale` variant.")
    public static func language(_ languageCode: LanguageCode) -> Self {
        language(Locale.LanguageCode(languageCode.rawValue))
    }

    @available(*, deprecated, message: "Use `Locale` variant.")
    public static func script(_ scriptCode: ScriptCode?) -> Self {
        guard let scriptCode else {
            return script(Locale.Script?.none)
        }

        return script(Locale.Script(scriptCode.rawValue))
    }

    @available(*, deprecated, message: "Use `Locale` variant.")
    public static func region(_ regionCode: RegionCode?) -> Self {
        guard let regionCode else {
            return region(Locale.Region?.none)
        }

        return region(Locale.Region(regionCode.rawValue))
    }
}
