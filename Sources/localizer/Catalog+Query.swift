import Foundation
import ArgumentParser
import TranslationCatalog
import TranslationCatalogIO

extension Catalog {
    struct Query: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "query",
            abstract: "Perform queries against the catalog.",
            version: "1.0.0",
            subcommands: [
                ProjectCommand.self,
                ExpressionCommand.self
            ],
            helpNames: .shortAndLong
        )
    }
}

extension Catalog.Query {
    struct ProjectCommand: CatalogCommand {
        
        static let configuration = CommandConfiguration(
            commandName: "project",
            abstract: "Query for projects in the catalog.",
            version: "1.0.0",
            helpNames: .shortAndLong
        )
        
        @Option(help: "Partial name search")
        var named: String?
        
        @Option(help: "Storage mechanism used to persist the catalog. [sqlite, filesystem]")
        var storage: Catalog.Storage = .default
        
        @Option(help: "Path to catalog to use in place of the application library.")
        var path: String?
        
        @Flag(help: "Outputs detailed execution")
        var noisy: Bool = false
        
        func validate() throws {
            if let named = self.named {
                guard !named.isEmpty else {
                    throw ValidationError("Must provide a non-empty value for 'named'.")
                }
            }
        }
        
        func run() async throws {
            let catalog = try catalog(forStorage: storage, debug: noisy)
            
            var projects: [Project] = []
            
            if let named = self.named {
                projects = try catalog.projects(matching: GenericProjectQuery.named(named))
            } else {
                projects = try catalog.projects()
            }
            
            let table = try MarkdownTable(
                content: projects,
                paths: [\.id.uuidString, \.name],
                headers: ["Project.ID", "Name"]
            )
            
            print(table)
        }
    }
    
    struct ExpressionCommand: CatalogCommand {
        
        static let configuration = CommandConfiguration(
            commandName: "expression",
            abstract: "Query for expressions in the catalog.",
            version: "1.0.0",
            helpNames: .shortAndLong
        )
        
        @Option(help: "Unique key used in localization files.")
        var key: String?
        
        @Option(help: "A descriptive human-readable identification.")
        var named: String?
        
        @Option(help: "Storage mechanism used to persist the catalog. [sqlite, filesystem]")
        var storage: Catalog.Storage = .default
        
        @Option(help: "Path to catalog to use in place of the application library.")
        var path: String?
        
        @Flag(help: "Outputs detailed execution")
        var noisy: Bool = false
        
        func validate() throws {
            if let named = self.named {
                guard !named.isEmpty else {
                    throw ValidationError("Must provide a non-empty value for 'named'.")
                }
            }
        }
        
        func run() async throws {
            let catalog = try catalog(forStorage: storage, debug: noisy)
            
            var expressions: [TranslationCatalog.Expression] = []
            
            if let key = self.key {
                expressions = try catalog.expressions(matching: GenericExpressionQuery.key(key))
            } else if let named = self.named {
                expressions = try catalog.expressions(matching: GenericExpressionQuery.named(named))
            } else {
                expressions = try catalog.expressions()
            }
            
            let table = try MarkdownTable(
                content: expressions,
                paths: [\.id.uuidString, \.key, \.name, \.defaultLanguage.rawValue, \.context, \.feature],
                headers: ["Expression.ID", "Key", "Name", "Default Language", "Context", "Feature"]
            )
            
            print(table)
        }
    }
}
