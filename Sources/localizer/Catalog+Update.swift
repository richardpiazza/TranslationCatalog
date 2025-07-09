import ArgumentParser
import Foundation
import LocaleSupport
import TranslationCatalog

extension Catalog {
    struct Update: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "update",
            abstract: "Update a single entity in the catalog.",
            version: "1.0.0",
            subcommands: [
                ProjectCommand.self,
                ExpressionCommand.self,
                TranslationCommand.self,
            ],
            helpNames: .shortAndLong
        )
    }
}

extension Catalog.Update {
    struct ProjectCommand: CatalogCommand {

        static let configuration = CommandConfiguration(
            commandName: "project",
            abstract: "Update a Project in the catalog.",
            version: "1.0.0",
            helpNames: .shortAndLong
        )

        @Argument(help: "Unique ID of the Project.")
        var id: Project.ID

        @Option(help: "Name that identifies a collection of expressions.")
        var name: String?

        @Option(help: "Adds an expression to a project.")
        var linkExpression: TranslationCatalog.Expression.ID?

        @Option(help: "Remove an expression from a project.")
        var unlinkExpression: TranslationCatalog.Expression.ID?

        @Option(help: "Storage mechanism used to persist the catalog. (*default) [core-data, filesystem, *sqlite]")
        var storage: Catalog.Storage = .default

        @Option(help: "Path to catalog to use in place of the application library.")
        var path: String?

        @Flag(help: "Additional execution details in the standard output.")
        var verbose: Bool = false

        func validate() throws {
            if let name {
                guard !name.isEmpty else {
                    throw ValidationError("Must provide a non-empty 'name'.")
                }
            }
        }

        func run() async throws {
            let catalog = try catalog(forStorage: storage, verbose: verbose)

            let project = try catalog.project(id)

            print("Updating Project '\(project.name) [\(project.id.uuidString)]'…")

            if let name {
                try catalog.updateProject(project.id, action: GenericProjectUpdate.name(name))
                print("Set Name to '\(name)'.")
            }

            if let link = linkExpression {
                try catalog.updateProject(project.id, action: GenericProjectUpdate.linkExpression(link))
                print("Created link to expression '\(link.uuidString)'.")
            }

            if let unlink = unlinkExpression {
                try catalog.updateProject(project.id, action: GenericProjectUpdate.unlinkExpression(unlink))
                print("Removed link from expression '\(unlink.uuidString)'.")
            }
        }
    }

    struct ExpressionCommand: CatalogCommand {

        static let configuration = CommandConfiguration(
            commandName: "expression",
            abstract: "Update an Expression in the catalog.",
            version: "1.0.0",
            helpNames: .shortAndLong
        )

        @Argument(help: "Unique ID of the Expression.")
        var id: TranslationCatalog.Expression.ID

        @Option(help: "Unique key that identifies the expression in translation files.")
        var key: String?

        @Option(help: "Name that identifies a collection of translations.")
        var name: String?

        @Option(help: "The default/development language code.")
        var defaultLanguage: LanguageCode?

        @Option(help: "Contextual information that guides translators.")
        var context: String?

        @Option(help: "Optional grouping identifier.")
        var feature: String?

        @Option(help: "Adds the expression to a project.")
        var linkProject: Project.ID?

        @Option(help: "Remove the expression from a project.")
        var unlinkProject: Project.ID?

        @Option(help: "Storage mechanism used to persist the catalog. [sqlite, filesystem]")
        var storage: Catalog.Storage = .default

        @Option(help: "Path to catalog to use in place of the application library.")
        var path: String?

        @Flag(help: "Additional execution details in the standard output.")
        var verbose: Bool = false

        func validate() throws {
            if let key {
                guard !key.isEmpty else {
                    throw ValidationError("Must provide a non-empty 'key'.")
                }
            }

            if let name {
                guard !name.isEmpty else {
                    throw ValidationError("Must provide a non-empty 'name'.")
                }
            }
        }

        func run() async throws {
            let catalog = try catalog(forStorage: storage, verbose: verbose)

            let expression = try catalog.expression(id)

            if let key, expression.key != key {
                try catalog.updateExpression(expression.id, action: GenericExpressionUpdate.key(key))
            }

            if let name, expression.name != name {
                try catalog.updateExpression(expression.id, action: GenericExpressionUpdate.name(name))
            }

            if let language = defaultLanguage, expression.defaultLanguage != language {
                try catalog.updateExpression(expression.id, action: GenericExpressionUpdate.defaultLanguage(language))
            }

            if let context, expression.context != context {
                let value = context.isEmpty ? nil : context
                try catalog.updateExpression(expression.id, action: GenericExpressionUpdate.context(value))
            }

            if let feature, expression.feature != feature {
                let value = feature.isEmpty ? nil : feature
                try catalog.updateExpression(expression.id, action: GenericExpressionUpdate.feature(value))
            }

            if let link = linkProject {
                try catalog.updateProject(link, action: GenericProjectUpdate.linkExpression(expression.id))
            }

            if let unlink = unlinkProject {
                try catalog.updateProject(unlink, action: GenericProjectUpdate.unlinkExpression(expression.id))
            }
        }
    }
}

extension Catalog.Update {
    struct TranslationCommand: CatalogCommand {

        static let configuration = CommandConfiguration(
            commandName: "translation",
            abstract: "Update a Translation in the catalog.",
            version: "1.0.0",
            helpNames: .shortAndLong
        )

        @Argument(help: "Unique ID of the Translation.")
        var id: TranslationCatalog.Translation.ID

        @Option(help: "Language of the translation.")
        var language: LanguageCode?

        @Option(help: "Script code specifier.")
        var script: ScriptCode?

        @Option(help: "Region code specifier.")
        var region: RegionCode?

        @Option(help: "The translated string.")
        var value: String?

        @Flag(help: "Forcefully drop the 'ScriptCode'. Does nothing when 'script' value provided.")
        var dropScript: Bool = false

        @Flag(help: "Forcefully drop the 'RegionCode'. Does nothing when 'region' value provided.")
        var dropRegion: Bool = false

        @Option(help: "Storage mechanism used to persist the catalog. [sqlite, filesystem]")
        var storage: Catalog.Storage = .default

        @Option(help: "Path to catalog to use in place of the application library.")
        var path: String?

        @Flag(help: "Additional execution details in the standard output.")
        var verbose: Bool = false

        func run() async throws {
            let catalog = try catalog(forStorage: storage, verbose: verbose)

            let translation = try catalog.translation(id)

            if let language, translation.languageCode != language {
                try catalog.updateTranslation(translation.id, action: GenericTranslationUpdate.language(language))
            }

            if let script, translation.scriptCode != script {
                try catalog.updateTranslation(translation.id, action: GenericTranslationUpdate.script(script))
            }

            if let region, translation.regionCode != region {
                try catalog.updateTranslation(translation.id, action: GenericTranslationUpdate.region(region))
            }

            if let value, translation.value != value {
                try catalog.updateTranslation(translation.id, action: GenericTranslationUpdate.value(value))
            }

            if dropScript, script == nil {
                try catalog.updateTranslation(translation.id, action: GenericTranslationUpdate.script(nil))
            }

            if dropRegion, region == nil {
                try catalog.updateTranslation(translation.id, action: GenericTranslationUpdate.region(nil))
            }
        }
    }
}
