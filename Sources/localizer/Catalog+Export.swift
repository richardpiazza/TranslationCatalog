import ArgumentParser
import Foundation
import Plot
import LocaleSupport
import TranslationCatalog

extension Catalog {
    struct Export: CatalogCommand {
        
        static var configuration: CommandConfiguration = .init(
            commandName: "export",
            abstract: "Export a translation file using the catalog.",
            usage: nil,
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
        
        @Argument(help: "The export format [android, apple, json]")
        var format: Catalog.Format
        
        @Argument(help: "The language code to use for the strings.")
        var language: LanguageCode
        
        @Option(help: "The script code to use for the strings.")
        var script: ScriptCode?
        
        @Option(help: "The region code to use for the strings.")
        var region: RegionCode?
        
        @Option(help: "Identifier of the project for which to limit results.")
        var projectId: Project.ID?
        
        @Flag(help: "Indicates if a fallback translation should be used when no matching option is found.")
        var fallback: Bool = false
        
        @Option(help: "Storage mechanism used to persist the catalog. [sqlite, filesystem]")
        var storage: Catalog.Storage = .default
        
        @Option(help: "Path to catalog to use in place of the application library.")
        var path: String?
        
        func run() throws {
            let catalog = try catalog(forStorage: storage)
            
            var expressions: [Expression]
            var expressionIds: [Expression.ID]
            
            if format == .apple || fallback {
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
            } else {
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
            }
            
            switch format {
            case .android:
                exportAndroid(expressions)
            case .apple:
                exportApple(expressions)
            case .json:
                try exportJson(expressions)
            }
        }
        
        private func exportAndroid(_ expressions: [Expression]) {
            let sorted = expressions.sorted(by: { $0.key < $1.key})
            let xml = XML.make(with: sorted)
            print(xml.render(indentedBy: .spaces(2)))
        }
        
        private func exportApple(_ expressions: [Expression]) {
            let sorted = expressions.sorted(by: { $0.key < $1.key})
            sorted.forEach { (expression) in
                guard let translation = expression.translations.first else {
                    return
                }
                
                print("\"\(expression.key)\" = \"\(translation.value)\";")
            }
        }
        
        private func exportJson(_ expressions: [Expression]) throws {
            let sequence = expressions.map { [$0.key: $0.translations.first?.value ?? ""] }
            let dictionary = sequence.reduce(into: Dictionary<String, String>()) { partialResult, pair in
                partialResult[pair.keys.first!] = pair.values.first!
            }
            
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
            
            let data = try encoder.encode(dictionary)
            let json = String(data: data, encoding: .utf8) ?? ""
            print(json)
        }
    }
}
