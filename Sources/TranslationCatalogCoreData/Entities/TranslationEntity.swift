#if canImport(CoreData)
import CoreData
import Foundation
import LocaleSupport
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

extension TranslationEntity: LocaleRepresentable {
    public var languageCode: LanguageCode {
        guard let languageCodeRawValue else {
            return .en
        }

        return LanguageCode(rawValue: languageCodeRawValue) ?? .en
    }

    public var scriptCode: ScriptCode? {
        guard let scriptCodeRawValue else {
            return nil
        }

        return ScriptCode(rawValue: scriptCodeRawValue)
    }

    public var regionCode: RegionCode? {
        guard let regionCodeRawValue else {
            return nil
        }

        return RegionCode(rawValue: regionCodeRawValue)
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
            languageCode: entity.languageCode,
            scriptCode: entity.scriptCode,
            regionCode: entity.regionCode,
            value: entity.value ?? ""
        )
    }
}
#endif
