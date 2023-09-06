import Foundation
import TranslationCatalog
import LocaleSupport
import Plot

/// Utility for encoding catalog `Translation`s for export/transfer.
public struct ExpressionEncoder {
    
    private init() {}
    
    /// Encode the first/primary `Translation` of each `Expression` in the collection.
    ///
    /// - throws: `Error`
    /// - parameters:
    ///   - expressions: The `Expression`s with `Translation`(s) to be encoded.
    ///   - fileFormat: Format in which the `data` should be interpreted.
    /// - returns: The encoded translations in the request format.
    public static func encodeTranslations(
        for expressions: [Expression],
        fileFormat: FileFormat
    ) throws -> Data {
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
