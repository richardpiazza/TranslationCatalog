import ArgumentParser
import Foundation

@main struct Command: AsyncParsableCommand {
    static let configuration = {
        try? Configuration.load(.default)

        return CommandConfiguration(
            commandName: "localizer",
            abstract: "Utility for interacting with Android 'strings.xml', Apple 'Localizable.strings', and Web '*.json' localization files.",
            discussion: """
            Default Language Code: \(Locale.LanguageCode.localizerDefault.identifier)
            Default Region Code: \(Locale.Region.localizerDefault.identifier)
            Default Storage: \(Catalog.Storage.default.rawValue)
            """,
            version: "1.0.0",
            subcommands: [
                Preview.self,
                Catalog.self,
                Catalog.Import.self,
                Catalog.Export.self,
                Configure.self,
                Syntax.self
            ],
            helpNames: .shortAndLong)
    }()
}
