import Foundation

enum TestResource {
    case directory(URL?)
    case file(URL?)

    @available(*, deprecated)
    static func bundleURL(_ url: URL?) -> Self {
        .file(url)
    }
}
