import ArgumentParser
import Foundation
import TranslationCatalog
import TranslationCatalogFilesystem
import TranslationCatalogIO
import TranslationCatalogSQLite

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

        @Option(help: "Storage mechanism used to persist the catalog. [sqlite, filesystem]")
        var storage: Catalog.Storage = .default

        @Option(help: "Path to catalog to use in place of the application library.")
        var path: String?

        func run() async throws {
            let url = try catalogURL(forStorage: storage)

            let expressions: [TranslationCatalog.Expression]

            switch storage {
            case .sqlite:
                let catalog = try SQLiteCatalog(url: url)
                expressions = try catalog.expressions(matching: SQLiteCatalog.ExpressionQuery.hierarchy).sorted(by: { $0.name < $1.name })
            case .filesystem:
                let catalog = try FilesystemCatalog(url: url)
                expressions = try catalog.expressions().sorted(by: { $0.name < $1.name })
            }

            let render = try ExpressionRenderer.render(expressions: expressions, renderFormat: format)
            print(render)
        }
    }
}
