import Foundation
import TranslationCatalog

/// Utility for decoding `Expression`s from a translation file.
public struct ExpressionDecoder {

    private init() {}

    /// Decode a collection of `Expression` from the provided `Data`.
    ///
    /// - parameters:
    ///   - data: `Data`, typically from reading a file.
    ///   - fileFormat: Format in which the `data` should be interpreted.
    ///   - defaultLanguage: The default `Locale.LanguageCode` applied to any new `Expression`.
    ///   - language: The `Locale.LanguageCode` to associate with the `Translation` strings in the file.
    ///   - script: The `Locale.Script` associated with the files values.
    ///   - region: The `Locale.Region` associated with the files values.
    /// - returns: The decoded `Expression` collection.
    public static func decodeExpressions(
        from data: Data,
        fileFormat: FileFormat,
        defaultLanguage: Locale.LanguageCode,
        language: Locale.LanguageCode,
        script: Locale.Script?,
        region: Locale.Region?
    ) throws -> [TranslationCatalog.Expression] {
        let expressions: [TranslationCatalog.Expression]

        switch fileFormat {
        case .androidXML:
            let xml = try StringsXml.make(with: data)
            expressions = xml.expressions(
                defaultLanguage: defaultLanguage,
                language: language,
                script: script,
                region: region
            )
        case .appleStrings:
            let dictionary = try Dictionary(data: data)
            expressions = dictionary.expressions(
                defaultLanguage: defaultLanguage,
                language: language,
                script: script,
                region: region
            )
        case .json:
            let dictionary = try JSONDecoder().decode([String: String].self, from: data)
            expressions = dictionary.expressions(
                defaultLanguage: defaultLanguage,
                language: language,
                script: script,
                region: region
            )
        }

        return expressions
    }
}
