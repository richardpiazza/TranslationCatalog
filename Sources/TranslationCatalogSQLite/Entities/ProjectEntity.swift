import Statement
import TranslationCatalog
import Foundation

struct ProjectEntity: Table, Identifiable {
    
    enum CodingKeys: String, CodingKey {
        case id
        case uuid
        case name
    }
    
    static var schema: Schema = { ProjectEntity().schema }()
    static var id: AnyColumn { schema.columns[0] }
    static var uuid: AnyColumn { schema.columns[1] }
    static var name: AnyColumn { schema.columns[2] }
    private var schema: Schema { Schema(name: "project", columns: [_id, _uuid, _name]) }
    
    @Column(table: ProjectEntity.self, name: CodingKeys.id.rawValue, dataType: "INTEGER", notNull: true, unique: true, primaryKey: true, autoIncrement: true)
    var id: Int = 0
    @Column(table: ProjectEntity.self, name: CodingKeys.uuid.rawValue, dataType: "TEXT", notNull: true, unique: true)
    var uuid: String = ""
    @Column(table: ProjectEntity.self, name: CodingKeys.name.rawValue, dataType: "TEXT", notNull: true)
    var name: String = ""
}

extension ProjectEntity {
    init(_ project: Project) {
        uuid = project.uuid.uuidString
        name = project.name
    }
    
    func project(with expressions: [Expression] = []) throws -> Project {
        guard let id = UUID(uuidString: uuid) else {
            throw SQLiteCatalog.Error.unhandledConversion
        }
        
        return Project(uuid: id, name: name, expressions: expressions)
    }
}
