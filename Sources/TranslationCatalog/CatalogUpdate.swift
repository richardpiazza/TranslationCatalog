import Foundation

/// Associated parameters when performing update operations
public protocol CatalogUpdate: Sendable {}

public enum GenericProjectUpdate: CatalogUpdate {
    case name(String)
    case linkExpression(Expression.ID)
    case unlinkExpression(Expression.ID)
}

public enum GenericExpressionUpdate: CatalogUpdate {
    case key(String)
    case name(String)
    case defaultLanguage(Locale.LanguageCode)
    case defaultValue(String)
    case context(String?)
    case feature(String?)
}

public enum GenericTranslationUpdate: CatalogUpdate {
    case language(Locale.LanguageCode)
    case script(Locale.Script?)
    case region(Locale.Region?)
    case value(String)
    case state(TranslationState)
}
