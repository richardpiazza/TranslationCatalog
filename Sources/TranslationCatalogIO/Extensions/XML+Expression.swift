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
                        .text($0.translations.first?.value ?? "")
                    ])
                }
            ])
        )
    }
}
