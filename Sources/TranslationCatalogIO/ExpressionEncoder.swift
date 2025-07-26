import Foundation
import LocaleSupport
import Plot
import TranslationCatalog

/// Utility for encoding catalog `Translation`s for export/transfer.
public struct ExpressionEncoder {

    private init() {}

    /// Encode the translation value for the provided expressions.
    ///
    /// - parameters:
    ///   - expressions: the `Expression`s to be encoded.
    ///   - locale: The `Locale` for which values should be encoded.
    ///   - fallback: Indicates whether the `Expression.defaultValue` should be used
    ///              if no locale-specific `Translation` is found.
    ///   - format: Format in which the `data` should be encoded.
    public static func encodeValues(
        for expressions: [TranslationCatalog.Expression],
        locale: Locale,
        fallback: Bool,
        format: FileFormat
    ) throws -> Data {
        switch format {
        case .androidXML:
            let sorted = expressions.sorted(by: { $0.key < $1.key })
            let xml = XML.make(
                with: sorted,
                locale: locale,
                fallback: fallback
            )
            let raw = xml.render(indentedBy: .spaces(2))
            return raw.data(using: .utf8) ?? Data()
        case .appleStrings:
            let sorted = expressions.sorted(by: { $0.key < $1.key })
            var output: [String] = []

            for expression in sorted {
                let translation = fallback ? expression.valueOrDefault(for: locale) : expression.value(for: locale)
                guard let translation else {
                    continue
                }

                output.append("\"\(expression.key)\" = \"\(translation.simpleAppleDictionaryEscaped())\";")
            }

            return output
                .joined(separator: "\n")
                .data(using: .utf8) ?? Data()
        case .json:
            let filtered = expressions.compactMap(locale: locale, fallback: fallback)
            let sequence = filtered.map { [$0.key: $0.translations.first?.value ?? ""] }
            let dictionary = sequence.reduce(into: [String: String]()) { partialResult, pair in
                partialResult[pair.keys.first!] = pair.values.first!
            }

            let encoder = JSONEncoder()
            encoder.outputFormatting = [.sortedKeys, .prettyPrinted]

            return try encoder.encode(dictionary)
        }
    }
    
    /// Encode the a `Translation` of each `Expression` in the collection.
    ///
    /// - parameters:
    ///   - expressions: The `Expression`s with `Translation`(s) to be encoded.
    ///   - fileFormat: Format in which the `data` should be interpreted.
    ///   - locale: The `Locale` used to map a specific `Translation`.
    ///   - defaultOrFirst: Indicates a _default_ or _first_ translation is used when a locale-specific one is not found.
    /// - returns: The encoded translations in the request format.
    @available(*, deprecated, renamed: "encodeValues(for:format:locale:fallbackToDefault:)")
    public static func encodeTranslations(
        for expressions: [TranslationCatalog.Expression],
        fileFormat: FileFormat,
        locale: Locale?,
        defaultOrFirst: Bool
    ) throws -> Data {
        switch fileFormat {
        case .androidXML:
            exportAndroidXML(
                expressions,
                locale: locale,
                defaultOrFirst: defaultOrFirst
            )
        case .appleStrings:
            exportAppleStrings(
                expressions,
                locale: locale,
                defaultOrFirst: defaultOrFirst
            )
        case .json:
            try exportJson(
                expressions,
                locale: locale,
                defaultOrFirst: defaultOrFirst
            )
        }
    }

    @available(*, deprecated)
    private static func exportAndroidXML(
        _ expressions: [TranslationCatalog.Expression],
        locale: Locale?,
        defaultOrFirst: Bool
    ) -> Data {
        let sorted = expressions.sorted(by: { $0.key < $1.key })
        let xml = XML.make(
            with: sorted,
            locale: locale,
            defaultOrFirst: defaultOrFirst
        )
        let raw = xml.render(indentedBy: .spaces(2))
        return raw.data(using: .utf8) ?? Data()
    }

