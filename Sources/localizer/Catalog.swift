import ArgumentParser
import Foundation
import TranslationCatalog
import TranslationCatalogCoreData
import TranslationCatalogFilesystem
import TranslationCatalogSQLite

struct Catalog: AsyncParsableCommand {

    enum Storage: String, CaseIterable, Codable, ExpressibleByArgument {
        #if os(macOS)
        case coreData = "core-data"
        #endif
        case filesystem
        case sqlite

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
        #if os(macOS)
        case .coreData:
            if let path, !path.isEmpty {
                return try FileManager.default.url(for: path)
            } else {
                return try FileManager.default.catalogURL()
            }
        #endif
        case .filesystem:
            if let path, !path.isEmpty {
                return try FileManager.default.directoryURL(for: path)
            } else {
                return try FileManager.default.catalogDirectoryURL()
            }
        case .sqlite:
            if let path, !path.isEmpty {
                return try FileManager.default.url(for: path)
            } else {
                return try FileManager.default.catalogURL()
            }
        }
    }

    func catalog(forStorage storage: Catalog.Storage, verbose: Bool = false) throws -> TranslationCatalog.Catalog {
        let url = try catalogURL(forStorage: storage)

        let catalog: TranslationCatalog.Catalog

        switch storage {
        #if os(macOS)
        case .coreData:
            catalog = try CoreDataCatalog(url: url)
        #endif
        case .filesystem:
            catalog = try FilesystemCatalog(url: url)
        case .sqlite:
            let sqliteCatalog = try SQLiteCatalog(url: url)
            if verbose {
                sqliteCatalog.statementHook = { sql in
                    print("======SQL======\n\(sql)\n======___======\n")
                }
            }
            catalog = sqliteCatalog
        }

        return catalog
    }
}
