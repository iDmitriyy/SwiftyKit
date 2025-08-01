//
//  _ReExport.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 13.04.2025.
//

@_exported public import Collections
@_exported public import ErrorInfo
@_exported public import FoundationExtensions
@_exported public import IndependentDeclarations
@_exported public import NonEmpty
@_exported public import StdLibExtensions

/// SPI:
/// @_spi(SwiftyKitBuiltinTypes)
/// @_spi(SwiftyKitBuiltinFuncs)

/// Modules:
/// - make script for compiling products as static & dynamic library

/// Binary size ideas:
/// - make Either, OoneOfx, Empty, HashableExcluded, FileLine, RefBox, TextError, AppVersion, MacrosSymbols and others @frozen
/// - disable reflection

//import Foundation
import Macros

let col1 = #colorValues(hex: "#0011AAFF")
let col2 = #colorValues(hex: 0x0011_AAFF)
//let url = #URL("https://github.com")

@UpdatableCopy
struct Product {
  let name: String
  let price: Double
  let oldPrice: Double?
  var discount: Double?
  var unit: String {
    willSet {}
    didSet {}
  }
}

//let dd = UpdatableCopyMacro.self

func prod(product: Product) {
  _ = product
  product.copyUpdating(name: .takeValueFromSource)
  product.copyUpdating(name: .new("Orange"))
  product.copyUpdating(oldPrice: nil)
//  product.copyUpdating()
}
