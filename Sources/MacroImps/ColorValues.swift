//
//  ColorValues.swift
//  swifty-kit
//
//  Created by tmp on 29/07/2025.
//

import Foundation
private import IndependentDeclarations
import SwiftDiagnostics
//import SwiftCompilerPlugin
public import SwiftSyntax
import SwiftSyntaxBuilder
public import SwiftSyntaxMacros

@_spi(SwiftyKitBuiltinTypes) private import struct IndependentDeclarations.TextError

///      #color("#FFF") -> (red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
///      #color(0xfff) -> (red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
///
///

public struct ColorValuesFromRGBAHexMacro: HexExpressionMacro {
  public static func colorExpressionSyntax(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8) -> SwiftSyntax.ExprSyntax {
    var expr: SwiftSyntax.ExprSyntax = "ColorValues(r: \(raw: red), g: \(raw: green), b: \(raw: blue), a: \(raw: alpha))"
    expr.trailingTrivia = .lineComment(" // r: \(red), g: \(green), b: \(blue), a: \(alpha)")
    
    //      VariableDeclSyntax(leadingTrivia: [.newlines(2),
    //        .lineComment("// These members are always generated irrespective of the contents of the generated files. They are intended to exclusively centralize code symbols that would otherwise be repeated frequently."),
    //        .newlines(1)],
    //                         modifiers: [DeclModifierSyntax(name: .keyword(.private)),
    //                                     DeclModifierSyntax(name: .keyword(.static))],
    //        .let,
    //                         name: PatternSyntax(IdentifierPatternSyntax(identifier: "decoder")),
    //                         initializer: InitializerClauseSyntax(value: ExprSyntax(stringLiteral: "\(configuration.decoderExpression)")))
    //
    //      // These members are always generated irrespective of the contents of the generated files. They are intended to exclusively centralize code symbols that would otherwise be repeated frequently.
    //      private static let decoder = JSONDecoder()

    return expr
  }
}

public protocol HexExpressionMacro: ExpressionMacro {
  static func colorExpressionSyntax(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8) -> SwiftSyntax.ExprSyntax
}

extension HexExpressionMacro {
  public static func expansion(of node: some SwiftSyntax.FreestandingMacroExpansionSyntax,
                               in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> SwiftSyntax.ExprSyntax {
    guard let argument = node.arguments.first?.expression else {
      fatalError("compiler bug: macro needs one argument")
    }

    var string: String
    if let stringLiteralExpressionSyntax = argument.as(StringLiteralExprSyntax.self) {
      let segments = stringLiteralExpressionSyntax.segments
      guard segments.count == 1, case .stringSegment(let literalSegment)? = segments.first else {
        fatalError("compiler bug: macro needs a static string")
      }

      string = literalSegment.content.text
    } else if let intergerLiteralExpressionSyntex = argument.as(IntegerLiteralExprSyntax.self) {
      string = intergerLiteralExpressionSyntex.literal.text

      guard string.hasPrefix("0x") else {
        let error = TextError.message("integerLiteral MustBe Hexadecimal")
        // TODO: - .
        // TextError: DiagnosticMessage
        //              Diagnostic(node: Syntax(node), message: error)
        throw error
      }

      string = string.replacingOccurrences(of: "0x", with: "#")
      string = string.replacingOccurrences(of: "_", with: "")  // when formatted with underscores like 0x0011_AAFF
    } else {
      fatalError("compiler bug: unknown argument type")
    }

    do {
      let (r, g, b, a) = try rgbaUInt8(rgbaHexString: string)
      return colorExpressionSyntax(red: r, green: g, blue: b, alpha: a)
    } catch {
      // TODO: - .
      //            context.diagnose( HexColorsError.diagnose(at: node ) )
      throw error
    }
  }
}

// --------------

/*
 #ColorValues(r: 128, g: 0, b: 200)

 #ColorValues(hex: "#A1F2B3") | Errors for other formats
 #ColorValues(hex: 0xA1F2B3) | Errors for other formats, must be 3 or 4 components

 #ColorValues(0.2, 1, 0.86) Float
 #ColorValues(0.2, 1, 0.86) Float with Alpha

 Add comment annotations to each macro expansions to see all values in 3 formats. Examople:
 let buttonColor = #ColorValues(r: 255, g: 255, b: 255)
 // expands to:
 ```
 /// rgb: 255 255 255
 /// hex: #FFFFFF
 /// floats: 1.0 1.0 1.0
 let buttonColor = #ColorValues(r: 255, g: 255, b: 255)
 ```
 */
