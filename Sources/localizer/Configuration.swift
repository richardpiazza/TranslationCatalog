import LocaleSupport
import Foundation

struct Configuration: Codable {
    var defaultLanguageCode: LanguageCode
    var defaultRegionCode: RegionCode
    
    internal static var decoder: JSONDecoder {
        return JSONDecoder()
    }
    
    internal static var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }
    
    static var `default`: Configuration {
        do {
            let url = try FileManager.default.configurationURL()
            let data = try Data(contentsOf: url)
            return try decoder.decode(Configuration.self, from: data)
        } catch {
            return Configuration(
                defaultLanguageCode: .default,
                defaultRegionCode: .default
            )
        }
    }
    
    static func load(_ configuration: Configuration) throws {
        LanguageCode.default = configuration.defaultLanguageCode
        RegionCode.default = configuration.defaultRegionCode
    }
    
    static func save(_ configuration: Configuration) throws {
        let url = try FileManager.default.configurationURL()
        let data = try encoder.encode(configuration)
        try data.write(to: url)
    }
}

extension Configuration: CustomStringConvertible {
    var description: String {
        do {
            let data = try Self.encoder.encode(self)
            return String(data: data, encoding: .utf8) ?? ""
        } catch {
            return ""
        }
    }
}
