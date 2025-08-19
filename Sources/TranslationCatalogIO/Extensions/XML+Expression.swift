import Foundation
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
}
