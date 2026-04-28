//
//  _ReExport.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 13.04.2025.
//

@_exported public import FoundationExtensions
@_exported public import IndependentDeclarations
@_exported public import StdLibExtensions

/// Needed to silence compilation warning "'SwiftyKit.o' has no symbols" when SwiftyKit is imported.
public var swiftykitdummysymbol: some Any { 0 }

/// SPI:
/// @_spi(SwiftyKitBuiltinTypes)
/// @_spi(SwiftyKitBuiltinFuncs)

/// Modules:
/// - make script for compiling products as static & dynamic library

/// Binary size ideas:
/// - make Either, OoneOfx, Empty, HashableExcluded, FileLine, RefBox, TextError, AppVersion, MacrosSymbols and others @frozen
/// - disable reflection
