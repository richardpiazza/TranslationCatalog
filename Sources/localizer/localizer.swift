import ArgumentParser
import LocaleSupport

@main struct Command: AsyncParsableCommand {
    static var configuration: CommandConfiguration = {
        try? Configuration.load(.default)
        
        return .init(
            commandName: "localizer",
            abstract: "Utility for interacting with Android 'strings.xml', Apple 'Localizable.strings', and Web '*.json' localization files.",
            usage: nil,
            discussion: """
            Default Language Code: \(LanguageCode.default.rawValue)
            Default Region Code: \(RegionCode.default.rawValue)
            Default Storage: \(Catalog.Storage.default.rawValue)
            """,
            version: "1.0.0",
            shouldDisplay: true,
            subcommands: [
                Preview.self,
                Catalog.self,
                Catalog.Import.self,
                Catalog.Export.self,
                Configure.self
            ],
            defaultSubcommand: nil,
            helpNames: [.short, .long])
    }()
}
