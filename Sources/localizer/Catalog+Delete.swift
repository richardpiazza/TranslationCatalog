import ArgumentParser
import Foundation
import TranslationCatalog

extension Catalog {
    struct Delete: AsyncParsableCommand {
        static var configuration: CommandConfiguration = .init(
            commandName: "delete",
            abstract: "Remove a single entity in the catalog.",
            usage: nil,
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
            usage: nil,
            discussion: "",
            version: "1.0.0",
            shouldDisplay: true,
            subcommands: [],
            defaultSubcommand: nil,
            helpNames: .shortAndLong
        )
        
        @Argument(help: "Unique ID of the Project.")
        var id: Project.ID
        
        @Option(help: "Storage mechanism used to persist the catalog. [sqlite, filesystem]")
        var storage: Catalog.Storage = .default
        
        @Option(help: "Path to catalog to use in place of the application library.")
        var path: String?
        
        @Flag(help: "Outputs additional details about the execution of the command.")
        var debug: Bool = false
        
        func run() async throws {
            let catalog = try catalog(forStorage: storage, debug: debug)
            
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
            usage: nil,
            discussion: "",
            version: "1.0.0",
            shouldDisplay: true,
            subcommands: [],
            defaultSubcommand: nil,
            helpNames: .shortAndLong
        )
        
        @Argument(help: "Unique ID of the Expression.")
        var id: Expression.ID
        
        @Option(help: "Storage mechanism used to persist the catalog. [sqlite, filesystem]")
        var storage: Catalog.Storage = .default
        
        @Option(help: "Path to catalog to use in place of the application library.")
        var path: String?
        
        func run() async throws {
            let catalog = try catalog(forStorage: storage)
            try catalog.deleteExpression(id)
        }
    }
    
    struct TranslationEntity: CatalogCommand {
        
        static var configuration: CommandConfiguration = .init(
            commandName: "translation",
            abstract: "Delete a Translation from the catalog.",
            usage: nil,
            discussion: "",
            version: "1.0.0",
            shouldDisplay: true,
            subcommands: [],
            defaultSubcommand: nil,
            helpNames: .shortAndLong
        )
        
        @Argument(help: "Unique ID of the Translation.")
        var id: TranslationCatalog.Translation.ID
        
        @Option(help: "Storage mechanism used to persist the catalog. [sqlite, filesystem]")
        var storage: Catalog.Storage = .default
        
        @Option(help: "Path to catalog to use in place of the application library.")
        var path: String?
        
        func run() async throws {
            let catalog = try catalog(forStorage: storage)
            try catalog.deleteTranslation(id)
        }
    }
}
