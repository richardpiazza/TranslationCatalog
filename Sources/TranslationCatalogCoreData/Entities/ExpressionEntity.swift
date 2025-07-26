#if canImport(CoreData)
import CoreData
import Foundation
import TranslationCatalog

typealias ExpressionEntityCoreDataClassSet = NSSet
typealias ExpressionEntityCoreDataPropertiesSet = NSSet

@objc(ExpressionEntity)
class ExpressionEntity: NSManagedObject {}

extension ExpressionEntity {

    @nonobjc class func fetchRequest() -> NSFetchRequest<ExpressionEntity> {
        NSFetchRequest<ExpressionEntity>(entityName: "ExpressionEntity")
    }

    @NSManaged var context: String?
    @NSManaged var defaultLanguageRawValue: String?
    @NSManaged var defaultValue: String?
    @NSManaged var feature: String?
    @NSManaged var id: UUID?
    @NSManaged var key: String?
    @NSManaged var name: String?
    @NSManaged var projectEntities: NSSet?
    @NSManaged var translationEntities: NSSet?
}

// MARK: Generated accessors for projectEntities

extension ExpressionEntity {

    @objc(addProjectEntitiesObject:)
    @NSManaged func addToProjectEntities(_ value: ProjectEntity)

    @objc(removeProjectEntitiesObject:)
    @NSManaged func removeFromProjectEntities(_ value: ProjectEntity)

    @objc(addProjectEntities:)
    @NSManaged func addToProjectEntities(_ values: NSSet)

    @objc(removeProjectEntities:)
    @NSManaged func removeFromProjectEntities(_ values: NSSet)
}

// MARK: Generated accessors for translationEntities

extension ExpressionEntity {

    @objc(addTranslationEntitiesObject:)
    @NSManaged func addToTranslationEntities(_ value: TranslationEntity)

    @objc(removeTranslationEntitiesObject:)
    @NSManaged func removeFromTranslationEntities(_ value: TranslationEntity)

    @objc(addTranslationEntities:)
    @NSManaged func addToTranslationEntities(_ values: NSSet)

    @objc(removeTranslationEntities:)
    @NSManaged func removeFromTranslationEntities(_ values: NSSet)
}

extension ExpressionEntity {
    var defaultLanguage: Locale.LanguageCode {
        guard let defaultLanguageRawValue else {
            return .default
        }

        guard let languageCode = try? Locale.LanguageCode(matching: defaultLanguageRawValue) else {
            return .default
        }

        return languageCode
    }
    
    var value: String {
        defaultValue ?? ""
    }
}

extension TranslationCatalog.Expression {
    init(_ entity: ExpressionEntity) throws {
        guard let id = entity.id else {
            throw CocoaError(.coderInvalidValue)
        }

        guard let key = entity.key else {
            throw CocoaError(.coderInvalidValue)
        }

        guard let name = entity.name else {
            throw CocoaError(.coderInvalidValue)
        }

        self.init(
            id: id,
            key: key,
            name: name,
            defaultLanguageCode: entity.defaultLanguage,
            defaultValue: entity.value,
            context: entity.context,
            feature: entity.feature
        )
    }
}
#endif
