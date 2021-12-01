import ArgumentParser
import LocaleSupport

try Configuration.load(.default)

struct Command: ParsableCommand {
    static var configuration: CommandConfiguration = {
        return .init(
            commandName: "localizer",
            abstract: "Android 'strings.xml' & Apple 'Localizable.strings' utility.",
            discussion: """
            Default Language Code: \(LanguageCode.default.rawValue)
            Default Region Code: \(RegionCode.default.rawValue)
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

Command.main()
