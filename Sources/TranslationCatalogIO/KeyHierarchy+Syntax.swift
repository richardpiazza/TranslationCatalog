import Foundation
import LocaleSupport
import SwiftBasicFormat
import SwiftSyntax
import SwiftSyntaxBuilder
import TranslationCatalog

public extension KeyHierarchy {
    /// Data containing a file with a hierarchy of enums conforming to `LocalizedStringConvertible`.
    func localizedStringConvertible(rootDeclaration name: String = "LocalizedStrings") -> Data {
        let sourceFile = SourceFileSyntax {
            CodeBlockItemListSyntax {
                ImportDeclSyntax(
                    path: ImportPathComponentListSyntax {
                        ImportPathComponentSyntax(name: TokenSyntax("LocaleSupport"))
                    }
                )

                EnumDeclSyntax.localizedStringConvertibleEnumerationDecl(for: self, named: name)
            }
        }

        var dataStream = DataOutputStream()
        sourceFile.formatted().write(to: &dataStream)
        return dataStream.data
    }

    /// Data containing a file with a hierarchy of enums extending `LocalizedStringKey`.
    func localizedStringKey() -> Data {
        let sourceFile = SourceFileSyntax {
            CodeBlockItemListSyntax {
                ImportDeclSyntax(
                    path: ImportPathComponentListSyntax {
                        ImportPathComponentSyntax(name: TokenSyntax("SwiftUI"))
                    }
                )

                ExtensionDeclSyntax(
                    leadingTrivia: .newlines(2),
                    attributes: AttributeListSyntax([.attribute("@MainActor")]),
                    extendedType: TypeSyntax(stringLiteral: "LocalizedStringKey")
                ) {
                    let hierarchy = self
                    for key in hierarchy.sortedContentsKeys {
                        if let content = hierarchy.contents[key] {
                            VariableDeclSyntax.localizedStringKey(
                                name: key.lowerCamelCased,
                                value: content.key,
                                comment: content.defaultValue.isEmpty ? nil : content.defaultValue
                            )
                        }
                    }

                    for node in hierarchy.sortedNodes {
                        EnumDeclSyntax.localizedStringKeyEnumerationDecl(for: node)
                    }
                }
            }
        }

        var dataStream = DataOutputStream()
        sourceFile.formatted().write(to: &dataStream)
        return dataStream.data
    }

    func syntaxTree(
        style: SyntaxStyle = .localeSupport,
        rootDeclaration name: String = "LocalizedStrings"
    ) -> String {
        switch style {
        case .localeSupport:
            String(
                decoding: localizedStringConvertible(rootDeclaration: name),
                as: UTF8.self
            )
        case .swiftUI:
            String(
                decoding: localizedStringKey(),
                as: UTF8.self
            )
        }
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

extension EnumDeclSyntax {
    static func localizedStringConvertibleEnumerationDecl(
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
                    EnumCaseDeclSyntax.localizedStringConvertibleEnumerationCase(
                        key: key.lowerCamelCased,
                        value: content.defaultValue,
                        comment: content.comment
                    )
                }
            }

            if !hierarchy.contents.isEmpty {
                let prefix = hierarchy.prefix.flatMap { $0 }.lowerCamelCased
                if !prefix.isEmpty {
                    VariableDeclSyntax.stringValuePrefix(prefix)
                }
            }

            for node in hierarchy.sortedNodes {
                localizedStringConvertibleEnumerationDecl(for: node)
            }
        }
    }

    static func localizedStringKeyEnumerationDecl(
        for hierarchy: KeyHierarchy
    ) -> EnumDeclSyntax {
        EnumDeclSyntax(
            leadingTrivia: .newlines(2),
            name: TokenSyntax(stringLiteral: hierarchy.declName)
        ) {
            for key in hierarchy.sortedContentsKeys {
                if let content = hierarchy.contents[key] {
                    VariableDeclSyntax.localizedStringKey(
                        name: key.lowerCamelCased,
                        value: content.key,
                        comment: content.defaultValue.isEmpty ? nil : content.defaultValue
                    )
                }
            }

            for node in hierarchy.sortedNodes {
                EnumDeclSyntax.localizedStringKeyEnumerationDecl(for: node)
            }
        }
    }
}

extension EnumCaseDeclSyntax {
    static func localizedStringConvertibleEnumerationCase(key: String, value: String, comment: String?) -> EnumCaseDeclSyntax {
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

    static func localizedStringKey(name: String, value: String, comment: String?) -> VariableDeclSyntax {
        var trivia: Trivia?
        if let comment {
            trivia = [
                .docLineComment("/// \(comment)"),
                .newlines(1),
            ]
        }

        return VariableDeclSyntax(
            leadingTrivia: trivia,
            modifiers: DeclModifierListSyntax([
                DeclModifierSyntax(name: .keyword(.static)),
            ]),
            bindingSpecifier: .keyword(.let)
        ) {
            PatternBindingSyntax(
                pattern: IdentifierPatternSyntax(identifier: .identifier(name)),
                typeAnnotation: TypeAnnotationSyntax(
                    type: IdentifierTypeSyntax(name: .identifier("LocalizedStringKey"))
                ),
                initializer: InitializerClauseSyntax(
                    value: StringLiteralExprSyntax(
                        openingQuote: .stringQuoteToken(),
                        segments: StringLiteralSegmentListSyntax([
                            .stringSegment(StringSegmentSyntax(content: .stringSegment(value))),
                        ]),
                        closingQuote: .stringQuoteToken()
                    )
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
