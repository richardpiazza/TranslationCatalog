import Foundation
import SQLite
import TranslationCatalog

extension Statement.Element {
    func isNull(position: Int) -> Bool {
        self[position] == nil
    }

    func columnText(position: Int) -> String {
        guard let value = self[position] as? String else {
            fatalError()
        }

        return value
    }

    func columnInt(position: Int) -> Int {
        guard let value = self[position] as? Int64 else {
            fatalError()
        }

        return Int(value)
    }
}

extension Statement.Element {
    func optional<T>(position: Int) -> T? {
        guard !isNull(position: position) else {
            return nil
        }

        switch T.self {
        case is String.Type:
            return (columnText(position: position) as! T)
        default:
            return nil
        }
    }

    func uuid(position: Int) -> UUID {
        UUID(uuidString: columnText(position: position))!
    }

    var projectEntity: ProjectEntity {
        .init(
            id: columnInt(position: 0),
            uuid: columnText(position: 1),
            name: columnText(position: 2)
        )
    }

    var projectExpressionEntity: ProjectExpressionEntity {
        .init(projectID: columnInt(position: 0), expressionID: columnInt(position: 1))
    }

    var expressionEntity: ExpressionEntity {
        .init(
            id: columnInt(position: 0),
            uuid: columnText(position: 1),
            key: columnText(position: 2),
            name: columnText(position: 3),
            defaultLanguage: columnText(position: 4),
            defaultValue: columnText(position: 5),
            context: optional(position: 6),
            feature: optional(position: 7)
        )
    }

    var translationEntity: TranslationEntity {
        .init(
            id: columnInt(position: 0),
            uuid: columnText(position: 1),
            expressionID: columnInt(position: 2),
            language: columnText(position: 3),
            script: optional(position: 4),
            region: optional(position: 5),
            value: columnText(position: 6),
            stateRawValue: columnText(position: 7)
        )
    }
}
