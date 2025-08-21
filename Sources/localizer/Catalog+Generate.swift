import ArgumentParser
import Foundation
import TranslationCatalog
import TranslationCatalogIO

extension Catalog {
    struct Generate: CatalogCommand {

        static let configuration = CommandConfiguration(
            commandName: "generate",
            abstract: "Generate a viewable document using the strings catalog.",
            discussion: """
            Available formats: \(RenderFormat.allCases.map(\.rawValue).joined(separator: " "))
            """,
            version: "1.0.0",
            helpNames: .shortAndLong
        )

        @Argument(help: "The export format")
        var format: RenderFormat

        @Option(help: "Storage mechanism used to persist the catalog. (*default) [core-data, filesystem, *sqlite]")
        var storage: Catalog.Storage = .default

        @Option(help: "Path to catalog to use in place of the application library.")
        var path: String?

        @Flag(help: "Additional execution details in the standard output.")
        var verbose: Bool = false

        func run() async throws {
            let catalog = try catalog()
            let expressions = try catalog.expressions()
            let sortedExpressions = expressions.sorted(by: { $0.key < $1.key })
            let expressionsWithTranslations = try sortedExpressions.map { expression in
                let translations = try catalog.translations(matching: GenericTranslationQuery.expressionId(expression.id))
                return TranslationCatalog.Expression(
                    expression: expression,
                    translations: translations
                )
            }
            let render = try ExpressionRenderer.render(expressions: expressionsWithTranslations, renderFormat: format)
            print(render)
        }
    }
}
