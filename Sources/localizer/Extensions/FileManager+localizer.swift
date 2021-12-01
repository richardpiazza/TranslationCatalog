import Foundation

extension FileManager {
    func url(for filename: String) throws -> URL {
        // Absolute Path?
        let absoluteURL = URL(fileURLWithPath: filename)
        if fileExists(atPath: absoluteURL.path) {
            return absoluteURL
        }
        
        // Relative Path?
        let directory = URL(fileURLWithPath: currentDirectoryPath, isDirectory: true)
        let relativeURL = directory.appendingPathComponent(filename)
        return relativeURL
    }
    
    func applicationSupportDirectory() throws -> URL {
        let url = try self.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let application = url.appendingPathComponent("localizer")
        try createDirectory(at: application, withIntermediateDirectories: true, attributes: nil)
        return application
    }
    
    func configurationURL() throws -> URL {
        return try applicationSupportDirectory().appendingPathComponent("configuration.json")
    }
    
    func catalogURL() throws -> URL {
        return try applicationSupportDirectory().appendingPathComponent("catalog.sqlite")
    }
}
