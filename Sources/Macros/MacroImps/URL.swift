//
//  URL.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 29/07/2025.
//

@_spi(SwiftyKitBuiltinTypes) private import struct IndependentDeclarations.TextError

/// Creates a non-optional URL from a static string. The string is checked to
/// be valid during compile time.
public enum URLMacro: ExpressionMacro {
  public static func expansion(of node: some FreestandingMacroExpansionSyntax,
                               in context: some MacroExpansionContext) throws -> ExprSyntax {
    guard let argument = node.arguments.first?.expression,
      let segments = argument.as(StringLiteralExprSyntax.self)?.segments,
      segments.count == 1,
      case .stringSegment(let literalSegment)? = segments.first
    else {
      throw TextError.message("#URL macro requires a static string literal")
    }
    
    let extractedString = literalSegment.content.text
    guard let _ = URL(string: extractedString) else {
      throw TextError.message("Malformed url: \(argument)")
    }
    // TODO: "URL(string: \(extractedString))!"
    return "URL(string: \(argument))!"
  }
}
