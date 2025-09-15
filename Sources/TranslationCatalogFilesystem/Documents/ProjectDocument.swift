import Foundation
import TranslationCatalog

struct ProjectDocument: Document {
    let id: UUID
    var name: String
    var expressionIds: Set<ExpressionDocument.ID>
}

extension ProjectDocument: Encodable {
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        if #available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *) {
            try container.encode(expressionIds.sorted(), forKey: .expressionIds)
        } else {
            try container.encode(expressionIds, forKey: .expressionIds)
        }
    }
}

extension Project {
    init(document: ProjectDocument, expressions: [TranslationCatalog.Expression]) {
        self.init(
            id: document.id,
            name: document.name,
            expressions: expressions
        )
    }
}
