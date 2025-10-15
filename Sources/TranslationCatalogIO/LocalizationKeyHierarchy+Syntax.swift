import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder
import TranslationCatalog

public extension LocalizationKeyHierarchy {
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

    internal var declName: String {
        id.map { $0.capitalized }.joined()
    }
}

extension EnumDeclSyntax {
    static func stringEnumerationDecl(
        for hierarchy: LocalizationKeyHierarchy,
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
