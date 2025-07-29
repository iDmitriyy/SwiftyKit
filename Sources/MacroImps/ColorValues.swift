//
//  ColorValues.swift
//  swifty-kit
//
//  Created by tmp on 29/07/2025.
//

import Foundation
//import SwiftCompilerPlugin
public import SwiftSyntax
import SwiftSyntaxBuilder
public import SwiftSyntaxMacros
import SwiftDiagnostics
@_spi(SwiftyKitBuiltinTypes) private import struct IndependentDeclarations.TextError
private import IndependentDeclarations

/// Implementation of the `color`, `uiColor`, `nsColor`, `cgColor` macros, which takes a string or hexadecimal integer literal
/// and produces a color instance. For example
///
///     #color("#FFF") -> SwiftUI.Color( red: 1.0, green: 1.0, blue: 1.0, opacity: 1.0 )
///     #color(0xfff) -> SwiftUI.Color( red: 1.0, green: 1.0, blue: 1.0, opacity: 1.0 )
//public struct HexIntExpressionMacro: ExpressionMacro {
//    public static func expansion(of node: some SwiftSyntax.FreestandingMacroExpansionSyntax, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> SwiftSyntax.ExprSyntax {
//        guard let argument = node.arguments.first?.expression,
//            let integerLiteral: TokenSyntax = argument.as(IntegerLiteralExprSyntax.self)?.literal
//        else {
//            fatalError("compiler bug: macro needs an integer literal")
//        }
//      // TODO: - ?
////        dump(argument)
//        var string = integerLiteral.text
//        
//      
//        guard string.hasPrefix("0x") else {
//          let error = TextError.message("integerLiteralMustBeHexadecimal")
//          
//          // TODO: - .
////            context.diagnose( error.diagnose(at: node ) )
//            throw error
//        }
//        
//        string = string.replacingOccurrences(of: "0x", with: "#")
//        
//        switch rgba(for: string) {
//        case let .success((r, g, b, a)):
//            return "SwiftUI.Color(red: \(raw: r), green: \(raw: g), blue: \(raw: b), opacity: \(raw: a) )"
//        case .failure( let error ):
//            context.diagnose( error.diagnose(at: node ) )
//            throw error
//        }
//    }
//}

public struct ColorValuesFromHexMacro: HexExpressionMacro {
    public static func colorExpressionSyntax(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8) -> SwiftSyntax.ExprSyntax {
      var expr: SwiftSyntax.ExprSyntax = "ColorValues(r: \(raw: red), g: \(raw: green), b: \(raw: blue), a: \(raw: alpha))"
//      expr.trailingTrivia = .lineComment("\\\\ \(red), g: \(green), b: \(blue), a: \(alpha)")
      
      
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
        if let stringLiteralExpressionSyntax = argument.as( StringLiteralExprSyntax.self ){
            let segments = stringLiteralExpressionSyntax.segments
            guard segments.count == 1, case .stringSegment(let literalSegment)? = segments.first else {
                fatalError("compiler bug: macro needs a static string")
            }
            
            string = literalSegment.content.text
        } else if let intergerLiteralExpressionSyntex = argument.as( IntegerLiteralExprSyntax.self ){
            string = intergerLiteralExpressionSyntex.literal.text
            
            guard string.hasPrefix("0x") else {
              let error = TextError.message("integerLiteralMustBeHexadecimal")
              // TODO: - .
              // TextError: DiagnosticMessage
//              Diagnostic(node: Syntax(node), message: error)
                throw error
            }
            
            string = string.replacingOccurrences(of: "0x", with: "#")
        } else {
            fatalError("compiler bug: unknown argument type")
        }
    
      do {
        let (r, g, b, a) = try rgbaUInt8(hexString: string)
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

