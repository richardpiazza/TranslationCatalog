import Statement
import StatementSQLite
import TranslationCatalog
import LocaleSupport
import Foundation

// MARK: - Translation (Schema)
extension SQLiteStatement {
    static var createTranslationEntity: Self {
        .init(
            .CREATE(
                .SCHEMA(TranslationEntity.self, ifNotExists: true)
            )
        )
    }
    
    static var translationTable_addScriptCode: Self {
        .init(
            .ALTER_TABLE(
                TranslationEntity.self,
                .ADD_COLUMN(TranslationEntity.script)
            )
        )
    }
    
    static var translationTable_addUUID: Self {
        .init(
            .ALTER_TABLE(TranslationEntity.self, .ADD_COLUMN(TranslationEntity.uuid))
        )
    }
}

// MARK: - Translation (Queries)
extension SQLiteStatement {
    static var selectAllFromTranslation: Self {
        .init(
            .SELECT(
                .column(TranslationEntity.id),
                .column(TranslationEntity.uuid),
                .column(TranslationEntity.expressionID),
                .column(TranslationEntity.language),
                .column(TranslationEntity.script),
                .column(TranslationEntity.region),
                .column(TranslationEntity.value)
            ),
            .FROM_TABLE(TranslationEntity.self)
        )
    }
    
    static func selectTranslation(withID id: Int) -> Self {
        .init(
            .SELECT(
                .column(TranslationEntity.id),
                .column(TranslationEntity.uuid),
                .column(TranslationEntity.expressionID),
                .column(TranslationEntity.language),
                .column(TranslationEntity.script),
                .column(TranslationEntity.region),
                .column(TranslationEntity.value)
            ),
            .FROM_TABLE(TranslationEntity.self),
            .WHERE(
                .column(TranslationEntity.id, op: .equal, value: id)
            ),
            .LIMIT(1)
        )
    }
    
    static func selectTranslation(withID id: TranslationCatalog.Translation.ID) -> Self {
        .init(
            .SELECT(
                .column(TranslationEntity.id),
                .column(TranslationEntity.uuid),
                .column(TranslationEntity.expressionID),
                .column(TranslationEntity.language),
                .column(TranslationEntity.script),
                .column(TranslationEntity.region),
                .column(TranslationEntity.value)
            ),
            .FROM_TABLE(TranslationEntity.self),
            .WHERE(
                .column(TranslationEntity.uuid, op: .equal, value: id)
            ),
            .LIMIT(1)
        )
    }
    
    static func selectTranslationsFor(_ expressionID: Int) -> Self {
        .init(
            .SELECT(
                .column(TranslationEntity.id),
                .column(TranslationEntity.uuid),
                .column(TranslationEntity.expressionID),
                .column(TranslationEntity.language),
                .column(TranslationEntity.script),
                .column(TranslationEntity.region),
                .column(TranslationEntity.value)
            ),
            .FROM_TABLE(TranslationEntity.self),
            .WHERE(
                .column(TranslationEntity.expressionID, op: .equal, value: expressionID)
            )
        )
    }
    
    static func selectTranslationsFor(_ expressionID: Int, languageCode: LanguageCode?, scriptCode: ScriptCode?, regionCode: RegionCode?) -> Self {
        .init(
            .SELECT(
                .column(TranslationEntity.id),
                .column(TranslationEntity.uuid),
                .column(TranslationEntity.expressionID),
                .column(TranslationEntity.language),
                .column(TranslationEntity.script),
                .column(TranslationEntity.region),
                .column(TranslationEntity.value)
            ),
            .FROM_TABLE(TranslationEntity.self),
            .WHERE(
                .AND(
                    .column(TranslationEntity.expressionID, op: .equal, value: expressionID),
                    .unwrap(languageCode, transform: { .column(TranslationEntity.language, op: .equal, value: $0.rawValue) }),
                    .unwrap(scriptCode, transform: { .column(TranslationEntity.script, op: .equal, value: $0.rawValue) }),
                    .unwrap(regionCode, transform: { .column(TranslationEntity.region, op: .equal, value: $0.rawValue) })
                )
            )
        )
    }
    
