/// Creates a markdown formatted table when printed.
struct MarkdownTable: CustomStringConvertible {
    let header: [String]
    private var contents: [[String]] = []
    private var columnLengths: [Int] = []
    
    private let prefix = "| "
    private let suffix = " |"
    private let join = " | "
    private let space = " "
    private let dash = "-"
    private let newLine = "\n"
    
    init(_ header: String...) {
        self.header = header
        header.forEach({
            columnLengths.append($0.count)
        })
    }
    
    mutating func addContent(_ content: String...) {
        contents.append(content)
        content.enumerated().forEach({
            if $0.element.count > columnLengths[$0.offset] {
                columnLengths[$0.offset] = $0.element.count
            }
        })
    }
    
    var description: String {
        var output = ""
        output.append(prefix)
        output.append(header.enumerated().map({ $0.element.padding(toLength: columnLengths[$0.offset], withPad: space, startingAt: 0)}).joined(separator: join))
        output.append(suffix)
        output.append(newLine)
        output.append(prefix)
        output.append(columnLengths.map({ "".padding(toLength: $0, withPad: dash, startingAt: 0)}).joined(separator: join))
        output.append(suffix)
        output.append(newLine)
        contents.forEach { element in
            output.append(prefix)
            output.append(element.enumerated().map({ $0.element.padding(toLength: columnLengths[$0.offset], withPad: space, startingAt: 0)}).joined(separator: join))
            output.append(suffix)
            output.append(newLine)
        }
        return output
    }
}
