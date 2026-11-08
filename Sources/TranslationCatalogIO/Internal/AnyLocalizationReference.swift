import LocaleSupport

struct AnyAnnotatedLocalizationReference: AnnotatedLocalizationReference {
    let key: String
    let value: String
    let comment: String?
    let keyStrategy: LocalizationKeyStrategy

    init(
        key: String,
        value: String,
        comment: String? = nil,
        keyStrategy: LocalizationKeyStrategy = .default,
    ) {
        self.key = key
        self.value = value
        self.comment = comment
        self.keyStrategy = keyStrategy
    }
}
