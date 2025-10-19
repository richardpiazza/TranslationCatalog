import Foundation

struct Configuration: Codable {
    var defaultLanguageCode: Locale.LanguageCode
    var defaultRegionCode: Locale.Region
    var defaultStorage: Catalog.Storage

    init() {
        defaultLanguageCode = .default
        defaultRegionCode = .default
        defaultStorage = .default
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        defaultLanguageCode = try container.decodeIfPresent(Locale.LanguageCode.self, forKey: .defaultLanguageCode) ?? .default
        defaultRegionCode = try container.decodeIfPresent(Locale.Region.self, forKey: .defaultRegionCode) ?? .default
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
        Locale.LanguageCode.localizerDefault = configuration.defaultLanguageCode
        Locale.Region.localizerDefault = configuration.defaultRegionCode
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
