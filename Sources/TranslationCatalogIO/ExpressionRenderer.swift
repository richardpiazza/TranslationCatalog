import TranslationCatalog
import Plot

public struct ExpressionRenderer {
    
    private init() {}
    
    public static func render(expressions: [Expression], renderFormat: RenderFormat) throws -> String {
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
                    table.addRow(translation, strong: translation.languageCode == expression.defaultLanguage)
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
