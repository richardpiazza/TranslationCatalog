import Foundation
import LocaleSupport
import TranslationCatalog

public struct KeyHierarchy {

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

    enum KeyHierarchyError: Error {
        case emptyNodeId
        case nodeNotFound
    }

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

    public static func make(with expressions: [TranslationCatalog.Expression]) throws -> KeyHierarchy {
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
                let id = key.key.components(separatedBy: String(key.strategy.separator))
                hierarchy.process(id, key: key)
            }

        return hierarchy
    }

    mutating func process(_ identity: [String], key: LocalizationKey) {
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

    /// Creates an instance of the hierarchy in which `nodes` that only have a single `contents` item
    /// will be merged into the parent `node`.
    public func compressed() throws -> KeyHierarchy {
        var hierarchy = self
        try hierarchy.compress()
        return hierarchy
    }

    /// Mutates the hierarchy by merging `nodes` with only a single `contents` item into the parent `node`.
    public mutating func compress() throws {
        let orphans = singleContentNodes()
        guard !orphans.isEmpty else {
            return
        }

        for orphan in orphans.reversed() {
            let hierarchy = try removeNode(orphan)
            var parent = orphan
            parent.removeLast()
            try mergeContents(of: hierarchy, into: parent)
        }
    }

    func singleContentNodes(parentNodes: [String] = []) -> [[String]] {
        var identifiedNodes: [[String]] = []

        for node in nodes {
            if node.contents.count == 1 {
                identifiedNodes.append(parentNodes + node.id)
            }

            identifiedNodes.append(
                contentsOf: node.singleContentNodes(
                    parentNodes: parentNodes + node.id
                )
            )
        }

        return identifiedNodes
    }

    mutating func removeNode(_ id: [String]) throws -> KeyHierarchy {
        switch id.count {
        case 0:
            throw KeyHierarchyError.emptyNodeId
        case 1:
            guard let index = nodes.firstIndex(where: { $0.id == id }) else {
                throw KeyHierarchyError.nodeNotFound
            }

            return nodes.remove(at: index)
        default:
            var path = id
            let nodeId = [path.removeFirst()]
            guard let index = nodes.firstIndex(where: { $0.id == nodeId }) else {
                throw KeyHierarchyError.nodeNotFound
            }

            return try nodes[index].removeNode(path)
        }
    }

    mutating func mergeContents(of hierarchy: KeyHierarchy, into id: [String]) throws {
        switch id.count {
        case 0:
            for (key, value) in hierarchy.contents {
                let newKey = hierarchy.id + key
                contents[newKey] = value
            }
        case 1:
            guard let index = nodes.firstIndex(where: { $0.id == id }) else {
                throw KeyHierarchyError.nodeNotFound
            }

            for (key, value) in hierarchy.contents {
                let newKey = hierarchy.id + key
                nodes[index].contents[newKey] = value
            }
        default:
            var path = id
            let nodeId = [path.removeFirst()]
            guard let index = nodes.firstIndex(where: { $0.id == nodeId }) else {
                throw KeyHierarchyError.nodeNotFound
            }

            try nodes[index].mergeContents(of: hierarchy, into: path)
        }
    }
}
