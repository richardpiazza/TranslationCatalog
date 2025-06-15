import Statement
import StatementSQLite
import TranslationCatalog

// MARK: - Project (Schema)
extension SQLiteStatement {
    static var createProjectEntity: Self {
        .init(
            .CREATE(
                .SCHEMA(ProjectEntity.entity, ifNotExists: true)
            )
        )
    }
}

// MARK: - Project (Queries)
extension SQLiteStatement {
    static var selectAllFromProject: Self {
        .init(
            .SELECT(
                .column(ProjectEntity.id),
                .column(ProjectEntity.uuid),
                .column(ProjectEntity.name)
            ),
            .FROM(
                .TABLE(ProjectEntity.self)
            )
        )
    }
    
    static func selectProject(withID id: Int) -> Self {
        .init(
            .SELECT(
                .column(ProjectEntity.id),
                .column(ProjectEntity.uuid),
                .column(ProjectEntity.name)
            ),
            .FROM(
                .TABLE(ProjectEntity.self)
            ),
            .WHERE(
                .column(ProjectEntity.id, op: .equal, value: id)
            )
        )
    }
    
    static func selectProject(withID id: Project.ID) -> Self {
        .init(
            .SELECT(
                .column(ProjectEntity.id),
                .column(ProjectEntity.uuid),
                .column(ProjectEntity.name)
            ),
            .FROM(
                .TABLE(ProjectEntity.self)
            ),
            .WHERE(
                .column(ProjectEntity.uuid, op: .equal, value: id)
            ),
            .LIMIT(1)
        )
    }
    
    static func selectProject(withName name: String) -> Self {
        .init(
            .SELECT(
                .column(ProjectEntity.id),
                .column(ProjectEntity.uuid),
                .column(ProjectEntity.name)
            ),
            .FROM(
                .TABLE(ProjectEntity.self)
            ),
            .WHERE(
                .column(ProjectEntity.name, op: .equal, value: name)
            ),
            .LIMIT(1)
        )
    }
    
    static func selectProjects(withNameLike name: String) -> Self {
        .init(
            .SELECT(
                .column(ProjectEntity.id),
                .column(ProjectEntity.uuid),
                .column(ProjectEntity.name)
            ),
            .FROM(
                .TABLE(ProjectEntity.self)
            ),
            .WHERE(
                .column(ProjectEntity.name, op: .like, value: "%\(name)%")
            )
        )
    }
    
    static func insertProject(_ project: ProjectEntity) -> Self {
        SQLiteStatement(
            .INSERT_INTO(
                ProjectEntity.self,
                .column(ProjectEntity.uuid),
                .column(ProjectEntity.name)
            ),
            .VALUES(
                .value(project.uuid as DataTypeConvertible),
                .value(project.name as DataTypeConvertible)
            )
        )
    }
    
    static func updateProject(_ id: Int, name: String) -> Self {
        SQLiteStatement(
            .UPDATE(
                .TABLE(ProjectEntity.self)
            ),
            .SET(
                .column(ProjectEntity.name, op: .equal, value: name)
            ),
            .WHERE(
                .column(ProjectEntity.id, op: .equal, value: id)
            )
        )
    }
    
    static func deleteProject(_ id: Int) -> Self {
        SQLiteStatement(
            .DELETE(
                .FROM(ProjectEntity.self)
            ),
            .WHERE(
                .column(ProjectEntity.id, op: .equal, value: id)
            )
        )
    }
}
