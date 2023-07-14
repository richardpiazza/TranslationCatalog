import ArgumentParser
import Foundation
import TranslationCatalog
import TranslationCatalogIO

struct Preview: AsyncParsableCommand {
    
    static var configuration: CommandConfiguration = .init(
        commandName: "preview",
        abstract: "Displays the localizations found in a translation file.",
        usage: nil,
        discussion: "",
        version: "1.0.0",
        shouldDisplay: true,
        subcommands: [],
        defaultSubcommand: nil,
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
        let expressions = try ExpressionDecoder.decodeExpressions(from: data, fileFormat: format, defaultLanguage: .default, languageCode: .default, scriptCode: nil, regionCode: nil)
        
        expressions.sorted(by: { $0.name < $1.name }).forEach { (expression) in
            switch expression.translations.count {
            case .zero:
                print("\(expression.name) NO TRANSLATIONS")
            default:
                expression.translations.forEach { (translation) in
                    print("\(expression.name) = \(translation.value)")
                }
            }
        }
    }
}
