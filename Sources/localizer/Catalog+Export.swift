import ArgumentParser
import Foundation
import LocaleSupport
import TranslationCatalog
import TranslationCatalogIO

extension Catalog {
    struct Export: CatalogCommand {

        static let configuration = CommandConfiguration(
            commandName: "export",
            abstract: "Export a translation file using the catalog.",
            discussion: """
            iOS Localization should contain all keys (expressions) for a given language. There is no native fallback
            mechanism to a 'base' language. (i.e. en-GB > en). Given this functionality, when exporting the 'apple'
            format, all expressions will be included (preferring the script/region).
            """,
            version: "1.0.0",
            helpNames: .shortAndLong
        )

        @Argument(help: "The export format [android-xml, apple-strings, json]")
        var format: FileFormat

        @Argument(help: "The language code to use for the strings.")
        var language: LanguageCode

        @Option(help: "The script code to use for the strings.")
        var script: ScriptCode?

        @Option(help: "The region code to use for the strings.")
        var region: RegionCode?

        @Option(help: "Identifier of the project for which to limit results.")
        var projectId: Project.ID?

        @Flag(help: "Indicates if a fallback translation should be used when no matching option is found.")
        var fallback: Bool = false

        @Option(help: "Storage mechanism used to persist the catalog. (*default) [core-data, filesystem, *sqlite]")
        var storage: Catalog.Storage = .default

        @Option(help: "Path to catalog to use in place of the application library.")
        var path: String?

        func run() async throws {
            let catalog = try catalog(forStorage: storage)
            let expressions = try queryExpressions(from: catalog, using: storage, projectId: projectId)
            let defaultOrFirst = (format == .appleStrings || fallback) ? true : false
            let data = try ExpressionEncoder.encodeTranslations(
                for: expressions,
                fileFormat: format,
                localeIdentifier: localeIdentifier,
                defaultOrFirst: defaultOrFirst
            )
            let output = String(data: data, encoding: .utf8) ?? ""

            print(output)
        }

        func queryExpressions(
            from catalog: TranslationCatalog.Catalog,
            using storage: Storage,
            projectId: Project.ID?
        ) throws -> [TranslationCatalog.Expression] {
            var expressions: [TranslationCatalog.Expression] = if let id = projectId {
                try catalog.expressions(matching: GenericExpressionQuery.projectId(id))
            } else {
                try catalog.expressions()
            }

            if storage == .filesystem {
                return expressions
            }

            let enumerated = expressions.enumerated()
            for (index, expression) in enumerated {
                let translations = try catalog.translations(matching: GenericTranslationQuery.expressionId(expression.id))
                expressions[index] = Expression(expression: expression, translations: translations)
            }

            return expressions
        }
    }
}

extension Catalog.Export: LocaleRepresentable {
    var languageCode: LocaleSupport.LanguageCode { language }
    var scriptCode: LocaleSupport.ScriptCode? { script }
    var regionCode: LocaleSupport.RegionCode? { region }
}
