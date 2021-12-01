import Foundation
import PerfectSQLite
import LocaleSupport
import TranslationCatalog

extension SQLiteStmt {
    func optional<T>(position: Int) -> T? {
        guard !isNull(position: position) else {
            return nil
        }
        
        switch T.self {
        case is String.Type:
            return (columnText(position: position) as! T)
        case is ScriptCode.Type:
            return (ScriptCode(rawValue: columnText(position: position)) as! T)
        case is RegionCode.Type:
            return (RegionCode(rawValue: columnText(position: position)) as! T)
        default:
            return nil
        }
    }
    
    func uuid(position: Int) -> UUID {
        return UUID(uuidString: columnText(position: position))!
    }
    
    func languageCode(position: Int) -> LanguageCode {
        return LanguageCode(rawValue: columnText(position: position)) ?? .default
    }
    
    func scriptCode(position: Int) -> ScriptCode? {
        guard !isNull(position: position) else {
            return nil
        }
        
        return ScriptCode(rawValue: columnText(position: position))
    }
    
    func regionCode(position: Int) -> RegionCode? {
        guard !isNull(position: position) else {
            return nil
        }
        
        return RegionCode(rawValue: columnText(position: position))
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
            context: optional(position: 5),
            feature: optional(position: 6)
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
            value: columnText(position: 6)
        )
    }
}
