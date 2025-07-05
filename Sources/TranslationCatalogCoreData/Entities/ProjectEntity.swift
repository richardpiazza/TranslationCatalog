#if canImport(CoreData)
import CoreData
import Foundation
import TranslationCatalog

typealias ProjectEntityCoreDataClassSet = NSSet
typealias ProjectEntityCoreDataPropertiesSet = NSSet

@objc(ProjectEntity)
class ProjectEntity: NSManagedObject {}

extension ProjectEntity {

    @nonobjc class func fetchRequest() -> NSFetchRequest<ProjectEntity> {
        NSFetchRequest<ProjectEntity>(entityName: "ProjectEntity")
    }

    @NSManaged var id: UUID?
    @NSManaged var name: String?
    @NSManaged var expressionEntities: NSSet?
}

// MARK: Generated accessors for expressionEntities

extension ProjectEntity {

    @objc(addExpressionEntitiesObject:)
    @NSManaged func addToExpressionEntities(_ value: ExpressionEntity)

    @objc(removeExpressionEntitiesObject:)
    @NSManaged func removeFromExpressionEntities(_ value: ExpressionEntity)

    @objc(addExpressionEntities:)
    @NSManaged func addToExpressionEntities(_ values: NSSet)

    @objc(removeExpressionEntities:)
    @NSManaged func removeFromExpressionEntities(_ values: NSSet)
}

extension TranslationCatalog.Project {
    init(_ entity: ProjectEntity) throws {
        guard let id = entity.id else {
            throw CocoaError(.coderInvalidValue)
        }

        guard let name = entity.name else {
            throw CocoaError(.coderInvalidValue)
        }

        self.init(
            id: id,
            name: name
        )
    }
}
#endif
