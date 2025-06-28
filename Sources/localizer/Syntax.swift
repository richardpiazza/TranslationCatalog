import Foundation
import ArgumentParser
import SwiftSyntax
import SwiftSyntaxBuilder

struct Syntax: AsyncParsableCommand {
    
    static var configuration: CommandConfiguration = CommandConfiguration(
        commandName: "syntax"
    )
    
    func run() async throws {
        let sourceFile = SourceFileSyntax {
            CodeBlockItemListSyntax {
                ImportDeclSyntax(
                    path: ImportPathComponentListSyntax {
                        ImportPathComponentSyntax(name: TokenSyntax("LocaleSupport"))
                    }
                )
                
                EnumDeclSyntax(
                    leadingTrivia: .newlines(2),
                    name: TokenSyntax("Strings"),
                    inheritanceClause: InheritanceClauseSyntax(
                        inheritedTypes: InheritedTypeListSyntax {
                            InheritedTypeSyntax(type: TypeSyntax("String"))
                            InheritedTypeSyntax(type: TypeSyntax("LocalizedStringConvertible"))
                        }
                    )
                ) {
                    EnumCaseDeclSyntax {
                        EnumCaseElementListSyntax {
                            EnumCaseElementSyntax(
                                name: TokenSyntax("something"),
                                rawValue: InitializerClauseSyntax(value: StringLiteralExprSyntax(content: "Have a nice day!"))
                            )
                        }
                    }
                    
                    VariableDeclSyntax(
                        leadingTrivia:  .newlines(2),
                        bindingSpecifier: TokenSyntax("var")
                    ) {
                        PatternBindingSyntax(
                            pattern: IdentifierPatternSyntax(identifier: TokenSyntax("prefix")),
                            typeAnnotation: TypeAnnotationSyntax(
                                type: OptionalTypeSyntax(wrappedType: IdentifierTypeSyntax(name: TokenSyntax("String")))
                            ),
                            accessorBlock: AccessorBlockSyntax(
                                accessors: .getter(CodeBlockItemListSyntax { StringLiteralExprSyntax(content: "anything") })
                            )
                        )
                    }
                }
            }
        }
        
        var dataStream = DataOutputStream()
        sourceFile.formatted().write(to: &dataStream)
        print(dataStream.description)
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
