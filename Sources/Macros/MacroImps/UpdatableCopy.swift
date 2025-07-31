//
//  UpdatableCopy.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 30/07/2025.
//

import MacroSymbols
@_spi(SwiftyKitBuiltinTypes) import struct IndependentDeclarations.TextError

fileprivate let typesNamespace = "\(UpdatableCopyMacro_.self)"

public enum UpdatableCopyMacro: MemberMacro {
  public static func expansion(
    of node: AttributeSyntax,
    providingMembersOf declaration: some DeclGroupSyntax,
    conformingTo protocols: [TypeSyntax],
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {
    // Extract the properties from the type. Only struct Types are supported for now.
    guard let structDeclaration = declaration.as(StructDeclSyntax.self) else {
      throw TextError.message("UpdatableCopy Macro can only be applied to structs yet")
    }
    
    let storedPropertiesDecl = structDeclaration.storedProperties()
    let accessLevel = "public" // TODO: .
    let funcName = "copyUpdating" // The same name must be spicified in macro declaration file – @attached(member, names: named(copyUpdating))
    let selfType = "Self"
    
    let emptyArgsFuncInterfaceString = "func \(funcName)() -> \(selfType)"
    
    guard !storedPropertiesDecl.isEmpty else {
      throw TextError.message("Declaration has no stored properties, generation of `\(emptyArgsFuncInterfaceString)` doesn't make sense")
    }

    let storedProperties = storedProperties(propertiesDecl: storedPropertiesDecl)
        
    let funcDecl = try makeFuncDecl(accessLevel: accessLevel,
                                    funcName: funcName,
                                    storedProperties: storedProperties,
                                    selfType: selfType)
    
    let emptyArgsFuncDecl = try makeEmptyArgsFuncDecl(emptyArgsFuncInterface: emptyArgsFuncInterfaceString,
                                                      accessLevel: accessLevel)
    return [funcDecl, emptyArgsFuncDecl]
  }
  
  // MARK: - Expansion func decomposition
  
  private static func storedProperties(propertiesDecl: [VariableDeclSyntax]) -> [(name: String, type: String, isOptional: Bool)] {
    propertiesDecl.compactMap { property in
      /// Get the property's name (a.k.a. identifier)...
      guard let patternBinding: PatternBindingSyntax = property.bindings.first else { return nil }
      guard let propertyIdentifier = patternBinding.pattern.as(IdentifierPatternSyntax.self)?.identifier else { return nil }
      // ...and then the property's type...
      guard let typeAnnotation: TypeAnnotationSyntax = patternBinding.typeAnnotation else { return nil }
            
      let typeDescription = typeAnnotation.type.description
            
      let type: String
      let isOptional: Bool
      if let _ = typeAnnotation.type.as(OptionalTypeSyntax.self) {
        isOptional = true
        type = typeDescription.replacingOccurrences(of: "?", with: "")
      } else {
        isOptional = false
        type = typeDescription
      }

      return (propertyIdentifier.text, type, isOptional)
    }
  }
  
  private static func makeFuncDecl(accessLevel: String,
                                   funcName: String,
                                   storedProperties: [(name: String, type: String, isOptional: Bool)],
                                   selfType: String) throws -> DeclSyntax {
    let argsSuffix = "Choice"
    
    let funcInterface: SyntaxNodeString
    do {
      let funcInterfaceArgsList = storedProperties.map {
        return if $0.isOptional {
          "\($0.name) \($0.name)\(argsSuffix): \(typesNamespace).CopyingChoice<\($0.type), Void> = .takeValueFromSource"
        } else {
          // e.g. "price priceChoice: UpdatableCopyMacro.CopyingChoice<Double, Never> = .takeValueFromSource"
          "\($0.name) \($0.name)\(argsSuffix): \(typesNamespace).CopyingChoice<\($0.type), Never> = .takeValueFromSource"
        }
      }.joined(separator: ",\n")
      
      let funcInterfaceString = """
          \(accessLevel) func \(funcName)(
            \(funcInterfaceArgsList)
          ) -> \(selfType)
          """
      funcInterface = SyntaxNodeString(stringLiteral: funcInterfaceString)
    }
    
    let funcBody: ExprSyntax
    do {
      let calledInitializerArgsList = storedProperties.map {
        if $0.isOptional {
          "\($0.name): updatedCopy_optionalValue(for: \($0.name)\(argsSuffix), currentValue: self.\($0.name))"
        } else {
          // e.g. "price: updatedCopy_value(for: priceChoice, currentValue: self.price),"
          "\($0.name): updatedCopy_value(for: \($0.name)\(argsSuffix), currentValue: self.\($0.name))"
        }
      }.joined(separator: ",\n")
      // func body is an initializer call – Self(
      funcBody = """
        \(raw: selfType)(
        \(raw: calledInitializerArgsList)
        )
        """
    }
    
    let funcDecl = try FunctionDeclSyntax(funcInterface, bodyBuilder: { funcBody })
    
    guard let funcDecl = DeclSyntax(funcDecl) else {
      throw TextError
        .message("`func \(funcName)(...) -> \(selfType)` FunctionDeclSyntax was created, but DeclSyntax failed to init")
    }
    
    return funcDecl
  }
  
  /// Make function overload with no arguments to warn users when they don't specify at least 1 argument
  private static func makeEmptyArgsFuncDecl(emptyArgsFuncInterface: String, accessLevel: String) throws -> DeclSyntax {
    let emptyArgsMessage = "\"Using `\(emptyArgsFuncInterface)` without passing at least one argument make no sense\""
    let emptyArgsWarning = "@available(*, deprecated, message: \(emptyArgsMessage))"
    
    let emptyArgsFunc = emptyArgsWarning + "\n\(accessLevel) " + emptyArgsFuncInterface
    let emptyArgsFuncSyntaxNode = SyntaxNodeString(stringLiteral: emptyArgsFunc)
    let emptyArgsFuncDeclSyntax = try FunctionDeclSyntax(emptyArgsFuncSyntaxNode, bodyBuilder: { "return self" })
    guard let emptyArgsFuncDeclaration = DeclSyntax(emptyArgsFuncDeclSyntax) else {
      throw TextError.message("`\(emptyArgsFunc)` FunctionDeclSyntax was created, but DeclSyntax failed to init")
    }
    return emptyArgsFuncDeclaration
  }
}

// MARK: SwiftSyntax helper extensions

extension DeclGroupSyntax {
  /// Get the stored properties from the declaration based on syntax.
  fileprivate func storedProperties() -> [VariableDeclSyntax] {
    memberBlock.members.compactMap { member in
      guard let variable = member.decl.as(VariableDeclSyntax.self), variable.isStoredProperty else { return nil }
      return variable
    }
  }
}

extension VariableDeclSyntax {
  /// Check this variable is a stored property
  fileprivate var isStoredProperty: Bool {
    guard let binding = bindings.first, bindings.count == 1,
      modifiers.contains(where: {
        $0.name == .keyword(.public) // TODO: ?
      }) || modifiers.isEmpty
    else { return false }

    switch binding.accessorBlock?.accessors {
    case .none: return true
    case .getter: return false
    case .accessors(let node):
      for accessor in node {
        switch accessor.accessorSpecifier.tokenKind {
        case .keyword(.willSet), .keyword(.didSet): break // stored properties can have observers
        default: return false // everything else mean it is not a computed property
        }
      }
      return true
    }
  }
}
