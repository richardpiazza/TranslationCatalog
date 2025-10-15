import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder
import TranslationCatalog

public extension KeyHierarchy {
    /// Data containing a file with a hierarchy of enums conforming to `LocalizedStringConvertible`.
    func localizedStringConvertible(rootDeclaration name: String = "LocalizedStrings") -> Data {
        let sourceFile = SourceFileSyntax {
            CodeBlockItemListSyntax {
                ImportDeclSyntax.localeSupport

                EnumDeclSyntax.stringEnumerationDecl(for: self, named: name)
            }
        }

        var dataStream = DataOutputStream()
        sourceFile.formatted().write(to: &dataStream)
        return dataStream.data
    }

    func syntaxTree() -> String {
        String(decoding: localizedStringConvertible(), as: UTF8.self)
    }

    internal var declName: String {
        id.map(\.capitalized).joined()
    }
}

extension [String] {
    var lowerCamelCased: String {
        enumerated()
            .map { index, value in
                index == 0 ? value.lowercased() : value.capitalized
            }
            .joined()
    }
}

extension ImportDeclSyntax {
    static let localeSupport: ImportDeclSyntax = ImportDeclSyntax(
        path: ImportPathComponentListSyntax {
            ImportPathComponentSyntax(name: TokenSyntax("LocaleSupport"))
        }
    )
}

extension EnumDeclSyntax {
    static func stringEnumerationDecl(
        for hierarchy: KeyHierarchy,
        named name: String? = nil
    ) -> EnumDeclSyntax {
        var inheritanceClause: InheritanceClauseSyntax?
        if !hierarchy.contents.isEmpty {
            inheritanceClause = InheritanceClauseSyntax(
                inheritedTypes: InheritedTypeListSyntax {
                    InheritedTypeSyntax(type: TypeSyntax("String"))
                    InheritedTypeSyntax(type: TypeSyntax("LocalizedStringConvertible"))
                }
            )
        }

        return EnumDeclSyntax(
            leadingTrivia: .newlines(2),
            name: TokenSyntax(stringLiteral: name ?? hierarchy.declName),
            inheritanceClause: inheritanceClause
        ) {
            for key in hierarchy.sortedContentsKeys {
                if let content = hierarchy.contents[key] {
                    EnumCaseDeclSyntax.stringEnumerationCase(
                        key: key.lowerCamelCased,
                        value: content.defaultValue,
                        comment: content.comment
                    )
                }
            }

            if !hierarchy.contents.isEmpty {
                let prefix = (hierarchy.parent + [hierarchy.id]).flatMap { $0 }.lowerCamelCased
                if !prefix.isEmpty {
                    VariableDeclSyntax.stringValuePrefix(prefix)
                }
            }

            for node in hierarchy.sortedNodes {
                stringEnumerationDecl(for: node)
            }
        }
    }
}

extension EnumCaseDeclSyntax {
    static func stringEnumerationCase(key: String, value: String, comment: String?) -> EnumCaseDeclSyntax {
        var trivia: Trivia = []
        if let comment {
            trivia = [
                .docLineComment("/// \(comment)"),
                .newlines(1),
            ]
        }

        let token: TokenSyntax = if KeyHierarchy.reservedVariableTokens.contains(key) {
            TokenSyntax(stringLiteral: "`\(key)`")
        } else {
            TokenSyntax(stringLiteral: key)
        }

        let rawValue: InitializerClauseSyntax? = if key != value {
            InitializerClauseSyntax(value: StringLiteralExprSyntax(content: value))
        } else {
            nil
        }

        return EnumCaseDeclSyntax(
            leadingTrivia: trivia
        ) {
            EnumCaseElementListSyntax {
                EnumCaseElementSyntax(
                    name: token,
                    rawValue: rawValue
                )
            }
        }
    }
}

extension VariableDeclSyntax {
    static func stringValuePrefix(_ value: String) -> VariableDeclSyntax {
        VariableDeclSyntax(
            leadingTrivia: .newlines(2),
            bindingSpecifier: TokenSyntax("var")
        ) {
            PatternBindingSyntax(
                pattern: IdentifierPatternSyntax(identifier: TokenSyntax("prefix")),
                typeAnnotation: TypeAnnotationSyntax(
                    type: OptionalTypeSyntax(wrappedType: IdentifierTypeSyntax(name: TokenSyntax("String")))
                ),
                accessorBlock: AccessorBlockSyntax(
                    accessors: .getter(CodeBlockItemListSyntax { StringLiteralExprSyntax(content: value) })
                )
            )
        }
    }
}

struct DataOutputStream: TextOutputStream, CustomStringConvertible {
    var data: Data = Data()

    var description: String {
        String(data: data, encoding: .utf8) ?? ""
    }

    mutating func write(_ string: String) {
        if let data = string.data(using: .utf8) {
            self.data.append(data)
        }
    }
}