    @available(*, deprecated)
    private static func exportAppleStrings(
        _ expressions: [TranslationCatalog.Expression],
        locale: Locale?,
        defaultOrFirst: Bool
    ) -> Data {
        let sorted = expressions.sorted(by: { $0.key < $1.key })
        var output: [String] = []

        for expression in sorted {
            let translation = defaultOrFirst ? expression.valueOrDefault(for: locale ?? expression.locale) : expression.value(for: locale)
            guard let translation else {
                continue
            }

            output.append("\"\(expression.key)\" = \"\(translation.simpleAppleDictionaryEscaped())\";")
        }

        return output
            .joined(separator: "\n")
            .data(using: .utf8) ?? Data()
    }

    @available(*, deprecated)
    private static func exportJson(
        _ expressions: [TranslationCatalog.Expression],
        locale: Locale?,
        defaultOrFirst: Bool
    ) throws -> Data {
        let filtered = expressions.compactMap(locale: locale, defaultOrFirst: defaultOrFirst)
        let sequence = filtered.map { [$0.key: $0.translations.first?.value ?? ""] }
        let dictionary = sequence.reduce(into: [String: String]()) { partialResult, pair in
            partialResult[pair.keys.first!] = pair.values.first!
        }

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .prettyPrinted]

        return try encoder.encode(dictionary)
    }

    @available(*, deprecated, renamed: "encodeTranslations(for:fileFormat:locale:defaultOrFirst:)")
    public static func encodeTranslations(
        for expressions: [TranslationCatalog.Expression],
        fileFormat: FileFormat,
        localeIdentifier: Locale.Identifier?,
        defaultOrFirst: Bool
    ) throws -> Data {
        switch fileFormat {
        case .androidXML:
            exportAndroidXML(
                expressions,
                localeIdentifier: localeIdentifier,
                defaultOrFirst: defaultOrFirst
            )
        case .appleStrings:
            exportAppleStrings(
                expressions,
                localeIdentifier: localeIdentifier,
                defaultOrFirst: defaultOrFirst
            )
        case .json:
            try exportJson(
                expressions,
                localeIdentifier: localeIdentifier,
                defaultOrFirst: defaultOrFirst
            )
        }
    }

    @available(*, deprecated, message: "Use `Locale` variant.")
    private static func exportAndroidXML(
        _ expressions: [TranslationCatalog.Expression],
        localeIdentifier: Locale.Identifier?,
        defaultOrFirst: Bool
    ) -> Data {
        let sorted = expressions.sorted(by: { $0.key < $1.key })
        let xml = XML.make(with: sorted, localeIdentifier: localeIdentifier, defaultOrFirst: defaultOrFirst)
        let raw = xml.render(indentedBy: .spaces(2))
        return raw.data(using: .utf8) ?? Data()
    }

    @available(*, deprecated, message: "Use `Locale` variant.")
    private static func exportAppleStrings(
        _ expressions: [TranslationCatalog.Expression],
        localeIdentifier: Locale.Identifier?,
        defaultOrFirst: Bool
    ) -> Data {
        let sorted = expressions.sorted(by: { $0.key < $1.key })
        var output: [String] = []

        for expression in sorted {
            let translation = defaultOrFirst ? expression.translationOrDefaultOrFirst(with: localeIdentifier) : expression.translation(with: localeIdentifier)
            guard let translation else {
                continue
            }

            output.append("\"\(expression.key)\" = \"\(translation.value.simpleAppleDictionaryEscaped())\";")
        }

        return output
            .joined(separator: "\n")
            .data(using: .utf8) ?? Data()
    }

    @available(*, deprecated, message: "Use `Locale` variant.")
    private static func exportJson(
        _ expressions: [TranslationCatalog.Expression],
        localeIdentifier: Locale.Identifier?,
        defaultOrFirst: Bool
    ) throws -> Data {
        let filtered = expressions.compactMap(localeIdentifier: localeIdentifier, defaultOrFirst: defaultOrFirst)
        let sequence = filtered.map { [$0.key: $0.translations.first?.value ?? ""] }
        let dictionary = sequence.reduce(into: [String: String]()) { partialResult, pair in
            partialResult[pair.keys.first!] = pair.values.first!
        }

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .prettyPrinted]

        return try encoder.encode(dictionary)
    }
}
