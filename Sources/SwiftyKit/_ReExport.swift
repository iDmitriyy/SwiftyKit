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
}

func prod(product: Product) {
  _ = product
}
