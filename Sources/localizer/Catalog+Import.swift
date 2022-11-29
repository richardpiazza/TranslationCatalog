import Foundation
import ArgumentParser
import LocaleSupport
import TranslationCatalog
import TranslationCatalogSQLite

extension Catalog {
    struct Import: CatalogCommand {
        
        static var configuration: CommandConfiguration = .init(
            commandName: "import",
            abstract: "Imports a translation file into the catalog.",
            usage: nil,
            discussion: """
            
            """,
            version: "1.0.0",
            shouldDisplay: true,
            subcommands: [],
            defaultSubcommand: nil,
            helpNames: .shortAndLong
        )
        
        @Argument(help: "The language code for the translations in the imported file.")
        var language: LanguageCode
        
        @Argument(help: "The path to the file being imported")
        var filename: String
        
        @Option(help: "The source of the file 'android', 'apple', 'json'.")
        var format: Catalog.Format?
        
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
        
        func run() throws {
            let fileURL = try FileManager.default.url(for: filename)
            let _format = format ?? Format(extension:  fileURL.pathExtension)
            guard let fileFormat = _format else {
                throw ValidationError("Import format could not be determined. Use '--format' to specify.")
            }
            
            let catalog = try catalog(forStorage: storage)
            
            let expressions: [Expression]
            switch fileFormat {
            case .android:
                let android = try StringsXml.make(contentsOf: fileURL)
                expressions = android.expressions(defaultLanguage: defaultLanguage, language: language, script: script, region: region)
            case .apple:
                let dictionary = try Dictionary(contentsOf: fileURL)
                expressions = dictionary.expressions(defaultLanguage: defaultLanguage, language: language, script: script, region: region)
            case .json:
                let data = try Data(contentsOf: fileURL)
                let dictionary = try JSONDecoder().decode([String: String].self, from: data)
                expressions = dictionary.expressions(defaultLanguage: defaultLanguage, language: language, script: script, region: region)
            }
            
            expressions.forEach({
                importExpression($0, into: catalog)
            })
        }
        
        private func importExpression(_ expression: Expression, into catalog: TranslationCatalog.Catalog) {
            do {
                try catalog.createExpression(expression)
                print("Imported Expression '\(expression.name)'")
            } catch CatalogError.expressionExistingWithKey(let key, let existing) {
                print("Existing Expression Key '\(key)'")
                importTranslations(expression.replacingId(existing.id), into: catalog)
            } catch SQLiteCatalog.Error.existingExpressionWithKey {
                print("Existing Expression Key '\(expression.key)'")
                importTranslations(expression, into: catalog)
            } catch {
                print("Import Failure: \(expression); \(error.localizedDescription)")
            }
        }
        
        private func importTranslations(_ expression: Expression, into catalog: TranslationCatalog.Catalog) {
            guard let id = try? catalog.expression(matching: GenericExpressionQuery.key(expression.key)).id else {
                return
            }
            
            expression.translations.forEach { translation in
                var t = translation
                t.expressionID = id
                importTranslation(t, into: catalog)
            }
        }
        
        private func importTranslation(_ translation: TranslationCatalog.Translation, into catalog: TranslationCatalog.Catalog) {
            do {
                try catalog.createTranslation(translation)
                print("Imported Translation '\(translation.value)'")
            } catch CatalogError.translationExistingWithValue {
                print("Existing Translation Value '\(translation.value)'")
            } catch {
                print("Import Failure: \(translation); \(error.localizedDescription)")
            }
        }
    }
}
