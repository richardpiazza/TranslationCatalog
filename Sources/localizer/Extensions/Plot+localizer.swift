import Plot
import HTMLString
import TranslationCatalog

extension HTML {
    static func make(with expressions: [Expression]) -> Self {
        return HTML(
            .head(
                .title("Localization Strings"),
                .style("""
                body {
                    font-family: -apple-system, Helvetica, sans-serif;
                }

                h1 {
                    color: purple;
                }

                h2 {
                    color: royalblue;
                }

                table, th, td {
                    border-collapse: collapse;
                    border: 1px solid gray;
                }

                th {
                    color: slategray;
                }
                """)
            ),
            .body(
                .div(
                    .h1("Strings")
                ),
                .forEach(expressions) {
                    .localization($0)
                }
            )
        )
    }
}

extension Node where Context == HTML.BodyContext {
    static func localization(_ expression: Expression) -> Self {
        let values = expression.translations.sorted(by: { $0.languageCode.rawValue < $1.languageCode.rawValue })
        
        return .div(
            .h2(
                .text(expression.name)
            ),
            .p(
                .text("ID: \(expression.id)"),
                .br(),
                .text("Key: \(expression.key)"),
                .br(),
                .text("Context: \(expression.context ?? "")"),
                .br(),
                .text("Feature: \(expression.feature ?? "")")
            ),
            .table(
                .tr(
                    .th("ID"),
                    .th("Locale Identifier"),
                    .th("Value")
                ),
                .forEach(values) {
                    .if($0.languageCode == expression.defaultLanguage, .defaultValue($0), else: .value($0))
                }
            )
        )
    }
    
    
}

extension Node where Context == HTML.TableContext {
    static func value(_ translation: Translation) -> Self {
        return .tr(
            .td(
                .text("\(translation.id)")
            ),
            .td(
                .text(translation.localeIdentifier)
            ),
            .td(
                .raw(translation.value.addingASCIIEntities())
            )
        )
    }
    
    static func defaultValue(_ translation: Translation) -> Self {
        return .tr(
            .td(
                .b(
                    .text("\(translation.id)")
                )
            ),
            .td(
                .b(
                    .text(translation.localeIdentifier)
                )
            ),
            .td(
                .b(
                    .raw(translation.value.addingASCIIEntities())
                )
            )
        )
    }
}

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
