import Foundation
import LocaleSupport
import Plot
import TranslationCatalog

extension XML {
    static func make(
        with expressions: [TranslationCatalog.Expression],
        locale: Locale,
        fallback: Bool
    ) -> Self {
        let filtered = expressions.compactMap(locale: locale, fallback: fallback)
        
        return XML(
            .element(named: "resources", nodes: [
                .forEach(filtered) {
                    .element(named: "string", nodes: [
                        .attribute(named: "name", value: $0.key),
                        .attribute(
                            named: "formatted",
                            value: $0.valueOrDefault(for: locale).hasMultipleReplacements ? "false" : "",
                            ignoreIfValueIsEmpty: true
                        ),
                        .text($0.valueOrDefault(for: locale).simpleAndroidXMLEscaped()),
                    ])
                },
            ])
        )
    }
    
    @available(*, deprecated, renamed: "make(with:locale:fallback:)")
    static func make(
        with expressions: [TranslationCatalog.Expression],
        locale: Locale?,
        defaultOrFirst: Bool
    ) -> Self {
        let filtered = expressions.compactMap(locale: locale, defaultOrFirst: defaultOrFirst)

        return XML(
            .element(named: "resources", nodes: [
                .forEach(filtered) {
                    .element(named: "string", nodes: [
                        .attribute(named: "name", value: $0.key),
                        .attribute(
                            named: "formatted",
                            value: $0.translations.first?.value.hasMultipleReplacements == true ? "false" : "",
                            ignoreIfValueIsEmpty: true
                        ),
                        .text(($0.translations.first?.value ?? "").simpleAndroidXMLEscaped()),
                    ])
                },
            ])
        )
    }

    @available(*, deprecated, renamed: "make(with:locale:defaultOrFirst:)")
    static func make(with expressions: [TranslationCatalog.Expression], localeIdentifier: Locale.Identifier?, defaultOrFirst: Bool) -> Self {
        let filtered = expressions.compactMap(localeIdentifier: localeIdentifier, defaultOrFirst: defaultOrFirst)

        return XML(
            .element(named: "resources", nodes: [
                .forEach(filtered) {
                    .element(named: "string", nodes: [
                        .attribute(named: "name", value: $0.key),
                        .attribute(
                            named: "formatted",
                            value: $0.translations.first?.value.hasMultipleReplacements == true ? "false" : "",
                            ignoreIfValueIsEmpty: true
                        ),
                        .text(($0.translations.first?.value ?? "").simpleAndroidXMLEscaped()),
                    ])
                },
            ])
        )
    }
}

extension String {
    func simpleAppleDictionaryEscaped() -> String {
        let replacements: [(Character, String)] = [
            (#"""#, #"\""#),
            ("\u{00a0}", "\\U00A0"), // Non-Breaking Space
        ]

        var updated = self

        for (character, replacement) in replacements {
            updated = updated.replacingOccurrences(of: String(describing: character), with: replacement, range: nil)
        }

        return updated
    }

    func simpleAndroidXMLEscaped() -> String {
        let replacements: [(Character, String)] = [
            ("&", "&amp;"),
            (#"""#, #"\""#),
            ("'", "\\'"),
            ("<", "&lt;"),
            (">", "&gt;"),
            (" ", "&#160;"), // Non-Breaking Space
        ]

        var updated = self

        for (character, replacement) in replacements {
            updated = updated.replacingOccurrences(of: String(describing: character), with: replacement, range: nil)
        }

        return updated
    }

    var hasMultipleReplacements: Bool {
        numberOfInstances("%@") > 1
    }

    func numberOfInstances(_ substring: String) -> Int {
        guard !isEmpty else {
            return 0
        }

        var count = 0

        var range: Range<String.Index>?
        while let match = self.range(of: substring, options: [], range: range) {
            count += 1
            range = Range(uncheckedBounds: (lower: match.upperBound, upper: endIndex))
        }

        return count
    }
}
