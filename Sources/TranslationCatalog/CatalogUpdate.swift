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
    case defaultLanguage(LanguageCode)
    case context(String?)
    case feature(String?)
}

public enum GenericTranslationUpdate: CatalogUpdate {
    case language(LanguageCode)
    case script(ScriptCode?)
    case region(RegionCode?)
    case value(String)
}
