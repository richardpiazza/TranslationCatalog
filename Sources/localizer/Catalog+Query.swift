import ArgumentParser
import Foundation
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
                ExpressionCommand.self,
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

        @Option(help: "Storage mechanism used to persist the catalog. (*default) [core-data, filesystem, *sqlite]")
        var storage: Catalog.Storage = .default

        @Option(help: "Path to catalog to use in place of the application library.")
        var path: String?

        @Flag(help: "Additional execution details in the standard output.")
        var verbose: Bool = false

        func validate() throws {
            if let named {
                guard !named.isEmpty else {
                    throw ValidationError("Must provide a non-empty value for 'named'.")
                }
            }
        }

        func run() async throws {
            let catalog = try catalog(forStorage: storage, verbose: verbose)

            var projects: [Project] = []

            if let named {
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

        @Option(help: "Value used as a base translation, expressed in the default language code.")
        var value: String?

        @Option(help: "A descriptive human-readable identification.")
        var named: String?

        @Option(help: "Identifier of the project to which the output belongs.")
        var projectId: TranslationCatalog.Project.ID?

        @Option(help: "Matches expressions having only the specific Language Code.")
        var languageCode: Locale.LanguageCode?

        @Option(help: "Matches expressions having the specified Locale.")
        var locale: Locale?

        @Option(help: "Matches expressions with translations matching a specific state.")
        var translationState: TranslationState?

        @Option(help: "Storage mechanism used to persist the catalog. [sqlite, filesystem]")
        var storage: Catalog.Storage = .default

        @Option(help: "Path to catalog to use in place of the application library.")
        var path: String?

        @Flag(help: "Additional execution details in the standard output.")
        var verbose: Bool = false

        func validate() throws {
            if let named {
                guard !named.isEmpty else {
                    throw ValidationError("Must provide a non-empty value for 'named'.")
                }
            }
        }

        func run() async throws {
            let catalog = try catalog(forStorage: storage, verbose: verbose)

            var expressions: [TranslationCatalog.Expression] = []

            if let key {
                expressions = try catalog.expressions(matching: GenericExpressionQuery.key(key))
            } else if let value {
                expressions = try catalog.expressions(matching: GenericExpressionQuery.value(value))
            } else if let named {
                expressions = try catalog.expressions(matching: GenericExpressionQuery.named(named))
            } else if let projectId {
                expressions = try catalog.expressions(matching: GenericExpressionQuery.projectId(projectId))
            } else if let languageCode {
                expressions = try catalog.expressions(matching: GenericExpressionQuery.translationsHavingOnly(languageCode))
            } else if let locale {
                guard let languageCode = locale.language.languageCode else {
                    throw ValidationError("Invalid Locale Language Code")
                }

                expressions = try catalog.expressions(
                    matching: GenericExpressionQuery.translationsHaving(
                        languageCode,
                        locale.language.script,
                        locale.language.region
                    )
                )
            } else if let translationState {
                expressions = try catalog.expressions(matching: GenericExpressionQuery.translationsHavingState(translationState))
            } else {
                expressions = try catalog.expressions()
            }

            let table = try MarkdownTable(
                content: expressions,
                paths: [\.id.uuidString, \.key, \.defaultValue, \.defaultLanguageCode.identifier, \.name, \.context, \.feature],
                headers: ["Expression.ID", "Key", "Default Value", "Default Language", "Name", "Context", "Feature"]
            )

            print(table)
        }
    }
}
