import Foundation
import LocaleSupport
import TranslationCatalog

public struct KeyHierarchy {

    typealias NodeID = [String]
    typealias NodePath = [NodeID]

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
    public func compressed(
        mergePhantoms: Bool = true,
        mergeOrphans: Bool = true,
    ) throws -> KeyHierarchy {
        var hierarchy = self
        try hierarchy.compress(mergePhantoms: mergePhantoms, mergeOrphans: mergeOrphans)
        return hierarchy
    }

    /// Mutates the hierarchy by merging phantom or orphaned nodes.
    public mutating func compress(
        mergePhantoms: Bool = true,
        mergeOrphans: Bool = true,
    ) throws {
        var lastIteration: Int = 0

        if mergePhantoms {
            lastIteration = -1

            var phantoms = phantomNodes()
            while !phantoms.isEmpty {
                if phantoms.count == lastIteration {
                    throw CocoaError(.userCancelled, userInfo: [
                        NSLocalizedDescriptionKey: "Phantoms not reducing",
                    ])
                } else {
                    lastIteration = phantoms.count
                }

                for phantom in phantoms.reversed() {
                    guard let node = node(with: phantom) else {
                        continue
                    }

                    // Only process phantoms which are _still_ valid.
                    guard let child = node.nodes.first, node.nodes.count == 1, node.contents.isEmpty else {
                        continue
                    }

                    let nodeId = phantom + child.id
                    if let hierarchy = removeNode(nodeId) {
                        mergeNode(hierarchy, into: phantom)
                    }
                }

                phantoms = phantomNodes()
            }
        }

        if mergeOrphans {
            lastIteration = -1

            var orphans = orphanNodes()
            while !orphans.isEmpty {
                if orphans.count == lastIteration {
                    throw CocoaError(.userCancelled, userInfo: [
                        NSLocalizedDescriptionKey: "Orphans not reducing",
                    ])
                } else {
                    lastIteration = orphans.count
                }

                for orphan in orphans.reversed() {
                    guard let node = node(with: orphan) else {
                        print("Skipped Orphan '\(orphan)'; No Node")
                        continue
                    }

                    // Only process orphans which are _still_ valid.
                    guard node.contents.count == 1 else {
                        print("Skipped Orphan '\(orphan)'; No Longer Valid")
                        continue
                    }
                    
                    if let hierarchy = removeNode(orphan) {
                        var parent = orphan
                        parent.removeLast()
                        mergeContents(of: hierarchy, into: parent)
                    }
                }
                
                orphans = orphanNodes()
            }
        }
    }

    func node(with id: NodeID) -> KeyHierarchy? {
        if self.id == id {
            return self
        }

        if let node = nodes.first(where: { $0.id == id }) {
            return node
        }

        var path = id
        let nodeId = [path.removeFirst()]

        if let node = nodes.first(where: { $0.id == nodeId }) {
            return node.node(with: path)
        }

        return nil
    }

    /// Nodes which have no child `nodes`, and have only one `content` item.
    ///
    /// In the following, `Time` would be considered an orphan:
    /// ```swift
    /// enum LocalizedStrings: String, LocalizedStringConvertible {
    ///     case greeting = "Hello World!"
    ///
    ///     enum Zulu {
    ///         enum Time: String, LocalizedStringConvertible {
    ///             case definition
    ///         }
    ///     }
    /// }
    /// ```
    func orphanNodes(parentNodes: [String] = []) -> [NodeID] {
        var identifiedNodes: [NodeID] = []

        for node in nodes {
            if node.nodes.isEmpty && node.contents.count == 1 {
                identifiedNodes.append(parentNodes + node.id)
            }

            identifiedNodes.append(
                contentsOf: node.orphanNodes(
                    parentNodes: parentNodes + node.id
                )
            )
        }

        return identifiedNodes.sorted()
    }

    /// Nodes which have no `contents` but have a single child `nodes`.
    ///
    /// This is similar to the practice of having 'phantom' enum types for grouping and/or generic contexts.
    ///
    /// In the following, `Zulu` would be a phantom node:
    /// ```swift
    /// enum LocalizedStrings: String, LocalizedStringConvertible {
    ///     case greeting = "Hello World!"
    ///
    ///     enum Zulu {
    ///         enum Time: String, LocalizedStringConvertible {
    ///             case definition
    ///         }
    ///     }
    /// }
    /// ```
    func phantomNodes(parentNodes: [String] = []) -> [NodeID] {
        var identifiedNodes: [NodeID] = []

        for node in nodes {
            if node.contents.isEmpty && node.nodes.count == 1 {
                identifiedNodes.append(parentNodes + node.id)
            }

            identifiedNodes.append(
                contentsOf: node.phantomNodes(
                    parentNodes: parentNodes + node.id
                )
            )
        }

        return identifiedNodes.sorted()
    }

    mutating func removeNode(_ nodeId: NodeID) -> KeyHierarchy? {
        guard !nodeId.isEmpty else {
            return nil
        }

        var path = nodeId
        let subNode = [path.removeFirst()]

        if let index = nodes.firstIndex(where: { $0.id == nodeId }) {
            return nodes.remove(at: index)
        } else if let index = nodes.firstIndex(where: { $0.id == subNode }) {
            return nodes[index].removeNode(path)
        }

        return nil
    }

    mutating func mergeContents(of node: KeyHierarchy, into nodeId: NodeID) {
        guard !nodeId.isEmpty else {
            for (key, value) in node.contents {
                let newKey = node.id + key
                contents[newKey] = value
            }
            return
        }

        var path = nodeId
        let subNode = [path.removeFirst()]

        if let index = nodes.firstIndex(where: { $0.id == nodeId }) {
            print("Merging Contents of '\(node.id)' into '\(nodes[index].id)'.")
            for (key, value) in node.contents {
                let newKey = node.id + key
                nodes[index].contents[newKey] = value
            }
        } else if let index = nodes.firstIndex(where: { $0.id == subNode }) {
            nodes[index].mergeContents(of: node, into: path)
        } else {
            // Merge into self
            print("Merging Contents of '\(node.id)' into SELF '\(id)'.")
            for (key, value) in node.contents {
                let newKey = node.id + key
                contents[newKey] = value
            }
        }
    }

    mutating func mergeNode(_ node: KeyHierarchy, into nodeId: NodeID) {
        guard !nodeId.isEmpty else {
            id.append(contentsOf: node.id)
            prefix = node.prefix
            for (key, value) in node.contents {
                contents[key] = value
            }
            nodes.append(contentsOf: node.nodes)
            return
        }

        var path = nodeId
        let subNode = [path.removeFirst()]

        if let index = nodes.firstIndex(where: { $0.id == nodeId }) {
            nodes[index].mergeNode(node, into: [])
        } else if let index = nodes.firstIndex(where: { $0.id == subNode }) {
            nodes[index].mergeNode(node, into: path)
        }
    }
}
