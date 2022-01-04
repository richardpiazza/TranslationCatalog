import Statement
import TranslationCatalog
import Foundation

struct ProjectEntity: Entity, Identifiable {
    
    let tableName: String = "project"
    
    @Field("id", unique: true, primaryKey: true, autoIncrement: true)
    var id: Int = 0
    @Field("uuid", unique: true)
    var uuid: String = ""
    @Field("name")
    var name: String = ""
}

extension ProjectEntity {
    static var id: Attribute { Self["id"]! }
    static var uuid: Attribute { Self["uuid"]! }
    static var name: Attribute { Self["name"]! }
    
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
