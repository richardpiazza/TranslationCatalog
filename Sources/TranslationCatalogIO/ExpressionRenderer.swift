import Plot
import TranslationCatalog

/// Utility for rendering expressions in multiple formats.
public struct ExpressionRenderer {

    private init() {}

    /// Create a string representation of a rendered `Expression` document.
    ///
    /// - parameters:
    ///   - expressions: The collection of `Expression` which should be rendered into the document.
    ///   - renderFormat: The output format for the document.
    /// - returns: String representation of the requested text document.
    public static func render(
        expressions: [Expression],
        renderFormat: RenderFormat
    ) throws -> String {
        switch renderFormat {
        case .html:
            let html = HTML.make(with: expressions)
            return html.render(indentedBy: .spaces(2))
        case .markdown:
            var md: String = "# Strings"

            for expression in expressions {
                let table = try MarkdownTable<[Translation]>(
                    paths: [\.id, \.localeIdentifier, \.value],
                    headers: ["ID", "Locale Identifier", "Value"]
                )

                let translations = expression.translations.sorted(by: { $0.languageCode.rawValue < $1.languageCode.rawValue })
                for translation in translations {
                    table.addRow(translation, strong: translation.language == expression.defaultLanguageCode)
                }

                md += """
                \n
                ## \(expression.name)
                Id: \(expression.id)
                Key: \(expression.key)
                Context: \(expression.context ?? "")
                Feature: \(expression.feature ?? "")

                \(table)
                """
            }

            return md
        }
    }
}
