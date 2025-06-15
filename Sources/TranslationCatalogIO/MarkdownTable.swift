/// Creates a markdown formatted table when printed.
public class MarkdownTable<T: Collection>: CustomStringConvertible {

    struct HeaderPathCountMismatch: Error {}

    private let headers: [String]
    private let paths: [PartialKeyPath<T.Element>]
    private var rows: [[String]] = []
    private var columnLengths: [Int]

    private let prefix = "| "
    private let suffix = " |"
    private let join = " | "
    private let space = " "
    private let dash = "-"
    private let newLine = "\n"

    public var description: String { render() }

    public init(paths: [PartialKeyPath<T.Element>], headers: [String]) throws {
        guard paths.count == headers.count else {
            throw HeaderPathCountMismatch()
        }

        self.headers = headers
        self.paths = paths
        columnLengths = headers.map(\.count)
    }

    public convenience init(content: T, paths: [PartialKeyPath<T.Element>], headers: [String]) throws {
        try self.init(paths: paths, headers: headers)
        for element in content {
            addRow(element)
        }
    }

    public func addRow(_ content: T.Element, strong: Bool = false, emphasis: Bool = false) {
        let row = paths.map { path in
            let value = content[keyPath: path]
            let description: String = switch value {
            case let optionalString as String?:
                optionalString ?? ""
            case let optionalBool as Bool?:
                (optionalBool != nil) ? String(describing: optionalBool!) : ""
            case let optionalInt as Int?:
                (optionalInt != nil) ? String(describing: optionalInt!) : ""
            case let optionalDouble as Double?:
                (optionalDouble != nil) ? String(describing: optionalDouble!) : ""
            default:
                String(describing: value)
            }

            switch (strong, emphasis) {
            case (true, true):
                return String(format: "**_%s_**", description)
            case (true, false):
                return String(format: "**%s**", description)
            case (false, true):
                return String(format: "_%s_", description)
            case (false, false):
                return description
            }
        }

        rows.append(row)

        for (index, value) in row.enumerated() {
            if value.count > columnLengths[index] {
                columnLengths[index] = value.count
            }
        }
    }

    public func render() -> String {
        var output = ""
        output.append(prefix)
        output.append(headers.enumerated().map { $0.element.padding(toLength: columnLengths[$0.offset], withPad: space, startingAt: 0) }.joined(separator: join))
        output.append(suffix)
        output.append(newLine)
        output.append(prefix)
        output.append(columnLengths.map { "".padding(toLength: $0, withPad: dash, startingAt: 0) }.joined(separator: join))
        output.append(suffix)
        output.append(newLine)
        for row in rows {
            output.append(prefix)
            output.append(row.enumerated().map { $0.element.padding(toLength: columnLengths[$0.offset], withPad: space, startingAt: 0) }.joined(separator: join))
            output.append(suffix)
            output.append(newLine)
        }
        return output
    }
}
