import ArgumentParser
import Foundation
import LocaleSupport
import TranslationCatalog
import TranslationCatalogIO
import TranslationCatalogSQLite

extension Catalog {
    struct Import: CatalogCommand {

        static let configuration = CommandConfiguration(
            commandName: "import",
            abstract: "Imports a translation file into the catalog.",
            version: "1.0.0",
            helpNames: .shortAndLong
        )

        @Argument(help: "The language code for the translations in the imported file.")
        var language: LanguageCode

        @Argument(help: "The path to the file being imported")
        var filename: String

        @Option(help: "The source of the file 'android-xml', 'apple-strings', 'json'.")
        var format: FileFormat?

        @Option(help: "The script code for the translations in the imported file.")
        var script: ScriptCode?

        @Option(help: "The region code for the translations in the imported file.")
        var region: RegionCode?

        @Option(help: "The 'default' Language for the expressions being imported.")
        var defaultLanguage: LanguageCode = .default

        @Option(help: "Storage mechanism used to persist the catalog. [sqlite, filesystem]")
        var storage: Catalog.Storage = .default

        @Option(help: "Path to catalog to use in place of the application library.")
        var path: String?

        func validate() throws {
            guard !filename.isEmpty else {
                throw ValidationError("'input' source file not provided.")
            }
        }

        func run() async throws {
            let fileURL = try FileManager.default.url(for: filename)
            let _format = format ?? FileFormat(fileExtension: fileURL.pathExtension)
            guard let fileFormat = _format else {
                throw ValidationError("Import format could not be determined. Use '--format' to specify.")
            }

            let catalog = try catalog(forStorage: storage)
            let data = try Data(contentsOf: fileURL)
            let expressions = try ExpressionDecoder.decodeExpressions(
                from: data,
                fileFormat: fileFormat,
                defaultLanguage: defaultLanguage,
                languageCode: language,
                scriptCode: script,
                regionCode: region
            )

            let importer = ExpressionImporter(catalog: catalog)
            let stream = await importer.importTranslations(from: expressions)
            for await operation in stream {
                print(operation.description)
            }
        }
    }
}
