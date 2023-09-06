import TranslationCatalog
import Plot

extension XML {
    static func make(with expressions: [Expression]) -> Self {
        return XML(
            .element(named: "resources", nodes: [
                .attribute(named: "xmlns:tools", value: "http://schemas.android.com/tools"),
                .forEach(expressions) {
                    .element(named: "string", nodes: [
                        .attribute(named: "name", value: $0.key),
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
}
