//
//  HexColor.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 29/07/2025.
//

public import struct IndependentDeclarations.ColorValues

@freestanding(expression)
public macro colorValues(hex: StringLiteralType) -> ColorValues =
  #externalMacro(module: "MacroImps", type: "ColorValuesFromRGBAHexMacro")

@freestanding(expression)
public macro colorValues(hex: IntegerLiteralType) -> ColorValues =
  #externalMacro(module: "MacroImps", type: "ColorValuesFromRGBAHexMacro")
