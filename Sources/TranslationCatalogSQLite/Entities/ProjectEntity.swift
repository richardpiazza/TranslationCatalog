import Statement
import TranslationCatalog
import Foundation

struct ProjectEntity: Entity, Identifiable {
    
    static let identifier: String = "project"
    
    @Field("id", unique: true, primaryKey: true, autoIncrement: true)
    var id: Int = 0
    @Field("uuid", unique: true)
    var uuid: String = ""
    @Field("name")
    var name: String = ""
}

extension ProjectEntity {
    static let entity = ProjectEntity()
    static var id: Attribute { entity["id"]! }
    static var uuid: Attribute { entity["uuid"]! }
    static var name: Attribute { entity["name"]! }
    
    init(_ project: Project) {
        uuid = project.id.uuidString
        name = project.name
    }
    
    func project(with expressions: [TranslationCatalog.Expression] = []) throws -> Project {
        guard let id = UUID(uuidString: uuid) else {
            throw CatalogError.dataTypeConversion("Invalid UUID '\(uuid)'")
        }
        
        return Project(id: id, name: name, expressions: expressions)
    }
}
