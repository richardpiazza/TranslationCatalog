import ArgumentParser
import Foundation
import LocaleSupport
import TranslationCatalog
import TranslationCatalogIO

extension Catalog {
    struct Export: CatalogCommand {
        
        static var configuration: CommandConfiguration = .init(
            commandName: "export",
            abstract: "Export a translation file using the catalog.",
            usage: nil,
            discussion: """
            iOS Localization should contain all keys (expressions) for a given language. There is no native fallback
            mechanism to a 'base' language. (i.e. en-GB > en). Given this functionality, when exporting the 'apple'
            format, all expressions will be included (preferring the script/region).
            """,
            version: "1.0.0",
            shouldDisplay: true,
            subcommands: [],
            defaultSubcommand: nil,
            helpNames: .shortAndLong
        )
        
        @Argument(help: "The export format [android-xml, apple-strings, json]")
        var format: FileFormat
        
        @Argument(help: "The language code to use for the strings.")
        var language: LanguageCode
        
        @Option(help: "The script code to use for the strings.")
        var script: ScriptCode?
        
        @Option(help: "The region code to use for the strings.")
        var region: RegionCode?
        
        @Option(help: "Identifier of the project for which to limit results.")
        var projectId: Project.ID?
        
        @Flag(help: "Indicates if a fallback translation should be used when no matching option is found.")
        var fallback: Bool = false
        
        @Option(help: "Storage mechanism used to persist the catalog. [sqlite, filesystem]")
        var storage: Catalog.Storage = .default
        
        @Option(help: "Path to catalog to use in place of the application library.")
        var path: String?
        
        func run() async throws {
            let catalog = try catalog(forStorage: storage)
            let data = try TranslationEncoder.encodeTranslations(
                from: catalog,
                fileFormat: format,
                fallbackToDefaultLanguage: fallback,
                languageCode: language,
                scriptCode: script,
                regionCode: region,
                projectId: projectId
            )
            let output = String(data: data, encoding: .utf8) ?? ""
            
            print(output)
        }
    }
}
