//
//  HexColor.swift
//  swifty-kit
//
//  Created by ColorValues on 29/07/2025.
//

//@freestanding(expression)
//public macro color(_ stringLiteral: StringLiteralType ) -> Color = #externalMacro(module: "HexColorsMacros", type: "ColorHexMacro")

public import struct IndependentDeclarations.ColorValues

@freestanding(expression)
public macro colorValues(hex: StringLiteralType ) -> ColorValues =
  #externalMacro(module: "MacroImps", type: "ColorValuesFromHexMacro")
//
//@freestanding(expression)
//public macro colorValues(hex: IntegerLiteralType ) -> ColorValues = #externalMacro(module: "MacroImps", type: "HexIntExpressionMacro")
