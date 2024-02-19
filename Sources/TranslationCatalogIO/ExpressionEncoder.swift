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
    @available(*, deprecated, renamed: "encodeTranslations(for:fileFormat:localeIdentifier:)")
    public static func encodeTranslations(
        for expressions: [Expression],
        fileFormat: FileFormat
    ) throws -> Data {
        return try encodeTranslations(for: expressions, fileFormat: fileFormat, localeIdentifier: nil)
    }
    
    /// Encode the a `Translation` of each `Expression` in the collection.
    ///
    /// - throws: `Error`
    /// - parameters:
    ///   - expressions: The `Expression`s with `Translation`(s) to be encoded.
    ///   - fileFormat: Format in which the `data` should be interpreted.
    ///   - localeIdentifier: The `Locale.Identifier` used to map a specific `Translation`.
    ///     When not provided, the _default_ or _first_ translation is used.
    /// - returns: The encoded translations in the request format.
    public static func encodeTranslations(
        for expressions: [Expression],
        fileFormat: FileFormat,
        localeIdentifier: Locale.Identifier?
    ) throws -> Data {
        switch fileFormat {
        case .androidXML:
            return exportAndroid(expressions, localeIdentifier: localeIdentifier)
        case .appleStrings:
            return exportApple(expressions, localeIdentifier: localeIdentifier)
        case .json:
            return try exportJson(expressions, localeIdentifier: localeIdentifier)
        }
    }
    
    private static func exportAndroid(_ expressions: [Expression], localeIdentifier: Locale.Identifier?) -> Data {
        let sorted = expressions.sorted(by: { $0.key < $1.key})
        let xml = XML.make(with: sorted, localeIdentifier: localeIdentifier)
        let raw = xml.render(indentedBy: .spaces(2))
        return raw.data(using: .utf8) ?? Data()
    }
    
    private static func exportApple(_ expressions: [Expression], localeIdentifier: Locale.Identifier?) -> Data {
        let sorted = expressions.sorted(by: { $0.key < $1.key})
        var output: [String] = []
        
        sorted.forEach { (expression) in
            guard let translation = expression.translationOrDefaultOrFirst(with: localeIdentifier) else {
                return
            }
            
            output.append("\"\(expression.key)\" = \"\(translation.value)\";")
        }
        
        return output
            .joined(separator: "\n")
            .data(using: .utf8) ?? Data()
    }
    
    private static func exportJson(_ expressions: [Expression], localeIdentifier: Locale.Identifier?) throws -> Data {
        let filtered = expressions.compactMap { expression -> Expression? in
            if expression.translation(with: localeIdentifier) != nil {
                return expression
            } else {
                return nil
            }
        }
        
        let sequence = filtered.map { [$0.key: $0.translation(with: localeIdentifier)?.value ?? ""] }
        let dictionary = sequence.reduce(into: Dictionary<String, String>()) { partialResult, pair in
            partialResult[pair.keys.first!] = pair.values.first!
        }
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
        
        return try encoder.encode(dictionary)
    }
}
