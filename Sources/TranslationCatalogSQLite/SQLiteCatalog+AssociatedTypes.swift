import Foundation
import LocaleSupport
import TranslationCatalog

public extension SQLiteCatalog {
    
    enum Error: Swift.Error {
        case invalidPrimaryKey(Int)
        case invalidStringValue(String)
        
        @available(*, deprecated, renamed: "CatalogError.unhandledUpdate()")
        case invalidAction(CatalogUpdate)
        @available(*, deprecated, renamed: "CatalogError.badQuery()")
        case invalidQuery(CatalogQuery)
        @available(*, deprecated, renamed: "CatalogError.projectID()")
        case invalidProjectID(Project.ID)
        @available(*, deprecated, renamed: "CatalogError.expressionID()")
        case invalidExpressionID(Expression.ID)
        @available(*, deprecated, renamed: "CatalogError.translationID()")
        case invalidTranslationID(TranslationCatalog.Translation.ID)
        @available(*, deprecated, renamed: "CatalogError.expressionExistingWithID()")
        case existingExpressionWithID(Expression.ID)
        @available(*, deprecated, renamed: "CatalogError.expressionExistingWithKey()")
        case existingExpressionWithKey(String)
        @available(*, deprecated, renamed: "CatalogError.translationExistingWithID()")
        case existingTranslationWithID(TranslationCatalog.Translation.ID)
        @available(*, deprecated, renamed: "CatalogError.unhandledUpdate()")
        case unhandledAction(CatalogUpdate)
        @available(*, deprecated, renamed: "CatalogError.dataTypeConversion()")
        case unhandledConversion
        @available(*, deprecated, renamed: "CatalogError.unhandledQuery()")
        case unhandledQuery(CatalogQuery)
    }
    
    enum ProjectQuery: CatalogQuery {
        case hierarchy
        case primaryKey(Int)
        
        @available(*, deprecated, renamed: "GenericProjectQuery.id")
        case id(Project.ID)
        @available(*, deprecated, renamed: "GenericProjectQuery.named")
        case named(String)
    }
    
    enum ExpressionQuery: CatalogQuery {
        case hierarchy
        case primaryKey(Int)
        
        @available(*, deprecated, renamed: "GenericExpressionQuery.id")
        case id(Expression.ID)
        @available(*, deprecated, renamed: "GenericExpressionQuery.projectID")
        case projectID(Project.ID)
        @available(*, deprecated, renamed: "GenericExpressionQuery.key")
        case key(String)
        @available(*, deprecated, renamed: "GenericExpressionQuery.named")
        case named(String)
        /// Expressions with Translations the match the LanguageCode as well as the provided script/region.
        @available(*, deprecated, renamed: "GenericExpressionQuery.translationsHaving")
        case having(LanguageCode, ScriptCode?, RegionCode?)
        /// Expressions with Translations that only match the provided LanguageCode. (Script == Null & Region == Null)
        @available(*, deprecated, renamed: "GenericExpressionQuery.translationsHavingOnly")
        case havingOnly(LanguageCode)
    }
    
    enum TranslationQuery: CatalogQuery {
        case primaryKey(Int)
        
        @available(*, deprecated, renamed: "GenericTranslationQuery.id")
        case id(TranslationCatalog.Translation.ID)
        @available(*, deprecated, renamed: "GenericTranslationQuery.expressionID")
        case expressionID(Expression.ID)
        /// Translations that match all of the provided parameters
        @available(*, deprecated, renamed: "GenericTranslationQuery.having")
        case having(Expression.ID, LanguageCode, ScriptCode?, RegionCode?)
        /// Translations that match only the given parameters (Script == Null & Region == Null)
        @available(*, deprecated, renamed: "GenericTranslationQuery.havingOnly")
        case havingOnly(Expression.ID, LanguageCode)
    }
    
    enum ProjectUpdate: CatalogUpdate {
        @available(*, deprecated, renamed: "GenericProjectUpdate.name")
        case name(String)
        @available(*, deprecated, renamed: "GenericProjectUpdate.linkExpression")
        case linkExpression(Expression.ID)
        @available(*, deprecated, renamed: "GenericProjectUpdate.unlinkExpression")
        case unlinkExpression(Expression.ID)
    }
    
    enum ExpressionUpdate: CatalogUpdate {
        @available(*, deprecated, renamed: "GenericExpressionUpdate.key")
        case key(String)
        @available(*, deprecated, renamed: "GenericExpressionUpdate.name")
        case name(String)
        @available(*, deprecated, renamed: "GenericExpressionUpdate.defaultLanguage")
        case defaultLanguage(LanguageCode)
        @available(*, deprecated, renamed: "GenericExpressionUpdate.context")
        case context(String?)
        @available(*, deprecated, renamed: "GenericExpressionUpdate.feature")
        case feature(String?)
        @available(*, deprecated, renamed: "GenericProjectUpdate.linkExpression")
        case linkProject(Project.ID)
        @available(*, deprecated, renamed: "GenericProjectUpdate.unlinkExpression")
        case unlinkProject(Project.ID)
    }
    
    enum TranslationUpdate: CatalogUpdate {
        @available(*, deprecated, renamed: "GenericTranslationUpdate.language")
        case language(LanguageCode)
        @available(*, deprecated, renamed: "GenericTranslationUpdate.script")
        case script(ScriptCode?)
        @available(*, deprecated, renamed: "GenericTranslationUpdate.region")
        case region(RegionCode?)
        @available(*, deprecated, renamed: "GenericTranslationUpdate.value")
        case value(String)
    }
}
