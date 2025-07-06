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
    case named(String)
    /// Expressions with Translations that only match the provided LanguageCode. (Script == Null & Region == Null)
    case translationsHavingOnly(LanguageCode)
    /// Expressions with Translations the match the LanguageCode as well as the provided script/region.
    case translationsHaving(LanguageCode, ScriptCode?, RegionCode?)
}

public enum GenericTranslationQuery: CatalogQuery {
    case id(Translation.ID)
    case expressionId(Expression.ID)
    /// Translations that match only the given parameters (Script == Null & Region == Null)
    case havingOnly(Expression.ID, LanguageCode)
    /// Translations that match all of the provided parameters
    case having(Expression.ID, LanguageCode, ScriptCode?, RegionCode?)
}
