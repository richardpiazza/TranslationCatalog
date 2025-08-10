#if canImport(CoreData)
import CoreData
import Foundation
import TranslationCatalog

typealias TranslationEntityCoreDataClassSet = NSSet
typealias TranslationEntityCoreDataPropertiesSet = NSSet

@objc(TranslationEntity)
class TranslationEntity: NSManagedObject {}

extension TranslationEntity {

    @nonobjc class func fetchRequest() -> NSFetchRequest<TranslationEntity> {
        NSFetchRequest<TranslationEntity>(entityName: "TranslationEntity")
    }

    @NSManaged var id: UUID?
    @NSManaged var languageCodeRawValue: String?
    @NSManaged var regionCodeRawValue: String?
    @NSManaged var scriptCodeRawValue: String?
    @NSManaged var value: String?
    @NSManaged var stateRawValue: String?
    @NSManaged var expressionEntity: ExpressionEntity?
}

extension TranslationEntity {
    var language: Locale.LanguageCode {
        guard let languageCodeRawValue else {
            return .default
        }
        
        return Locale.LanguageCode(languageCodeRawValue)
    }

    var script: Locale.Script? {
        guard let scriptCodeRawValue else {
            return nil
        }

        return Locale.Script(scriptCodeRawValue)
    }

    var region: Locale.Region? {
        guard let regionCodeRawValue else {
            return nil
        }

        return Locale.Region(regionCodeRawValue)
    }
    
    var state: TranslationState {
        guard let stateRawValue else {
            return .new
        }
        
        return TranslationState(stringLiteral: stateRawValue)
    }
}

extension TranslationCatalog.Translation {
    init(_ entity: TranslationEntity) throws {
        guard let id = entity.id else {
            throw CocoaError(.coderInvalidValue)
        }

        guard let expressionEntity = entity.expressionEntity, let expressionId = expressionEntity.id else {
            throw CocoaError(.coderInvalidValue)
        }

        self.init(
            id: id,
            expressionId: expressionId,
            value: entity.value ?? "",
            language: entity.language,
            script: entity.script,
            region: entity.region,
            state: entity.state
        )
    }
}
#endif
