import ArgumentParser
import Foundation
import LocaleSupport

extension Configure {
    struct Set: AsyncParsableCommand {

        static let configuration = CommandConfiguration(
            commandName: "set",
            abstract: "Sets configuration parameters.",
            version: "1.0.0",
            helpNames: .shortAndLong
        )

        @Option(help: "The default LanguageCode used when no other option is presented.")
        var defaultLanguage: LanguageCode?

        @Option(help: "The default RegionCode used when no other option is presented.")
        var defaultRegion: RegionCode?

        @Option(help: "Storage mechanism used to persist the catalog. (*default) [core-data, filesystem, *sqlite]")
        var defaultStorage: Catalog.Storage?

        func run() async throws {
            var config = Configuration.default

            if let language = defaultLanguage {
                print("Set 'defaultLanguageCode' = '\(language.rawValue)'; was \(config.defaultLanguageCode.rawValue)")
                config.defaultLanguageCode = language
            }

            if let region = defaultRegion {
                print("Set 'defaultRegionCode' = '\(region.rawValue)'; was \(config.defaultRegionCode.rawValue)")
                config.defaultRegionCode = region
            }

            if let storage = defaultStorage {
                print("Set 'defaultStorage' = '\(storage.rawValue)'; was \(config.defaultStorage.rawValue)")
                config.defaultStorage = storage
            }

            try Configuration.save(config)
        }
    }
}
