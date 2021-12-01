import LocaleSupport
import ArgumentParser
import Foundation

extension Configure {
    struct Set: ParsableCommand {
        
        static var configuration: CommandConfiguration = .init(
            commandName: "set",
            abstract: "Sets configuration parameters.",
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
            
            try Configuration.save(config)
        }
    }
}
