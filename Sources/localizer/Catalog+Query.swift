import ArgumentParser
import TranslationCatalog
import TranslationCatalogSQLite
import Foundation

extension Catalog {
    struct Query: ParsableCommand {
        static var configuration: CommandConfiguration = .init(
            commandName: "query",
            abstract: "Perform queries against the catalog.",
            discussion: "",
            version: "1.0.0",
            shouldDisplay: true,
            subcommands: [
                ProjectCommand.self,
                ExpressionCommand.self
            ],
            defaultSubcommand: nil,
            helpNames: .shortAndLong
        )
    }
}

extension Catalog.Query {
    struct ProjectCommand: CatalogCommand {
        
        static var configuration: CommandConfiguration = .init(
            commandName: "project",
            abstract: "Query for projects in the catalog.",
            discussion: "",
            version: "1.0.0",
            shouldDisplay: true,
            subcommands: [],
            defaultSubcommand: nil,
            helpNames: .shortAndLong
        )
        
        @Option(help: "Partial name search")
        var named: String?
        
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
        
        func run() throws {
            let catalog = try SQLiteCatalog(url: try catalogURL())
            if noisy {
                catalog.statementHook = { (sql) in
                    print("======SQL======\n\(sql)\n======___======\n")
                }
            }
            
            var projects: [Project] = []
            
            if let named = self.named {
                projects = try catalog.projects(matching: GenericProjectQuery.named(named))
            } else {
                projects = try catalog.projects()
            }
            
            var table = MarkdownTable("Project.ID", "Name")
            projects.forEach {
                table.addContent($0.id.uuidString, $0.name)
            }
            
            print(table)
        }
    }
    
    struct ExpressionCommand: CatalogCommand {
        
        static var configuration: CommandConfiguration = .init(
            commandName: "expression",
            abstract: "Query for expressions in the catalog.",
            discussion: "",
            version: "1.0.0",
            shouldDisplay: true,
            subcommands: [],
            defaultSubcommand: nil,
            helpNames: .shortAndLong
        )
        
        @Option(help: "Unique key used in localization files.")
        var key: String?
        
        @Option(help: "A descriptive human-readable identification.")
        var named: String?
        
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
        
        func run() throws {
            let catalog = try SQLiteCatalog(url: try catalogURL())
            if noisy {
                catalog.statementHook = { (sql) in
                    print("======SQL======\n\(sql)\n======___======\n")
                }
            }
            
            var expressions: [Expression] = []
            
            if let key = self.key {
                expressions = try catalog.expressions(matching: GenericExpressionQuery.key(key))
            } else if let named = self.named {
                expressions = try catalog.expressions(matching: GenericExpressionQuery.named(named))
            } else {
                expressions = try catalog.expressions()
            }
            
            var table = MarkdownTable("Expression.ID", "Key", "Name", "Default Language", "Context", "Feature")
            expressions.forEach {
                table.addContent($0.id.uuidString, $0.key, $0.name, $0.defaultLanguage.rawValue, ($0.context ?? ""), ($0.feature ?? ""))
            }
            print(table)
        }
    }
}
