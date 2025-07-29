import ArgumentParser
import Foundation
import TranslationCatalog
import TranslationCatalogIO

struct Preview: AsyncParsableCommand {

    static let configuration = CommandConfiguration(
        commandName: "preview",
        abstract: "Displays the localizations found in a translation file.",
        version: "1.0.0",
        helpNames: .shortAndLong
    )

    @Argument(help: "The source of the file 'android-xml', 'apple-strings', 'json'.")
    var format: FileFormat

    @Option(help: "The 'default' Language for the expressions being imported.")
    var language: Locale.LanguageCode = .localizerDefault

    @Option(help: "The script code for the translations in the imported file.")
    var script: Locale.Script?

    @Option(help: "The region code for the translations in the imported file.")
    var region: Locale.Region?

    @Argument(help: "The path to the file being imported")
    var input: String

    func validate() throws {
        guard !input.isEmpty else {
            throw ValidationError("'input' source file not provided.")
        }
    }

    func run() async throws {
        let url = try FileManager.default.url(for: input)
        let data = try Data(contentsOf: url)
        let expressions = try ExpressionDecoder.decodeExpressions(
            from: data,
            fileFormat: format,
            defaultLanguage: language,
            language: language,
            script: script,
            region: region
        )

        for expression in expressions.sorted(by: { $0.key < $1.key }) {
            switch expression.translations.count {
            case .zero:
                print("\(expression.key) = \(expression.defaultValue)")
            default:
                for translation in expression.translations {
                    print("\(expression.key) = \(translation.value)")
                }
            }
        }
    }
}
