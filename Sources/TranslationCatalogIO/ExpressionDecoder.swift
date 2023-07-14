import Foundation
import LocaleSupport
import TranslationCatalog

public struct ExpressionDecoder {
    
    private init() {}
    
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
