import Foundation
import LocaleSupport
import TranslationCatalog

/// Utility for decoding `Expression`s from a translation file.
public struct ExpressionDecoder {
    
    private init() {}
    
    /// Decode a collection of `Expression` from the provided `Data`.
    ///
    /// - throws: `Error`
    /// - parameters:
    ///   - data: `Data`, typically from reading a file.
    ///   - fileFormat: Format in which the `data` should be interpretted.
    ///   - defaultLanguage: The default `LanguageCode` applied to any new `Expression`.
    ///   - languageCode: The `LanguageCode` to associate with the `Translation` strings in the file.
    ///   - scriptCode: The `ScriptCode` associated with the files values.
    ///   - regionCode: The `RegionCode` associated with the files values.
    /// - returns: The decoded `Expression` collection.
    public static func decodeExpressions(
        from data: Data,
        fileFormat: FileFormat,
        defaultLanguage: LanguageCode,
        languageCode: LanguageCode,
        scriptCode: ScriptCode?,
        regionCode: RegionCode?
    ) throws -> [Expression] {
        let expressions: [Expression]
        
        switch fileFormat {
        case .androidXML:
            let xml = try StringsXml.make(with: data)
            expressions = xml.expressions(defaultLanguage: defaultLanguage, language: languageCode, script: scriptCode, region: regionCode)
        case .appleStrings:
            let dictionary = try Dictionary(data: data)
            expressions = dictionary.expressions(defaultLanguage: defaultLanguage, language: languageCode, script: scriptCode, region: regionCode)
        case .json:
            let dictionary = try JSONDecoder().decode([String: String].self, from: data)
            expressions = dictionary.expressions(defaultLanguage: defaultLanguage, language: languageCode, script: scriptCode, region: regionCode)
        }
        
        return expressions
    }
}
