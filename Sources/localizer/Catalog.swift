import ArgumentParser
import Foundation
import TranslationCatalog
import TranslationCatalogFilesystem
import TranslationCatalogSQLite

struct Catalog: AsyncParsableCommand {

    enum Storage: String, CaseIterable, Codable, ExpressibleByArgument {
        case sqlite
        case filesystem

        static var `default`: Storage = .sqlite
    }

    static let configuration = CommandConfiguration(
        commandName: "catalog",
        abstract: "Interact with the translation catalog.",
        version: "1.0.0",
        subcommands: [
            Import.self,
            Export.self,
            Generate.self,
            Query.self,
            Insert.self,
            Update.self,
            Delete.self,
        ],
        helpNames: .shortAndLong
    )
}

protocol CatalogCommand: AsyncParsableCommand {
    var storage: Catalog.Storage { get }
    var path: String? { get }
}

extension CatalogCommand {
    func catalogURL(forStorage storage: Catalog.Storage) throws -> URL {
        switch storage {
        case .sqlite:
            if let path, !path.isEmpty {
                try FileManager.default.url(for: path)
            } else {
                try FileManager.default.catalogURL()
            }
        case .filesystem:
            if let path, !path.isEmpty {
                try FileManager.default.directoryURL(for: path)
            } else {
                try FileManager.default.catalogDirectoryURL()
            }
        }
    }

    func catalog(forStorage storage: Catalog.Storage, verbose: Bool = false) throws -> TranslationCatalog.Catalog {
        let url = try catalogURL(forStorage: storage)

        let catalog: TranslationCatalog.Catalog

        switch storage {
        case .sqlite:
            let sqliteCatalog = try SQLiteCatalog(url: url)
            if verbose {
                sqliteCatalog.statementHook = { sql in
                    print("======SQL======\n\(sql)\n======___======\n")
                }
            }
            catalog = sqliteCatalog
        case .filesystem:
            catalog = try FilesystemCatalog(url: url)
        }

        return catalog
    }
}
