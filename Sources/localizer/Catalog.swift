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
            Export.self,
            Delete.self,
            Generate.self,
            Import.self,
            Insert.self,
            Query.self,
            Update.self,
        ],
        helpNames: .shortAndLong
    )
}

protocol CatalogCommand: AsyncParsableCommand {
    var storage: Catalog.Storage { get }
    var path: String? { get }
    var verbose: Bool { get }
}

extension CatalogCommand {
    func catalog() throws -> TranslationCatalog.Catalog {
        let url = switch storage {
        #if os(macOS)
        case .coreData:
            if let path, !path.isEmpty {
                URL(filePath: path, directoryHint: .notDirectory)
            } else {
                try FileManager.default.catalogURL()
            }
        #endif
        case .filesystem:
            if let path, !path.isEmpty {
                URL(filePath: path, directoryHint: .isDirectory)
            } else {
                try FileManager.default.catalogDirectoryURL()
            }
        case .sqlite:
            if let path, !path.isEmpty {
                URL(filePath: path, directoryHint: .notDirectory)
            } else {
                try FileManager.default.catalogURL()
            }
        }

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
