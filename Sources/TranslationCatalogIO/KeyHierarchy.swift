import LocaleSupport
import TranslationCatalog

public struct KeyHierarchy {
    public private(set) var id: [String]
    public private(set) var prefix: [String]
    public private(set) var contents: [[String]: LocalizationKey]
    public private(set) var nodes: [KeyHierarchy]

    public init(
        id: [String] = [],
        prefix: [String] = [],
        contents: [[String]: LocalizationKey] = [:],
        nodes: [KeyHierarchy] = []
    ) {
        self.id = id
        self.prefix = prefix
        self.contents = contents
        self.nodes = nodes
    }

    public static func make(with expressions: [Expression]) throws -> KeyHierarchy {
        var hierarchy = KeyHierarchy()

        try expressions
            .map {
                LocalizationKey(
                    key: $0.key,
                    defaultValue: try $0.defaultValue.encodingDarwinStrings(),
                    comment: $0.context
                )
            }
            .forEach { key in
                let id = key.key.components(separatedBy: "_")
                hierarchy.process(id, key: key)
            }

        return hierarchy
    }

    private mutating func process(_ identity: [String], key: LocalizationKey) {
        switch identity.count {
        case 0:
            break
        case 1:
            contents[identity] = key
        default:
            var components = identity
            let component = components.removeFirst()
            let nodeId = [component]

            for token in Self.reservedTypeTokens {
                if component.caseInsensitiveCompare(token) == .orderedSame {
                    contents[identity] = key
                    return
                }
            }

            if let nextComponent = components.first, Int(nextComponent) != nil {
                contents[identity] = key
                return
            }

            if let index = nodes.firstIndex(where: { $0.id == nodeId }) {
                nodes[index].process(components, key: key)
            } else {
                var node = KeyHierarchy(
                    id: nodeId,
                    prefix: prefix + nodeId
                )
                node.process(components, key: key)
                nodes.append(node)
            }
        }
    }

    static let reservedTypeTokens: [String] = [
        "Any",
        "Type",
    ]

    static let reservedVariableTokens: [String] = [
        "any",
        "continue",
        "for",
        "in",
        "self",
    ]
}
