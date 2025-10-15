import Foundation
import LocaleSupport
import TranslationCatalog

public struct KeyHierarchy {

    enum HierarchyError: Error {
        case emptyNodeID
        case emptyNodePath
        case reservedType(Any.Type)
        case reservedTypeToken(String)
        case unexpectedNodeIdComponents
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

    public private(set) var id: KeyNodeID
    public private(set) var parent: KeyNodePath
    public private(set) var contents: [KeyNodeID: LocalizationKey]
    public private(set) var nodes: [KeyHierarchy]

    private let pathSort = NodePathSortComparator()
    private let idSort = NodeIDSortComparator()

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

    var sortedContentsKeys: [KeyNodeID] {
        contents.keys.sorted(using: idSort)
    }

    var sortedNodes: [KeyHierarchy] {
        nodes.sorted { lhs, rhs in
            idSort.compare(lhs.id, rhs.id) == .orderedAscending
        }
    }

    public init(
        id: KeyNodeID = [],
        parent: KeyNodePath = [],
        contents: [KeyNodeID: LocalizationKey] = [:],
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
                try LocalizationKey(
                    key: $0.key,
                    defaultValue: $0.defaultValue.encodingDarwinStrings(),
                    comment: $0.context
                )
            }
            .forEach { key in
                let id = key.key
                    .components(separatedBy: String(key.strategy.separator))
                    .map {
                        [$0]
                    }

                try hierarchy.processKey(key, path: id)
            }

        return hierarchy
    }

    mutating func processKey(_ key: LocalizationKey, path: KeyNodePath) throws {
        guard !path.isEmpty else {
            throw HierarchyError.emptyNodePath
        }

        var components = path
        let nodeId = components.removeFirst()

        guard nodeId.count == 1 else {
            throw HierarchyError.unexpectedNodeIdComponents
        }

        guard let component = nodeId.first else {
            throw HierarchyError.unexpectedNodeIdComponents
        }

        guard !components.isEmpty else {
            if let token = Self.reservedTypeTokens.first(where: { $0.caseInsensitiveCompare(component) == .orderedSame }) {
                throw HierarchyError.reservedTypeToken(token)
            }

            if Int(component) != nil {
                throw HierarchyError.reservedType(Int.self)
            }

            contents[nodeId] = key
            return
        }

        let _nodeId: KeyNodeID
        let _path: KeyNodePath

        let nextNodeId = components.removeFirst()

        guard nextNodeId.count == 1 else {
            throw HierarchyError.unexpectedNodeIdComponents
        }

        guard let nextComponent = nextNodeId.first else {
            throw HierarchyError.unexpectedNodeIdComponents
        }

        let typeReservation = Self.reservedTypeTokens.contains(where: { $0.caseInsensitiveCompare(component) == .orderedSame })
        let integerCheck = Int(nextComponent) != nil

        switch (typeReservation, integerCheck) {
        case (false, false):
            _nodeId = nodeId
            _path = [nextNodeId] + components
        default:
            _nodeId = [component, nextComponent]
            _path = components
        }

        guard !_path.isEmpty else {
            contents[_nodeId] = key
            return
        }

        var _parent = parent
        if _parent.first == [] {
            _parent.removeFirst()
        }
        _parent.append(id)

        if let index = nodes.firstIndex(where: { $0.id == _nodeId }) {
            try nodes[index].processKey(key, path: _path)
        } else {
            var node = KeyHierarchy(id: _nodeId, parent: _parent)
            if !_path.isEmpty {
                try node.processKey(key, path: _path)
            }
            nodes.append(node)
        }
    }

    func node(at path: KeyNodePath) -> KeyHierarchy? {
        guard !path.isEmpty else {
            return self
        }

        var components = path
        let nodeId = components.removeFirst()

        guard let node = nodes.first(where: { $0.id == nodeId }) else {
            return nil
        }

        return node.node(at: components)
    }

    mutating func removeNode(at path: KeyNodePath) -> KeyHierarchy? {
        guard !path.isEmpty else {
            return nil
        }

        var components = path
        let nodeId = components.removeFirst()

        guard let index = nodes.firstIndex(where: { $0.id == nodeId }) else {
            return nil
        }

        guard !components.isEmpty else {
            return nodes.remove(at: index)
        }

        return nodes[index].removeNode(at: components)
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
    func orphanNodes(breadcrumb: KeyNodePath = []) -> [KeyNodePath] {
        var identifiedNodes: [KeyNodePath] = []

        for node in nodes {
            let path = breadcrumb + [node.id]

            if node.isOrphan {
                identifiedNodes.append(path)
            }

            if node.containsOrphans {
                identifiedNodes.append(contentsOf: node.orphanNodes(breadcrumb: path))
            }
        }

        return identifiedNodes.sorted(using: pathSort)
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
    func phantomNodes(breadcrumb: KeyNodePath = []) -> [KeyNodePath] {
        var identifiedNodes: [KeyNodePath] = []

        for node in nodes {
            let path = breadcrumb + [node.id]

            if node.isPhantom {
                identifiedNodes.append(path)
            }

            if node.containsPhantoms {
                identifiedNodes.append(contentsOf: node.phantomNodes(breadcrumb: path))
            }
        }

        return identifiedNodes.sorted(using: pathSort)
    }

    /// Creates an instance of the hierarchy in which `nodes` that only have a single `contents` item
    /// will be merged into the parent `node`.
    public func compressed(
        mergePhantoms: Bool = true,
        mergeOrphans: Bool = true
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
        mergeOrphans: Bool = true
    ) throws {
        if mergePhantoms {
            try self.mergePhantoms()
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

            for path in phantoms.reversed() {
                guard let phantom = node(at: path) else {
                    continue
                }

                guard phantom.isPhantom else {
                    continue
                }

                guard let subNode = phantom.nodes.first else {
                    continue
                }

                let subNodePath = subNode.parent + [subNode.id]

                guard let node = removeNode(at: subNodePath) else {
                    continue
                }

                mergeNode(node, intoNodeAt: path)
            }

            phantoms = phantomNodes()
        }
    }

    mutating func mergeNode(_ node: KeyHierarchy, intoNodeAt path: KeyNodePath) {
        guard !path.isEmpty else {
            var newId = id
            newId.append(contentsOf: node.id)
            id = newId

            for (nodeId, key) in node.contents {
                contents[nodeId] = key
            }

            for var subNode in node.nodes {
                subNode.parent = parent + [newId]
                nodes.append(subNode)
            }

            return
        }

        var components = path
        let nodeId = components.removeFirst()

        guard let index = nodes.firstIndex(where: { $0.id == nodeId }) else {
            return
        }

        nodes[index].mergeNode(node, intoNodeAt: components)
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

            for path in orphans.reversed() {
                guard let orphan = node(at: path) else {
                    continue
                }

                guard orphan.isOrphan else {
                    continue
                }

                guard let node = removeNode(at: path) else {
                    continue
                }

                var _parent = path
                _parent.removeLast()

                mergeContents(of: node, intoNodeAt: _parent)
            }

            orphans = orphanNodes()
        }
    }

    mutating func mergeContents(of node: KeyHierarchy, intoNodeAt path: KeyNodePath) {
        guard !path.isEmpty else {
            for (nodeId, key) in node.contents {
                var newId = nodeId
                newId.insert(contentsOf: node.id, at: 0)

                contents[newId] = key
            }

            return
        }

        var components = path
        let nodeId = components.removeFirst()

        guard let index = nodes.firstIndex(where: { $0.id == nodeId }) else {
            return
        }

        nodes[index].mergeContents(of: node, intoNodeAt: components)
    }
}
