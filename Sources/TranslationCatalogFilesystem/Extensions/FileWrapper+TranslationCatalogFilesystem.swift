#if os(macOS) || os(iOS) || os(watchOS) || os(tvOS) || os(visionOS)
import Foundation

extension FileWrapper {
    func directory(forPath path: String) -> FileWrapper {
        guard let wrapper = fileWrappers?[path] else {
            let directoryWrapper = FileWrapper(directoryWithFileWrappers: [:])
            directoryWrapper.preferredFilename = path
            addFileWrapper(directoryWrapper)
            return directoryWrapper
        }

        return wrapper
    }
}
#endif
