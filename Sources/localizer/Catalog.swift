import Foundation
import ArgumentParser
import TranslationCatalog
import TranslationCatalogSQLite
import TranslationCatalogFilesystem

struct Catalog: AsyncParsableCommand {
    
    enum Storage: String, CaseIterable, Codable, ExpressibleByArgument {
        case sqlite
        case filesystem
        
        static var `default`: Storage = .sqlite
    }
    
    @available(*, deprecated, renamed: "TranslationCatalogIO.FileFormat")
    enum Format: String, ExpressibleByArgument {
        case android
        case apple
        case json
        
        init?(extension: String) {
            switch `extension`.lowercased() {
            case "xml":
                self = .android
            case "strings":
                self = .apple
            case "json":
                self = .json
            default:
                return nil
            }
        }
    }
    
    static var configuration: CommandConfiguration = .init(
        commandName: "catalog",
        abstract: "Interact with the translation catalog.",
        usage: nil,
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

protocol CatalogCommand: AsyncParsableCommand {
    var storage: Catalog.Storage { get }
    var path: String? { get }
}

extension CatalogCommand {
    func catalogURL(forStorage storage: Catalog.Storage) throws -> URL {
        switch storage {
        case .sqlite:
            if let path = path, !path.isEmpty {
                return try FileManager.default.url(for: path)
            } else {
                return try FileManager.default.catalogURL()
            }
        case .filesystem:
            if let path = path, !path.isEmpty {
                return try FileManager.default.directoryURL(for: path)
            } else {
                return try FileManager.default.catalogDirectoryURL()
            }
        }
    }
    
    func catalog(forStorage storage: Catalog.Storage, debug: Bool = false) throws -> TranslationCatalog.Catalog {
        let url = try catalogURL(forStorage: storage)
        
        let catalog: TranslationCatalog.Catalog
        
        switch storage {
        case .sqlite:
            let sqliteCatalog = try SQLiteCatalog(url: url)
            if debug {
                sqliteCatalog.statementHook = { (sql) in
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
