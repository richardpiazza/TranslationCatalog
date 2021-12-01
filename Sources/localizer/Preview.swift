import ArgumentParser
import Foundation
import TranslationCatalog

struct Preview: ParsableCommand {
    
    enum Source: String, ExpressibleByArgument {
        case android
        case apple
    }
    
    static var configuration: CommandConfiguration = .init(
        commandName: "preview",
        abstract: "Displays the localizations found in a translation file.",
        discussion: "",
        version: "1.0.0",
        shouldDisplay: true,
        subcommands: [],
        defaultSubcommand: nil,
        helpNames: .shortAndLong
    )
    
    @Argument(help: "The source of the file 'android' or 'apple'.")
    var source: Source
    
    @Argument(help: "The path to the file being imported")
    var input: String
    
    func validate() throws {
        guard !input.isEmpty else {
            throw ValidationError("'input' source file not provided.")
        }
    }
    
    func run() throws {
        let url = try FileManager.default.url(for: input)
        
        let expressions: [Expression]
        switch source {
        case .android:
            let android = try StringsXml.make(contentsOf: url)
            expressions = android.expressions(language: .default, script: nil, region: nil)
        case .apple:
            let dictionary = try Dictionary(contentsOf: url)
            expressions = dictionary.expressions(language: .default, script: nil, region: nil)
        }
        
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
