import LocaleSupport
import ArgumentParser
import Foundation

extension Configure {
    struct Set: ParsableCommand {
        
        static var configuration: CommandConfiguration = .init(
            commandName: "set",
            abstract: "Sets configuration parameters.",
            usage: nil,
            discussion: "",
            version: "1.0.0",
            shouldDisplay: true,
            subcommands: [],
            defaultSubcommand: nil,
            helpNames: .shortAndLong
        )
        
        @Option(help: "")
        var defaultLanguage: LanguageCode?
        
        @Option(help: "")
        var defaultRegion: RegionCode?
        
        @Option(help: "")
        var defaultStorage: Catalog.Storage?
        
        func run() throws {
            var config = Configuration.`default`
            
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
