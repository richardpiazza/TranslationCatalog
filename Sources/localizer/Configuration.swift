import Foundation
import LocaleSupport

struct Configuration: Codable {
    var defaultLanguageCode: LanguageCode
    var defaultRegionCode: RegionCode
    var defaultStorage: Catalog.Storage

    init() {
        defaultLanguageCode = .default
        defaultRegionCode = .default
        defaultStorage = .default
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        defaultLanguageCode = try container.decodeIfPresent(LanguageCode.self, forKey: .defaultLanguageCode) ?? .default
        defaultRegionCode = try container.decodeIfPresent(RegionCode.self, forKey: .defaultRegionCode) ?? .default
        defaultStorage = try container.decodeIfPresent(Catalog.Storage.self, forKey: .defaultStorage) ?? .default
    }

    static var decoder: JSONDecoder {
        JSONDecoder()
    }

    static var encoder: JSONEncoder {
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
            return Configuration()
        }
    }

    static func load(_ configuration: Configuration) throws {
        LanguageCode.default = configuration.defaultLanguageCode
        RegionCode.default = configuration.defaultRegionCode
        Catalog.Storage.default = configuration.defaultStorage
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
