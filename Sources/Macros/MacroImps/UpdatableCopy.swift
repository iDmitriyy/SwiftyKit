//
//  UpdatableCopy.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 30/07/2025.
//

@_spi(SwiftyKitBuiltinTypes) import struct IndependentDeclarations.TextError

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
    
    let storedProperties = structDeclaration.storedProperties()
    let accessLevel = "public" // TODO: .
    let funcName = "copyUpdating" // The same name must be spicified in macro declaration file
    let selfType = "Self"
    
    let emptyArgsFuncInterfaceString = "func \(funcName)() -> \(selfType)"
    
    guard !storedProperties.isEmpty else {
      throw TextError.message("Declaration has no stored properties, generation of `\(emptyArgsFuncInterfaceString)` doesn't make sense")
    }

    let funcArguments = storedProperties.compactMap { property -> (name: String, type: String)? in
        /// Get the property's name (a.k.a. identifier)...
        guard let patternBinding: PatternBindingSyntax = property.bindings.first else { return nil }
        guard let name = patternBinding.pattern.as(IdentifierPatternSyntax.self)?.identifier else { return nil }
        // ...and then the property's type...
        guard let typeAnnotation: TypeAnnotationSyntax = patternBinding.typeAnnotation else { return nil }
      
        let type = typeAnnotation.trimmed.description.replacingOccurrences(of: "?", with: "")

        return (name: name.text, type: type)
    }
    
    let optionalNames = storedProperties.compactMap { property -> String? in
      guard let binding = property.bindings.first,
        let id = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier,
        binding.typeAnnotation?.type.as(OptionalTypeSyntax.self) != nil
      else {
        return nil
      }
      return id.text
    }.apply(transform: Set.init)
    
    let funcInterfaceArgsList = funcArguments.map {
      print("____________ UpdatableCopyMacro", $0.type)
      return "\($0.name)\($0.type)? = nil"
    }.joined(separator: ",\n")
    
    let funcInterfaceString = """
        \(accessLevel) func \(funcName)(
          \(funcInterfaceArgsList)
        ) -> \(selfType)
        """
    
    let funcInterface = SyntaxNodeString(stringLiteral: funcInterfaceString)
    
    let funcBody: ExprSyntax = """
      \(raw: selfType)(
      \(raw: funcArguments.map { arg in
              if optionalNames.contains(arg.name) {
                return "\(arg.name): \(arg.name)"
              } else {
                return "\(arg.name): \(arg.name) ?? self.\(arg.name)"
              }
          }.joined(separator: ",\n"))
      )
      """
    
    let funcDecl = try FunctionDeclSyntax(funcInterface, bodyBuilder: { funcBody })
    
    guard let funcDeclaration = DeclSyntax(funcDecl) else {
      throw TextError.message("`func \(funcName)(...) -> \(selfType)` FunctionDeclSyntax was created, but DeclSyntax failed to init")
    }
    
    let emptyArgsFuncDeclaration = try makeEmptyArgsFuncDecl(emptyArgsFuncInterface: emptyArgsFuncInterfaceString,
                                                             accessLevel: accessLevel)
    return [funcDeclaration, emptyArgsFuncDeclaration]
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

extension VariableDeclSyntax {
  /// Check this variable is a stored property
  fileprivate var isStoredProperty: Bool {
    guard let binding = bindings.first,
      bindings.count == 1,
      modifiers.contains(where: {
        $0.name == .keyword(.public)
      }) || modifiers.isEmpty
    else { return false }

    switch binding.accessorBlock?.accessors {
    case .none:
      return true

    case .accessors(let node):
      for accessor in node {
        switch accessor.accessorSpecifier.tokenKind {
        case .keyword(.willSet), .keyword(.didSet): break // stored properties can have observers
        default: return false // everything else mean it is a computed property
        }
      }
      return true

    case .getter:
      return false
    }
  }
}

extension DeclGroupSyntax {
  /// Get the stored properties from the declaration based on syntax.
  fileprivate func storedProperties() -> [VariableDeclSyntax] {
    memberBlock.members.compactMap { member in
      guard let variable = member.decl.as(VariableDeclSyntax.self), variable.isStoredProperty else { return nil }
      return variable
    }
  }
}

// MARK: - Macro Types

extension UpdatableCopyMacro {
  /// R is used as availability Type-token for remove operation.
  /// Remove operation is only possible for Optional values, so R == Void is used for Optionals.
  /// For non-Optional values Never is used, so removing is impossible and it is statically proven.
  public struct CopyingChoice<NewValue, R> {
    fileprivate let variant: _CopyingChoice<NewValue, R>
    
    private init(variant: _CopyingChoice<NewValue, R>) {
      self.variant = variant
    }
    
    public static var takeValueFromSource: Self { Self(variant: .copyFromSource) }
    public static func new(_ newValue: NewValue) -> Self { Self(variant: .new(newValue)) }
    public static func removeCurrent(_ removeAvailabilityToken: R) -> Self { Self(variant: .removeCurrent(removeAvailabilityToken)) }
  }

  fileprivate enum _CopyingChoice<NewValue, R> {
    case copyFromSource
    case new(NewValue)
    case removeCurrent(R)
  }
}

extension UpdatableCopyMacro.CopyingChoice: ExpressibleByNilLiteral where R == Void {
  public init(nilLiteral: ()) {
    self = .removeCurrent(nilLiteral)
  }
}

extension UpdatableCopyMacro.CopyingChoice where R == Void {
  @available(*, unavailable, message: "Use nil literal instead")
  public static var removeCurrent: Self { .removeCurrent(Void()) }
}

// MARK: Choice functions

public func updatedCopy_optionalValue<V>(for choice: UpdatableCopyMacro.CopyingChoice<V, Void>, currentValue: V?) -> V? {
  switch choice.variant {
    case .copyFromSource: currentValue
    case .new(let newValue): newValue
    case .removeCurrent: nil
  }
}

public func updatedCopy_value<V>(for choice: UpdatableCopyMacro.CopyingChoice<V, Never>, currentValue: V) -> V {
  switch choice.variant {
    case .copyFromSource: currentValue
    case .new(let newValue): newValue
  }
}

// MARK: - Example

struct Product {
  let name: String
  let price: Double
  let oldPrice: Double?

  func copyUpdating(
    name nameChoice: UpdatableCopyMacro.CopyingChoice<String, Never> = .takeValueFromSource,
    price priceChoice: UpdatableCopyMacro.CopyingChoice<Double, Never> = .takeValueFromSource,
    oldPrice oldPriceChoice: UpdatableCopyMacro.CopyingChoice<Double, Void> = .takeValueFromSource
  ) -> Self {
    
    return Self(
      name: updatedCopy_value(for: nameChoice, currentValue: self.name),
      price: updatedCopy_value(for: priceChoice, currentValue: self.price),
      oldPrice: updatedCopy_optionalValue(for: oldPriceChoice, currentValue: self.oldPrice)
    )
  }
}

private func testCopy(product: Product) {
  product.copyUpdating(name: .new("RenamedProduct"))
//product.copyWith(oldPrice: .new(99.9))
  product.copyUpdating(oldPrice: .new(99.9))
  product.copyUpdating(oldPrice: nil)
//   product.copyUpdating(oldPrice: .removeCurrent) // impossible, Error: 'removeCurrent' is unavailable: Use nil literal instead
}
