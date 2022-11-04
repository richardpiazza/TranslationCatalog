import ArgumentParser
import Foundation
import LocaleSupport
import TranslationCatalog

extension Catalog {
    struct Insert: ParsableCommand {
        static var configuration: CommandConfiguration = .init(
            commandName: "insert",
            abstract: "Adds a single entity to the catalog.",
            discussion: "",
            version: "1.0.0",
            shouldDisplay: true,
            subcommands: [
                ProjectCommand.self,
                ExpressionCommand.self,
                TranslationCommand.self
            ],
            defaultSubcommand: nil,
            helpNames: .shortAndLong
        )
    }
}

extension Catalog.Insert {
    struct ProjectCommand: CatalogCommand {
        
        static var configuration: CommandConfiguration = .init(
            commandName: "project",
            abstract: "Add a Project to the catalog.",
            discussion: "",
            version: "1.0.0",
            shouldDisplay: true,
            subcommands: [],
            defaultSubcommand: nil,
            helpNames: .shortAndLong
        )
        
        @Argument(help: "Name that identifies a collection of expressions.")
        var name: String
        
        @Option(help: "Storage mechanism used to persist the catalog. [sqlite, filesystem]")
        var storage: Catalog.Storage = .default
        
        @Option(help: "Path to catalog to use in place of the application library.")
        var path: String?
        
        func validate() throws {
            guard !name.isEmpty else {
                throw ValidationError("Must provide a non-empty 'name'.")
            }
        }
        
        func run() throws {
            print("Inserting Project '\(name)'…")
            
            let catalog = try catalog(forStorage: storage)
            
            let entity = Project(uuid: .zero, name: name, expressions: [])
            let id = try catalog.createProject(entity)
            print("Project '\(name)' inserted with ID '\(id)'.")
        }
    }
    
    struct ExpressionCommand: CatalogCommand {
        
        static var configuration: CommandConfiguration = .init(
            commandName: "expression",
            abstract: "Add an Expression to the catalog.",
            discussion: "",
            version: "1.0.0",
            shouldDisplay: true,
            subcommands: [],
            defaultSubcommand: nil,
            helpNames: .shortAndLong
        )
        
        @Argument(help: "Unique key that identifies the expression in translation files.")
        var key: String
        
        @Argument(help: "Name that identifies a collection of translations.")
        var name: String
        
        @Option(help: "The default/development language code.")
        var defaultLanguage: LanguageCode = .default
        
        @Option(help: "Contextual information that guides translators.")
        var context: String?
        
        @Option(help: "Optional grouping identifier.")
        var feature: String?
        
        @Option(help: "Storage mechanism used to persist the catalog. [sqlite, filesystem]")
        var storage: Catalog.Storage = .default
        
        @Option(help: "Path to catalog to use in place of the application library.")
        var path: String?
        
        func validate() throws {
            guard !key.isEmpty else {
                throw ValidationError("Must provide a non-empty 'key'.")
            }
            
            guard !name.isEmpty else {
                throw ValidationError("Must provide a non-empty 'name'.")
            }
        }
        
        func run() throws {
            let catalog = try catalog(forStorage: storage)
            
            let expression = Expression(
                uuid: .zero,
                key: key,
                name: name,
                defaultLanguage: defaultLanguage,
                context: context,
                feature: feature,
                translations: []
            )
            
            let id = try catalog.createExpression(expression)
            print("Inserted Expression [\(id)] '\(expression.name)'")
        }
    }
}

extension Catalog.Insert {
    struct TranslationCommand: CatalogCommand {
        
        static var configuration: CommandConfiguration = .init(
            commandName: "translation",
            abstract: "Add a Translation to the catalog.",
            discussion: "",
            version: "1.0.0",
            shouldDisplay: true,
            subcommands: [],
            defaultSubcommand: nil,
            helpNames: .shortAndLong
        )
        
        @Argument(help: "ID of the Expression to which this translation links.")
        var expression: Expression.ID
        
        @Argument(help: "Language of the translation.")
        var language: LanguageCode
        
        @Argument(help: "The translated string.")
        var value: String
        
        @Option(help: "Script code specifier.")
        var script: ScriptCode?
        
        @Option(help: "Region code specifier.")
        var region: RegionCode?
        
        @Option(help: "Storage mechanism used to persist the catalog. [sqlite, filesystem]")
        var storage: Catalog.Storage = .default
        
        @Option(help: "Path to catalog to use in place of the application library.")
        var path: String?
        
        func run() throws {
            let catalog = try catalog(forStorage: storage)
            
            let translation = Translation(
                uuid: .zero,
                expressionID: expression,
                languageCode: language,
                scriptCode: script,
                regionCode: region,
                value: value
            )
            
            let id = try catalog.createTranslation(translation)
            print("Inserted Translation [\(id)] '\(value)'")
        }
    }
}
