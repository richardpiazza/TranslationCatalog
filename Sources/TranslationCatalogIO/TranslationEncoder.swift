import Foundation
import TranslationCatalog
import LocaleSupport
import Plot

public struct TranslationEncoder {
    
    private init() {}
    
    public static func encodeTranslations(
        from catalog: Catalog,
        fileFormat: FileFormat,
        fallbackToDefaultLanguage: Bool,
        languageCode: LanguageCode,
        scriptCode: ScriptCode?,
        regionCode: RegionCode?,
        projectId: Project.ID?
    ) throws -> Data {
        var expressions: [Expression]
        var expressionIds: [Expression.ID]
        
        if fileFormat == .appleStrings || fallbackToDefaultLanguage {
            if let id = projectId {
                expressions = try catalog.expressions(matching: GenericExpressionQuery.projectID(id))
                let withLanguage = try catalog.expressions(matching: GenericExpressionQuery.translationsHaving(languageCode, nil, nil))
                expressions.removeAll { expression in
                    !withLanguage.contains(where: { $0.id == expression.id })
                }
            } else {
                expressions = try catalog.expressions()
            }
            
            expressionIds = expressions.map { $0.id }
            
            for (index, id) in expressionIds.enumerated() {
                let preferredTranslations = try catalog.translations(matching: GenericTranslationQuery.having(id, languageCode, scriptCode, regionCode))
                if !preferredTranslations.isEmpty {
                    expressions[index].translations = preferredTranslations
                    continue
                }
                
                let fallbackTranslations = try catalog.translations(matching: GenericTranslationQuery.having(id, languageCode, nil, nil))
                if !fallbackTranslations.isEmpty {
                    expressions[index].translations = fallbackTranslations
                    continue
                }
                
                let defaultLanguage = expressions[index].defaultLanguage
                let defaultTranslations = try catalog.translations(matching: GenericTranslationQuery.having(id, defaultLanguage, nil, nil))
                expressions[index].translations = defaultTranslations
            }
        } else {
            if let id = projectId {
                expressions = try catalog.expressions(matching: GenericExpressionQuery.projectID(id))
                let withLanguage = try catalog.expressions(matching: GenericExpressionQuery.translationsHaving(languageCode, scriptCode, regionCode))
                expressions.removeAll { expression in
                    !withLanguage.contains(where: { $0.id == expression.id })
                }
            } else {
                expressions = try catalog.expressions(matching: GenericExpressionQuery.translationsHaving(languageCode, scriptCode, regionCode))
            }
            
            expressionIds = expressions.map { $0.id }
            
            try expressionIds.enumerated().forEach { (index, id) in
                expressions[index].translations = try catalog.translations(matching: GenericTranslationQuery.having(id, languageCode, scriptCode, regionCode))
            }
        }
        
        switch fileFormat {
        case .androidXML:
            return exportAndroid(expressions)
        case .appleStrings:
            return exportApple(expressions)
        case .json:
            return try exportJson(expressions)
        }
    }
    
    private static func exportAndroid(_ expressions: [Expression]) -> Data {
        let sorted = expressions.sorted(by: { $0.key < $1.key})
        let xml = XML.make(with: sorted)
        let raw = xml.render(indentedBy: .spaces(2))
        return raw.data(using: .utf8) ?? Data()
    }
    
    private static func exportApple(_ expressions: [Expression]) -> Data {
        let sorted = expressions.sorted(by: { $0.key < $1.key})
        var output: [String] = []
        
        sorted.forEach { (expression) in
            guard let translation = expression.translations.first else {
                return
            }
            
            output.append("\"\(expression.key)\" = \"\(translation.value)\";")
        }
        
        return output
            .joined(separator: "\n")
            .data(using: .utf8) ?? Data()
    }
    
    private static func exportJson(_ expressions: [Expression]) throws -> Data {
        let sequence = expressions.map { [$0.key: $0.translations.first?.value ?? ""] }
        let dictionary = sequence.reduce(into: Dictionary<String, String>()) { partialResult, pair in
            partialResult[pair.keys.first!] = pair.values.first!
        }
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
        
        return try encoder.encode(dictionary)
    }
}
