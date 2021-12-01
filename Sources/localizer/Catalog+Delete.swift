import ArgumentParser
import Foundation
import TranslationCatalog
import TranslationCatalogSQLite

extension Catalog {
    struct Delete: ParsableCommand {
        static var configuration: CommandConfiguration = .init(
            commandName: "delete",
            abstract: "Remove a single entity in the catalog.",
            discussion: "",
            version: "1.0.0",
            shouldDisplay: true,
            subcommands: [
                ProjectEntity.self,
                ExpressionEntity.self,
                TranslationEntity.self
            ],
            defaultSubcommand: nil,
            helpNames: .shortAndLong
        )
    }
}

extension Catalog.Delete {
    struct ProjectEntity: CatalogCommand {
        
        static var configuration: CommandConfiguration = .init(
            commandName: "project",
            abstract: "Delete a Project from the catalog.",
            discussion: "",
            version: "1.0.0",
            shouldDisplay: true,
            subcommands: [],
            defaultSubcommand: nil,
            helpNames: .shortAndLong
        )
        
        @Argument(help: "Unique ID of the Project.")
        var id: Project.ID
        
        @Option(help: "Path to catalog to use in place of the application library.")
        var path: String?
        
        @Flag(help: "Outputs additional details about the execution of the command.")
        var debug: Bool = false
        
        func run() throws {
            let catalog = try SQLiteCatalog(url: try catalogURL())
            if debug {
                catalog.statementHook = { (sql) in
                    print("======SQL======\n\(sql)\n======___======\n")
                }
            }
            
            guard let project = try? catalog.project(id) else {
                Self.exit(withError: ValidationError("Unknown Project '\(id)'."))
            }
            
            print("Removing project '\(project.name)' [\(project.id)].")
            try catalog.deleteProject(id)
            print("Project '\(project.name)' deleted.")
        }
    }
    
    struct ExpressionEntity: CatalogCommand {
        
        static var configuration: CommandConfiguration = .init(
            commandName: "expression",
            abstract: "Delete a Expression from the catalog.",
            discussion: "",
            version: "1.0.0",
            shouldDisplay: true,
            subcommands: [],
            defaultSubcommand: nil,
            helpNames: .shortAndLong
        )
        
        @Argument(help: "Unique ID of the Expression.")
        var id: Expression.ID
        
        @Option(help: "Path to catalog to use in place of the application library.")
        var path: String?
        
        func run() throws {
            let catalog = try SQLiteCatalog(url: try catalogURL())
            try catalog.deleteExpression(id)
        }
    }
    
    struct TranslationEntity: CatalogCommand {
        
        static var configuration: CommandConfiguration = .init(
            commandName: "translation",
            abstract: "Delete a Translation from the catalog.",
            discussion: "",
            version: "1.0.0",
            shouldDisplay: true,
            subcommands: [],
            defaultSubcommand: nil,
            helpNames: .shortAndLong
        )
        
        @Argument(help: "Unique ID of the Translation.")
        var id: TranslationCatalog.Translation.ID
        
        @Option(help: "Path to catalog to use in place of the application library.")
        var path: String?
        
        func run() throws {
            let catalog = try SQLiteCatalog(url: try catalogURL())
            try catalog.deleteTranslation(id)
        }
    }
}
