import Foundation
import LocaleSupport
import TranslationCatalog

public struct KeyHierarchy {

    /// Represents a path of multi-part strings.
    ///
    /// The human readable path `Strings > EnumName > SubType > Category` would be represented by:
    /// ```swift
    /// [
    ///   ["Strings"],
    ///   ["Enum", "Name"],
    ///   ["Sub", "Type"],
    ///   ["Category"]
    /// ]
    /// ```
    public typealias NodeID = [[String]]

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

    public private(set) var id: NodeID
    public private(set) var parent: NodeID
    public private(set) var contents: [NodeID: LocalizationKey]
    public private(set) var nodes: [KeyHierarchy]

    private let nodeSort = NodePathSortComparator()

    var isPhantom: Bool {
        contents.isEmpty && nodes.count <= 1
    }

    var containsPhantoms: Bool {
        nodes.contains(where: { $0.isPhantom || $0.containsPhantoms })
    }

    var isOrphan: Bool {
        nodes.isEmpty && contents.count <= 1
    }

    var containsOrphans: Bool {
        nodes.contains(where: { $0.isOrphan || $0.containsOrphans })
    }

    public init(
        id: NodeID = [],
        parent: NodeID = [],
        contents: [NodeID: LocalizationKey] = [:],
        nodes: [KeyHierarchy] = []
    ) {
        self.id = id
        self.parent = parent
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
                let id = key.key
                    .components(separatedBy: String(key.strategy.separator))
                    .map {
                        [$0]
                    }
                hierarchy.processKey(key, path: id)
            }

