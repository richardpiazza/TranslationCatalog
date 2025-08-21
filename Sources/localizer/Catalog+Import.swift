import ArgumentParser
import Foundation
import TranslationCatalog
import TranslationCatalogIO

extension Catalog {
    struct Import: CatalogCommand {

        static let configuration = CommandConfiguration(
            commandName: "import",
            abstract: "Imports a translation file into the catalog.",
            version: "1.0.0",
            helpNames: .shortAndLong
        )

        @Argument(help: "The language code for the translations in the imported file.")
        var language: Locale.LanguageCode

        @Argument(help: "The path to the file being imported")
        var filename: String

        @Option(help: "The source of the file 'android-xml', 'apple-strings', 'json'.")
        var format: FileFormat?

        @Option(help: "The script code for the translations in the imported file.")
        var script: Locale.Script?

        @Option(help: "The region code for the translations in the imported file.")
        var region: Locale.Region?

        @Option(help: "The 'default' Language for the expressions being imported.")
        var defaultLanguage: Locale.LanguageCode = .localizerDefault

        @Option(help: "Storage mechanism used to persist the catalog. (*default) [core-data, filesystem, *sqlite]")
        var storage: Catalog.Storage = .default

        @Option(help: "Path to catalog to use in place of the application library.")
        var path: String?

        @Flag(help: "Additional execution details in the standard output.")
        var verbose: Bool = false

        func validate() throws {
            guard !filename.isEmpty else {
                throw ValidationError("'input' source file not provided.")
            }
        }

        func run() async throws {
            let fileURL = URL(filePath: filename, directoryHint: storage == .filesystem ? .isDirectory : .notDirectory)
            let _format = format ?? FileFormat(fileExtension: fileURL.pathExtension)
            guard let fileFormat = _format else {
                throw ValidationError("Import format could not be determined. Use '--format' to specify.")
            }

            let catalog = try catalog()
            let data = try Data(contentsOf: fileURL)
            let expressions = try ExpressionDecoder.decodeExpressions(
                from: data,
                fileFormat: fileFormat,
                defaultLanguage: defaultLanguage,
                language: language,
                script: script,
                region: region
            )

            let importer = ExpressionImporter(catalog: catalog)
            let stream = await importer.importTranslations(from: expressions)
            for await operation in stream {
                print(operation.description)
            }
        }
    }
}
