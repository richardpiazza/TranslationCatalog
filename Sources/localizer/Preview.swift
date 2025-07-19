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
            defaultLanguage: .default,
            language: .default,
            script: nil,
            region: nil
        )

        for expression in expressions.sorted(by: { $0.name < $1.name }) {
            switch expression.translations.count {
            case .zero:
                print("\(expression.name) NO TRANSLATIONS")
            default:
                for translation in expression.translations {
                    print("\(expression.name) = \(translation.value)")
                }
            }
        }
    }
}
