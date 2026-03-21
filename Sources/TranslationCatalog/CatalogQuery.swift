import Foundation

/// Associated parameters for performing query operations
public protocol CatalogQuery: Sendable {}

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
    /// Expressions with Translations that match the LanguageCode as well as the provided script/region.
    case translationsHaving(Locale.LanguageCode, Locale.Script?, Locale.Region?)
    /// Expressions with Translations having a specified state
    case translationsHavingState(TranslationState)
    /// Expressions that don't have a default value or Translation for _all_ of the specified locales.
    case withoutAllLocales(Set<Locale>)
}

public enum GenericTranslationQuery: CatalogQuery {
    case id(Translation.ID)
    case expressionId(Expression.ID)
    /// Translations that match only the given parameters (Script == Null & Region == Null)
    case havingOnly(Expression.ID, Locale.LanguageCode)
    /// Translations that match all of the provided parameters
    case having(Expression.ID, Locale.LanguageCode, Locale.Script?, Locale.Region?)
}
