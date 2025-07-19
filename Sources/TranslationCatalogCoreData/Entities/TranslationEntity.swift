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
    @NSManaged var expressionEntity: ExpressionEntity?
}

extension TranslationEntity {
    var language: Locale.LanguageCode {
        guard let languageCodeRawValue else {
            return .default
        }

        guard let languageCode = try? Locale.LanguageCode(matching: languageCodeRawValue) else {
            return .default
        }

        return languageCode
    }

    var script: Locale.Script? {
        guard let scriptCodeRawValue else {
            return nil
        }

        return try? Locale.Script(matching: scriptCodeRawValue)
    }

    var region: Locale.Region? {
        guard let regionCodeRawValue else {
            return nil
        }

        return try? Locale.Region(matching: regionCodeRawValue)
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
            language: entity.language,
            script: entity.script,
            region: entity.region,
            value: entity.value ?? ""
        )
    }
}
#endif
