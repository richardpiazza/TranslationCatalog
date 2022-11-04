import Foundation
import TranslationCatalog
import LocaleSupport

struct ProjectDocument: Document {
    let id: UUID
    var name: String
    var expressionIds: [ExpressionDocument.ID]
}

extension Project {
    init(document: ProjectDocument, expressions: [Expression]) {
        self.init(
            uuid: document.id,
            name: document.name,
            expressions: expressions
        )
    }
}
