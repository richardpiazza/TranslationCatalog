import ArgumentParser
import Foundation
import TranslationCatalog

extension Catalog {
    struct Delete: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "delete",
            abstract: "Remove a single entity in the catalog.",
            version: "1.0.0",
            subcommands: [
                ProjectEntity.self,
                ExpressionEntity.self,
                TranslationEntity.self
            ],
            helpNames: .shortAndLong
        )
    }
}

extension Catalog.Delete {
    struct ProjectEntity: CatalogCommand {
        
        static let configuration = CommandConfiguration(
            commandName: "project",
            abstract: "Delete a Project from the catalog.",
            version: "1.0.0",
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
        
        static let configuration = CommandConfiguration(
            commandName: "expression",
            abstract: "Delete a Expression from the catalog.",
            version: "1.0.0",
            helpNames: .shortAndLong
        )
        
        @Argument(help: "Unique ID of the Expression.")
        var id: TranslationCatalog.Expression.ID
        
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
        
        static let configuration = CommandConfiguration(
            commandName: "translation",
            abstract: "Delete a Translation from the catalog.",
            version: "1.0.0",
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