    static func selectTranslationsHavingOnly(_ expressionID: Int, languageCode: LanguageCode) -> Self {
        .init(
            .SELECT(
                .column(TranslationEntity.id),
                .column(TranslationEntity.uuid),
                .column(TranslationEntity.expressionID),
                .column(TranslationEntity.language),
                .column(TranslationEntity.script),
                .column(TranslationEntity.region),
                .column(TranslationEntity.value)
            ),
            .FROM(
                .TABLE(TranslationEntity.self)
            ),
            .WHERE(
                .AND(
                    .column(TranslationEntity.expressionID, op: .equal, value: expressionID),
                    .column(TranslationEntity.language, op: .equal, value: languageCode.rawValue),
                    .logical(op: .isNull, segments: [Segment<WhereContext>.column(TranslationEntity.script)]),
                    .logical(op: .isNull, segments: [Segment<WhereContext>.column(TranslationEntity.region)])
                )
            )
        )
    }
    
    static func insertTranslation(_ translation: TranslationEntity) -> Self {
        .init(
            .INSERT_INTO(
                TranslationEntity.self,
                .column(TranslationEntity.uuid),
                .column(TranslationEntity.expressionID),
                .column(TranslationEntity.language),
                .column(TranslationEntity.region),
                .column(TranslationEntity.value),
                .column(TranslationEntity.script)
            ),
            .VALUES(
                .value(translation.uuid),
                .value(translation.expressionID),
                .value(translation.language),
                .unwrap(translation.region, transform: { .value($0) }, else: .value(NSNull())),
                .value(translation.value),
                .unwrap(translation.script, transform: { .value($0) }, else: .value(NSNull()))
            )
        )
    }
    
    static func updateTranslation(_ id: Int, languageCode: LanguageCode) -> Self {
        SQLiteStatement(
            .UPDATE(
                .TABLE(TranslationEntity.self)
            ),
            .SET(
                .column(TranslationEntity.language, op: .equal, value: languageCode.rawValue)
            ),
            .WHERE(
                .column(TranslationEntity.id, op: .equal, value: id)
            ),
            .LIMIT(1)
        )
    }
    
    static func updateTranslation(_ id: Int, scriptCode: ScriptCode?) -> Self {
        SQLiteStatement(
            .UPDATE(
                .TABLE(TranslationEntity.self)
            ),
            .SET(
                .unwrap(
                    scriptCode,
                    transform: { value in
                        .column(TranslationEntity.script, op: .equal, value: value.rawValue)
                    },
                    else:
                        .column(TranslationEntity.script, op: .equal, value: NSNull())
                )
            ),
            .WHERE(
                .column(TranslationEntity.id, op: .equal, value: id)
            ),
            .LIMIT(1)
        )
    }
    
    static func updateTranslation(_ id: Int, regionCode: RegionCode?) -> Self {
        SQLiteStatement(
            .UPDATE(
                .TABLE(TranslationEntity.self)
            ),
            .SET(
                .unwrap(
                    regionCode,
                    transform: { value in
                        .column(TranslationEntity.region, op: .equal, value: value.rawValue)
                    },
                    else:
                        .column(TranslationEntity.region, op: .equal, value: NSNull())
                )
            ),
            .WHERE(
                .column(TranslationEntity.id, op: .equal, value: id)
            ),
            .LIMIT(1)
        )
    }
    
    static func updateTranslation(_ id: Int, value: String) -> Self {
        SQLiteStatement(
            .UPDATE(
                .TABLE(TranslationEntity.self)
            ),
            .SET(
                .column(TranslationEntity.value, op: .equal, value: value)
            ),
            .WHERE(
                .column(TranslationEntity.id, op: .equal, value: id)
            ),
            .LIMIT(1)
        )
    }
    
    static func deleteTranslation(_ id: Int) -> Self {
        .init(
            .DELETE_FROM(TranslationEntity.self),
            .WHERE(
                .column(TranslationEntity.id, op: .equal, value: id)
            ),
            .LIMIT(1)
        )
    }
    
    static func deleteTranslations(withExpressionID id: Int) -> Self {
        .init(
            .DELETE_FROM(TranslationEntity.self),
            .WHERE(
                .column(TranslationEntity.expressionID, op: .equal, value: id)
            )
        )
    }
}