        return hierarchy
    }

    mutating func processKey(_ key: LocalizationKey, path nodeId: NodeID) {
        guard !nodeId.isEmpty else {
            return
        }

        guard nodeId.count > 1 else {
            contents[nodeId] = key
            return
        }

        var path = nodeId
        let component = path.removeFirst()

        // Component is reserved.
        if let first = component.first, Self.reservedTypeTokens.contains(where: { $0.caseInsensitiveCompare(first) == .orderedSame }) {
            contents[nodeId] = key
            return
        }

        // (Next) Component is Integer
        if let nextElement = path.first?.first, Int(nextElement) != nil {
            contents[nodeId] = key
            return
        }

        let id = [component]

        if let index = nodes.firstIndex(where: { $0.id == id }) {
            nodes[index].processKey(key, path: path)
        } else {
            var node = KeyHierarchy(id: id, parent: self.id)
            node.processKey(key, path: path)
            nodes.append(node)
        }
    }

    /// Creates an instance of the hierarchy in which `nodes` that only have a single `contents` item
    /// will be merged into the parent `node`.
    public func compressed(
        mergePhantoms: Bool = true,
        mergeOrphans: Bool = true,
    ) throws -> KeyHierarchy {
        var hierarchy = self
        try hierarchy.compress(
            mergePhantoms: mergePhantoms,
            mergeOrphans: mergeOrphans
        )
        return hierarchy
    }

    /// Mutates the hierarchy by merging phantom or orphaned nodes.
    public mutating func compress(
        mergePhantoms: Bool = true,
        mergeOrphans: Bool = true,
    ) throws {
        if mergePhantoms {
            try self.mergePhantoms2()
        }

        if mergeOrphans {
            try self.mergeOrphans()
        }
    }

    mutating func mergePhantoms() throws {
        var lastIteration = -1

        var phantoms = phantomNodes()
        while !phantoms.isEmpty {
            if phantoms.count == lastIteration {
                throw CocoaError(.userCancelled, userInfo: [
                    NSLocalizedDescriptionKey: "Infinite Loop Detected - Phantoms not reducing",
                ])
            } else {
                lastIteration = phantoms.count
            }

            for id in phantoms.reversed() {
                guard let phantom = node(with: id) else {
                    print("No Node With ID '\(id)'")
                    continue
                }

                guard phantom.isPhantom else {
                    print("Node '\(id)' is no longer phantom.")
                    continue
                }

                guard let subNode = phantom.nodes.first else {
                    print("Node '\(id)' has no sub-nodes.")
                    continue
                }

                if let node = removeNode(with: subNode.parent + subNode.id) {
                    mergeNode(node, into: id)
                } else {
                    print("Failed to remove node with ID '\(subNode.parent + subNode.id)'")
                }
            }

            phantoms = phantomNodes()
        }
    }

    mutating func mergePhantoms2() throws {
        var lastIteration: NodeID? = nil

        while let id = nextPhantom() {
            print("Processing Phantom Node: \(id)")
            if id == lastIteration {
                throw CocoaError(.userCancelled, userInfo: [
                    NSLocalizedDescriptionKey: "Infinite Loop Detected - Phantoms not reducing",
                ])
            } else {
                lastIteration = id
            }

            guard let phantom = node(with: id) else {
                print("No Node With ID '\(id)'")
                continue
            }

            guard phantom.isPhantom else {
                print("Node '\(id)' is no longer phantom.")
                continue
            }

            guard let subNode = phantom.nodes.first else {
                print("Node '\(id)' has no sub-nodes.")
                continue
            }

            if let node = removeNode(with: id + subNode.id) {
                mergeNode(node, into: id)
            } else {
                print("Failed to remove node with ID '\(id + subNode.id)'")
            }
        }
    }

    mutating func mergeNode(_ node: KeyHierarchy, into nodeId: NodeID) {
        guard !nodeId.isEmpty else {
            id = id + node.id
            for (key, value) in node.contents {
                contents[key] = value
            }
            for var subNode in node.nodes {
                subNode.parent = parent
                nodes.append(subNode)
            }
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

    mutating func mergeOrphans() throws {
        var lastIteration = -1

        var orphans = orphanNodes()
        while !orphans.isEmpty {
            if orphans.count == lastIteration {
                throw CocoaError(.userCancelled, userInfo: [
                    NSLocalizedDescriptionKey: "Infinite Loop Detected - Orphans not reducing",
                ])
            } else {
                lastIteration = orphans.count
            }

            for id in orphans.reversed() {
                guard let orphan = node(with: id), orphan.isOrphan else {
                    // Only process orphans which are _still_ valid.
                    continue
                }

                if let hierarchy = removeNode(with: orphan.parent + orphan.id) {
                    mergeContents(of: hierarchy, into: orphan.parent)
                }
            }

            orphans = orphanNodes()
        }
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
            nodes[index].mergeContents(of: node, into: [])
        } else if let index = nodes.firstIndex(where: { $0.id == subNode }) {
            nodes[index].mergeContents(of: node, into: path)
        }
    }

    mutating func removeNode(with id: NodeID) -> KeyHierarchy? {
        guard !id.isEmpty else {
            return nil
        }

        var path = id
        let nodeId = [path.removeFirst()]

        if let index = nodes.firstIndex(where: { $0.id == id }) {
            return nodes.remove(at: index)
        } else if let index = nodes.firstIndex(where: { $0.id == nodeId }) {
            return nodes[index].removeNode(with: path)
        }

        return nil
    }

    func node(with id: NodeID) -> KeyHierarchy? {
        guard self.id != id && !id.isEmpty else {
            return self
        }

        var path = id
        let nodeId = [path.removeFirst()]

        for node in nodes {
            if let match = node.node(with: id) {
                return match
            }

            if node.id == nodeId {
                return node.node(with: path)
            }
        }

        return nil
    }

    func nextPhantom(parent: NodeID = []) -> NodeID? {
        for node in nodes {
            let path = parent + node.id

            if node.isPhantom {
                return path
            }

            if node.containsPhantoms {
                return node.nextPhantom(parent: path)
            }
        }

        return nil
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
    func phantomNodes(parent: NodeID = []) -> [NodeID] {
        var identifiedNodes: [NodeID] = []

        for node in nodes {
            let path = parent + node.id

            if node.isPhantom {
                identifiedNodes.append(path)
            }

            if node.containsPhantoms {
                identifiedNodes.append(contentsOf: node.phantomNodes(parent: path))
            }
        }

        return identifiedNodes.sorted(using: nodeSort)
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
    func orphanNodes(parent: NodeID = []) -> [NodeID] {
        var identifiedNodes: [NodeID] = []

        for node in nodes {
            let path = parent + node.id

            if node.isOrphan {
                identifiedNodes.append(path)
            }

            if node.containsOrphans {
                identifiedNodes.append(contentsOf: node.orphanNodes(parent: path))
            }
        }

        return identifiedNodes.sorted(using: nodeSort)
    }
}
