//
//  UpdatableCopy.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 30/07/2025.
//

public import SwiftSyntax
import SwiftSyntaxBuilder
public import SwiftSyntaxMacros
import Foundation

public enum UpdatableCopyMacro: MemberMacro {
  public static func expansion(
    of node: AttributeSyntax,
    providingMembersOf declaration: some DeclGroupSyntax,
    conformingTo protocols: [TypeSyntax],
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {
    _ = protocols
    
    // Extract the properties from the type--must be a struct
    guard let storedProperties = declaration.as(StructDeclSyntax.self)?.storedProperties(),
      !storedProperties.isEmpty else { return [] }

    let funcArguments = storedProperties
      .compactMap { property -> (name: String, type: String)? in
        /// Get the property's name (a.k.a. identifier)...
        guard let patternBinding = property.bindings.first?.as(PatternBindingSyntax.self) else { return nil }
        guard let name = patternBinding.pattern.as(IdentifierPatternSyntax.self)?.identifier else { return nil }
        // ...and then the property's type...
        guard let type = patternBinding.typeAnnotation?.as(TypeAnnotationSyntax.self)?.trimmed.description
          .replacingOccurrences(of: "?", with: "")
        else { return nil }

        return (name: name.text, type: type)
      }

    let optionalNames: Set<String> = Set(
      storedProperties.compactMap { property in
        guard
          let binding = property.bindings.first,
          let id = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier,
          binding.typeAnnotation?.type.as(OptionalTypeSyntax.self) != nil
        else {
          return nil
        }
        return id.text
      }
    )

    let funcBody: ExprSyntax = """
      .init(
      \(raw: funcArguments.map {arg in
              if optionalNames.contains(arg.name) {
                // Explicit nil assignment preserved
                return "\(arg.name): \(arg.name)"
              } else {
                return "\(arg.name): \(arg.name) ?? self.\(arg.name)"
              }
          }.joined(separator: ", \n"))
      )
      """

    guard
      let funcDeclSyntax = try? FunctionDeclSyntax(
        SyntaxNodeString(
          stringLiteral: """
            public func copy(
            \(funcArguments.map { "\($0.name)\($0.type)? = nil" }.joined(separator: ", \n"))
            ) -> Self
            """.trimmingCharacters(in: .whitespacesAndNewlines)
        ),
        bodyBuilder: {
          funcBody
        }
      ),
      let finalDeclaration = DeclSyntax(funcDeclSyntax)
    else {
      return []
    }

    return [finalDeclaration]
  }
}

extension VariableDeclSyntax {
  /// Check this variable is a stored property
  var isStoredProperty: Bool {
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
        case .keyword(.willSet), .keyword(.didSet):
          // stored properties can have observers
          break
        default:
          // everything else makes it a computed property
          return false
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
  func storedProperties() -> [VariableDeclSyntax] {
    memberBlock.members.compactMap { member in
      guard let variable = member.decl.as(VariableDeclSyntax.self),
        variable.isStoredProperty
      else { return nil }

      return variable
    }
  }
}

// MARK: Macro Types

extension UpdatableCopyMacro {
  //    public struct OptionalResult {
  //
  //    }

  typealias OptionalResult = Backing

  public enum Backing<Wrapped, R> {
    case keepCurrent
    case new(Wrapped)
    case removeCurrent(R)
  }
}

extension UpdatableCopyMacro.OptionalResult: ExpressibleByNilLiteral where R == Void {
  public init(nilLiteral: ()) {
    self = .removeCurrent
  }
}

extension UpdatableCopyMacro.OptionalResult where R == Void {
  public static var removeCurrent: Self { .removeCurrent(Void()) }
}

//extension UpdatedCopyMacro.OptionalResult where R == Never {
//  public func asSwiftOptional() -> Optional<Wrapped> {
//    switch self {
//      case
//    }
//  }
//}

struct Product {
  let name: String
  let price: Double
  let oldPrice: Double?

  func copy(
    name: UpdatableCopyMacro.OptionalResult<String, Never> = .keepCurrent,
    price: UpdatableCopyMacro.OptionalResult<Double, Never> = .keepCurrent,
    oldPrice: UpdatableCopyMacro.OptionalResult<Double, Void> = .keepCurrent
  ) -> Self {
    let name: String =
      switch name {
      case .keepCurrent: self.name
      case .new(let newName): newName
      }

    let price: Double =
      switch price {
      case .keepCurrent: self.price
      case .new(let newPrice): newPrice
      }

    let oldPrice: Double? =
      switch oldPrice {
      case .keepCurrent: self.price
      case .new(let newOldPrice): newOldPrice
      case .removeCurrent: nil
      }

    return Self(
      name: name,
      price: price,
      oldPrice: oldPrice
    )
  }
}

private func testCopy(product: Product) {
  product.copy(name: .new("RenamedProduct"))

  product.copy(oldPrice: .new(99.9))
  product.copy(oldPrice: nil)
  product.copy(oldPrice: .removeCurrent)
}
