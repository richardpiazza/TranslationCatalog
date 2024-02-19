import Foundation
import LocaleSupport
import TranslationCatalog
import Plot

extension XML {
    static func make(with expressions: [Expression], localeIdentifier: Locale.Identifier?, defaultOrFirst: Bool) -> Self {
        let filtered = expressions.compactMap(localeIdentifier: localeIdentifier, defaultOrFirst: defaultOrFirst)
        
        return XML(
            .element(named: "resources", nodes: [
                .attribute(named: "xmlns:tools", value: "http://schemas.android.com/tools"),
                .forEach(filtered) {
                    .element(named: "string", nodes: [
                        .attribute(named: "name", value: $0.key),
                        .attribute(
                            named: "formatted",
                            value: $0.translations.first?.value.hasMultipleReplacements == true ? "false" : "",
                            ignoreIfValueIsEmpty: true
                        ),
                        .text(($0.translations.first?.value ?? "").simpleAndroidXMLEscaped())
                    ])
                }
            ])
        )
    }
}

internal extension String {
    func simpleAndroidXMLEscaped() -> String {
        let replacements: [(Character, String)] = [
            ("&", "&amp;"),
//            ("\"", "&quot;"),
            ("'", "\\'"),
            ("<", "&lt;"),
            (">", "&gt;"),
            (" ", "&#160;") // NBSP
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
