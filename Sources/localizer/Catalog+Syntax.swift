import ArgumentParser
import Foundation
import LocaleSupport
import TranslationCatalog
import TranslationCatalogIO

extension Catalog {
    struct Syntax: CatalogCommand {

        static let configuration: CommandConfiguration = CommandConfiguration(
            commandName: "syntax",
            abstract: "Create a enumerated syntax tree.",
            discussion: """
            Generate an enumerated reference to strings. For example:

            (Using Style: 'locale-support', default)
            import LocaleSupport
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

            (Using Style: 'swift-ui')
            import SwiftUI
            extension LocalizedStringKey {
                /// Title for account screen.
                static let account: LocalizedStringKey = "ACCOUNT"

                enum Account {
                    /// Action to navigate to the previous screen.
                    static let back = "ACCOUNT_BACK"
                }
            }
            """,
            version: "1.0.0",
            helpNames: .shortAndLong,
        )

        @Option(help: "Name used for the root declaration. (Default 'LocalizedStrings')")
        var name: String?

        @Option(help: "Identifier of the project for which to limit results.")
        var projectId: Project.ID?

        @Option(help: "Storage mechanism used to persist the catalog. (*default) [core-data, filesystem, *sqlite]")
        var storage: Catalog.Storage = .default

        @Option(help: "Path to catalog to use in place of the application library.")
        var path: String?

        @Option(help: "Generated reference style.")
        var style: SyntaxStyle = .localeSupport

        @Flag(help: "Reduce the instance of single-content nodes.")
        var compressed: Bool = false

        @Flag(help: "Phantom nodes (Single-Node Enum) will not be merged when compression enabled.")
        var excludePhantoms: Bool = false

        @Flag(help: "Orphaned nodes (Single-Content Enum) will not be merged when compression enabled.")
        var excludeOrphans: Bool = false

        @Flag(help: "Additional execution details in the standard output.")
        var verbose: Bool = false

        func run() async throws {
            let catalog = try catalog()
            let expressions: [TranslationCatalog.Expression] = if let id = projectId {
                try catalog.expressions(matching: GenericExpressionQuery.projectId(id))
            } else {
                try catalog.expressions()
            }

            var keyHierarchy = try KeyHierarchy.make(with: expressions)
            if compressed {
                try keyHierarchy.compress(
                    mergePhantoms: !excludePhantoms,
                    mergeOrphans: !excludeOrphans,
                )
            }

            let syntax = if let name, !name.isEmpty {
                keyHierarchy.syntaxTree(
                    style: style,
                    rootDeclaration: name,
                )
            } else {
                keyHierarchy.syntaxTree(
                    style: style,
                )
            }

            print(syntax)
        }
    }
}
