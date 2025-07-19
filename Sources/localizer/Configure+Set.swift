import ArgumentParser
import Foundation

extension Configure {
    struct Set: AsyncParsableCommand {

        static let configuration = CommandConfiguration(
            commandName: "set",
            abstract: "Sets configuration parameters.",
            version: "1.0.0",
            helpNames: .shortAndLong
        )

        @Option(help: "The default LanguageCode used when no other option is presented.")
        var defaultLanguage: Locale.LanguageCode?

        @Option(help: "The default RegionCode used when no other option is presented.")
        var defaultRegion: Locale.Region?

        @Option(help: "Storage mechanism used to persist the catalog. (*default) [core-data, filesystem, *sqlite]")
        var defaultStorage: Catalog.Storage?

        func run() async throws {
            var config = Configuration.default

            if let language = defaultLanguage {
                print("Set 'defaultLanguageCode' = '\(language.identifier)'; was \(config.defaultLanguageCode.identifier)")
                config.defaultLanguageCode = language
            }

            if let region = defaultRegion {
                print("Set 'defaultRegionCode' = '\(region.identifier)'; was \(config.defaultRegionCode.identifier)")
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
