import LocaleSupport

public extension DefaultValueIndicator {
    init?(argument: String) {
        guard let prefix = argument.first else {
            return nil
        }

        guard let suffix = argument.last else {
            return nil
        }

        self.init(
            prefix: prefix,
            suffix: suffix,
        )
    }
}
