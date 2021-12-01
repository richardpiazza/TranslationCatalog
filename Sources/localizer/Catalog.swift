import Foundation
import ArgumentParser

struct Catalog: ParsableCommand {
    
    static var configuration: CommandConfiguration = .init(
        commandName: "catalog",
        abstract: "Interact with the translation catalog.",
        discussion: "",
        version: "1.0.0",
        shouldDisplay: true,
        subcommands: [
            Import.self,
            Export.self,
            Generate.self,
            Query.self,
            Insert.self,
            Update.self,
            Delete.self
        ],
        defaultSubcommand: nil,
        helpNames: .shortAndLong
    )
}

protocol CatalogCommand: ParsableCommand {
    var path: String? { get }
}

extension CatalogCommand {
    func catalogURL() throws -> URL {
        if let path = path, !path.isEmpty {
            return try FileManager.default.url(for: path)
        } else {
            return try FileManager.default.catalogURL()
        }
    }
}
