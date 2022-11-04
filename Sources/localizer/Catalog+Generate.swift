import ArgumentParser
import Foundation
import Plot
import TranslationCatalog
import TranslationCatalogSQLite
import TranslationCatalogFilesystem

extension Catalog {
    struct Generate: CatalogCommand {
        
        enum Format: String, CaseIterable, ExpressibleByArgument {
            case markdown
            case html
        }
        
        static var configuration: CommandConfiguration = .init(
            commandName: "generate",
            abstract: "Generate a viewable document using the strings catalog.",
            discussion: """
            Available formats: \(Format.allCases.map{ $0.rawValue }.joined(separator: " "))
            """,
            version: "1.0.0",
            shouldDisplay: true,
            subcommands: [],
            defaultSubcommand: nil,
            helpNames: .shortAndLong
        )
        
        @Argument(help: "The export format")
        var format: Format
        
        @Option(help: "Storage mechanism used to persist the catalog. [sqlite, filesystem]")
        var storage: Catalog.Storage = .default
        
        @Option(help: "Path to catalog to use in place of the application library.")
        var path: String?
        
        func run() throws {
            let url = try catalogURL(forStorage: storage)
            
            let expressions: [Expression]
            
            switch storage {
            case .sqlite:
                let catalog = try SQLiteCatalog(url: url)
                expressions = try catalog.expressions(matching: SQLiteCatalog.ExpressionQuery.hierarchy).sorted(by: { $0.name < $1.name })
            case .filesystem:
                let catalog = try FilesystemCatalog(url: url)
                expressions = try catalog.expressions().sorted(by: { $0.name < $1.name })
            }
            
            switch format {
            case .markdown:
                exportMarkdown(expressions)
            case .html:
                exportHtml(expressions)
            }
        }
        
        private func exportMarkdown(_ expressions: [Expression]) {
            var md: String = "# Strings"
            
            expressions.forEach { (expression) in
                md += """
                \n
                ## \(expression.name)
                Id: \(expression.id)
                Key: \(expression.key)
                Context: \(expression.context ?? "")
                Feature: \(expression.feature ?? "")
                
                | ID | Locale Identifier | Value |
                | --- | --- | --- |
                """
                
                let translations = expression.translations.sorted(by: { $0.languageCode.rawValue < $1.languageCode.rawValue })
                translations.forEach { (translation) in
                    if translation.languageCode == expression.defaultLanguage {
                        md += "\n| **\(translation.id)** | **\(translation.localeIdentifier)** | **\(translation.value)** |"
                    } else {
                        md += "\n| \(translation.id) | \(translation.localeIdentifier) | \(translation.value) |"
                    }
                }
            }
            
            print(md)
        }
        
        private func exportHtml(_ expressions: [Expression]) {
            let html = HTML.make(with: expressions)
            print(html.render(indentedBy: .spaces(2)))
        }
    }
}
