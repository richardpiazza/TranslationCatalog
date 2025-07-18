import ArgumentParser
import Foundation
import LocaleSupport
import TranslationCatalog

extension Catalog {
    struct Insert: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "insert",
            abstract: "Adds a single entity to the catalog.",
            version: "1.0.0",
            subcommands: [
                ProjectCommand.self,
                ExpressionCommand.self,
                TranslationCommand.self,
                KeyValueCommand.self,
            ],
            helpNames: .shortAndLong
        )
    }
}

extension Catalog.Insert {
    struct ProjectCommand: CatalogCommand {

        static let configuration = CommandConfiguration(
            commandName: "project",
            abstract: "Add a Project to the catalog.",
            version: "1.0.0",
            helpNames: .shortAndLong
        )

        @Argument(help: "Name that identifies a collection of expressions.")
        var name: String

        @Option(help: "Storage mechanism used to persist the catalog. (*default) [core-data, filesystem, *sqlite]")
        var storage: Catalog.Storage = .default

        @Option(help: "Path to catalog to use in place of the application library.")
        var path: String?

        func validate() throws {
            guard !name.isEmpty else {
                throw ValidationError("Must provide a non-empty 'name'.")
            }
        }

        func run() async throws {
            print("Inserting Project '\(name)'…")

            let catalog = try catalog(forStorage: storage)

            let entity = Project(id: .zero, name: name)
            let id = try catalog.createProject(entity)
            print("Project '\(name)' inserted with ID '\(id)'.")
        }
    }

    struct ExpressionCommand: CatalogCommand {

        static let configuration = CommandConfiguration(
            commandName: "expression",
            abstract: "Add an Expression to the catalog.",
            version: "1.0.0",
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

        func run() async throws {
            let catalog = try catalog(forStorage: storage)

            let expression = Expression(
                id: .zero,
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

    struct TranslationCommand: CatalogCommand {

        static let configuration = CommandConfiguration(
            commandName: "translation",
            abstract: "Add a Translation to the catalog.",
            version: "1.0.0",
            helpNames: .shortAndLong
        )

        @Argument(help: "ID of the Expression to which this translation links.")
        var expression: TranslationCatalog.Expression.ID

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

        func run() async throws {
            let catalog = try catalog(forStorage: storage)

            let translation = Translation(
                id: .zero,
                expressionId: expression,
                languageCode: language,
                scriptCode: script,
                regionCode: region,
                value: value
            )

            let id = try catalog.createTranslation(translation)
            print("Inserted Translation [\(id)] '\(value)'")
        }
    }

    struct KeyValueCommand: CatalogCommand {

        static let configuration = CommandConfiguration(
            commandName: "key-value",
            abstract: "Quickly add a Expression=Translation pairing to the catalog.",
            version: "1.0.0",
            helpNames: .shortAndLong
        )

        @Argument(help: "Unique key that identifies the expression in translation files.")
        var key: String

        @Argument(help: "The translated string.")
        var value: String

        @Option(help: "Storage mechanism used to persist the catalog. [sqlite, filesystem]")
        var storage: Catalog.Storage = .default

        @Option(help: "Path to catalog to use in place of the application library.")
        var path: String?

        func run() async throws {
            let catalog = try catalog(forStorage: storage)

            let expression = Expression(
                id: .zero,
                key: key,
                name: key,
                defaultLanguage: .default,
                context: nil,
                feature: nil,
                translations: []
            )

            let expressionId = try catalog.createExpression(expression)

            let translation = Translation(
                id: .zero,
                expressionId: expressionId,
                languageCode: .default,
                scriptCode: nil,
                regionCode: nil,
                value: value
            )

            let translationId = try catalog.createTranslation(translation)

            print("Inserted Expression / Translation [\(expressionId) / \(translationId)]")
            print("\(key)='\(value)'")
        }
    }
}
