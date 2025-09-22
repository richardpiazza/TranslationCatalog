import ArgumentParser
import Foundation
import LocaleSupport
import TranslationCatalog
import TranslationCatalogIO

extension Catalog {
    struct Syntax: CatalogCommand {

        static var configuration: CommandConfiguration = CommandConfiguration(
            commandName: "syntax",
            abstract: "Create a enumerated syntax tree.",
            discussion: """
            Generate a enumerate reference to strings. For example:
            
            enum LocalizedStrings: String, LocalizedStringConvertible {
                /// Title for account screen.
                case account = "Account"
            
                enum Account: String, LocalizedStringConvertible {
                    /// Action to navigate to the previous screen.
                    case back = "Back"
            
                    var prefix: String? {
                        "account"
                    }
                }
            }
            """,
            version: "1.0.0",
            helpNames: .shortAndLong
        )

        @Option(help: "Identifier of the project for which to limit results.")
        var projectId: Project.ID?

        @Option(help: "Storage mechanism used to persist the catalog. (*default) [core-data, filesystem, *sqlite]")
        var storage: Catalog.Storage = .default

        @Option(help: "Path to catalog to use in place of the application library.")
        var path: String?

        @Flag(help: "Additional execution details in the standard output.")
        var verbose: Bool = false

        func run() async throws {
            let catalog = try catalog()
            let expressions: [TranslationCatalog.Expression] = if let id = projectId {
                try catalog.expressions(matching: GenericExpressionQuery.projectId(id))
            } else {
                try catalog.expressions()
            }
            let keyHierarchy = KeyHierarchy.make(with: expressions)
            let data = keyHierarchy.localizedStringConvertible()
            let output = String(decoding: data, as: UTF8.self)
            print(output)
        }
    }
}
