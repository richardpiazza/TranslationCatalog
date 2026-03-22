import Foundation
import Testing
@testable @preconcurrency import TranslationCatalog
#if canImport(CoreData)
@testable import TranslationCatalogCoreData
#endif
@testable import TranslationCatalogFilesystem
@testable import TranslationCatalogSQLite

struct TestContainer {

    let catalogs: [any Catalog]

    init(prepared: Bool = false) throws {
        var catalogs: [any Catalog] = []
        #if canImport(CoreData)
        try catalogs.append(CoreDataCatalog())
        #endif
        try catalogs.append(DirectoryCatalog(url: Self.randomDirectoryUrl()))
        try catalogs.append(SQLiteCatalog(url: Self.randomSQLiteUrl()))

        if prepared {
            try catalogs.forEach {
                try $0.createProject(.project1)
                try $0.createProject(.project2)
                try $0.createProject(.project3)
                try $0.createExpression(.expression4)
            }
        }

        self.catalogs = catalogs
    }

    func recycle() throws {
        for catalog in catalogs {
            switch catalog {
            #if canImport(CoreData)
            case _ as CoreDataCatalog:
                // In-Memory Catalog
                break
            #endif
            case let directoryCatalog as DirectoryCatalog:
                let url = directoryCatalog.url
                try FileManager.default.removeItem(at: url)
            case let sqliteCatalog as SQLiteCatalog:
                let url = sqliteCatalog.url
                try FileManager.default.removeItem(at: url)
            default:
                break
            }
        }
    }

    private static func randomSQLiteUrl() -> URL {
        let directory = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let path = "\(UUID().uuidString).sqlite"
        return URL(fileURLWithPath: path, relativeTo: directory)
    }

    private static func randomDirectoryUrl() -> URL {
        let directory = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let path = UUID().uuidString
        if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, visionOS 1.0, *) {
            return directory.appending(path: path, directoryHint: .isDirectory)
        } else {
            return directory.appendingPathComponent(path, isDirectory: true)
        }
    }
}
