import ArgumentParser
import Foundation
import Plot
import LocaleSupport
import TranslationCatalog
import TranslationCatalogSQLite

extension Catalog {
    struct Export: CatalogCommand {
        
        enum Format: String, ExpressibleByArgument {
            case android
            case apple
        }
        
        static var configuration: CommandConfiguration = .init(
            commandName: "export",
            abstract: "Export a translation file using the catalog.",
            discussion: """
            iOS Localization should contain all keys (expressions) for a given language. There is no native fallback
            mechanism to a 'base' language. (i.e. en-GB > en). Given this functionality, when exporting the 'apple'
            format, all expressions will be included (preferring the script/region).
            """,
            version: "1.0.0",
            shouldDisplay: true,
            subcommands: [],
            defaultSubcommand: nil,
            helpNames: .shortAndLong
        )
        
        @Argument(help: "The export format")
        var format: Format = .android
        
        @Argument(help: "The language code to use for the strings.")
        var language: LanguageCode
        
        @Option(help: "The script code to use for the strings.")
        var script: ScriptCode?
        
        @Option(help: "The region code to use for the strings.")
        var region: RegionCode?
        
        @Option(help: "Identifier of the project for which to limit results.")
        var projectId: Project.ID?
        
        @Option(help: "Path to catalog to use in place of the application library.")
        var path: String?
        
        func run() throws {
            let catalog = try SQLiteCatalog(url: try catalogURL())
            
            var expressions: [Expression]
            var expressionIds: [Expression.ID]
            
            switch format {
            case .android:
                if let id = projectId {
                    expressions = try catalog.expressions(matching: GenericExpressionQuery.projectID(id))
                    let withLanguage = try catalog.expressions(matching: GenericExpressionQuery.translationsHaving(language, script, region))
                    expressions.removeAll { expression in
                        !withLanguage.contains(where: { $0.id == expression.id })
                    }
                } else {
                    expressions = try catalog.expressions(matching: GenericExpressionQuery.translationsHaving(language, script, region))
                }
                
                expressionIds = expressions.map { $0.id }
                
                try expressionIds.enumerated().forEach { (index, id) in
                    expressions[index].translations = try catalog.translations(matching: GenericTranslationQuery.having(id, language, script, region))
                }
                
                exportAndroid(expressions)
            case .apple:
                if let id = projectId {
                    expressions = try catalog.expressions(matching: GenericExpressionQuery.projectID(id))
                    let withLanguage = try catalog.expressions(matching: GenericExpressionQuery.translationsHaving(language, nil, nil))
                    expressions.removeAll { expression in
                        !withLanguage.contains(where: { $0.id == expression.id })
                    }
                } else {
                    expressions = try catalog.expressions()
                }
                
                expressionIds = expressions.map { $0.id }
                
                for (index, id) in expressionIds.enumerated() {
                    let preferredTranslations = try catalog.translations(matching: GenericTranslationQuery.having(id, language, script, region))
                    if !preferredTranslations.isEmpty {
                        expressions[index].translations = preferredTranslations
                        continue
                    }
                    
                    let fallbackTranslations = try catalog.translations(matching: GenericTranslationQuery.having(id, language, nil, nil))
                    if !fallbackTranslations.isEmpty {
                        expressions[index].translations = fallbackTranslations
                        continue
                    }
                    
                    let defaultLanguage = expressions[index].defaultLanguage
                    let defaultTranslations = try catalog.translations(matching: GenericTranslationQuery.having(id, defaultLanguage, nil, nil))
                    expressions[index].translations = defaultTranslations
                }
                
                exportApple(expressions)
            }
        }
        
        private func exportAndroid(_ expressions: [Expression]) {
            let xml = XML.make(with: expressions)
            print(xml.render(indentedBy: .spaces(2)))
        }
        
        private func exportApple(_ expressions: [Expression]) {
            expressions.forEach { (expression) in
                guard let translation = expression.translations.first else {
                    return
                }
                
                print("\"\(expression.key)\" = \"\(translation.value)\";")
            }
        }
    }
}
