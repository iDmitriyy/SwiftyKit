//
//  ColorValues.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 29/07/2025.
//

public struct ColorValues: Sendable {
  private let rawValues: RawValues
  
  fileprivate init(rawValues: RawValues) {
    self.rawValues = rawValues
  }
  
  fileprivate enum RawValues: Sendable {
  case rgb(r: UInt8, g: UInt8, b: UInt8)
  case rgba(r: UInt8, g: UInt8, b: UInt8, a: UInt8)
  }
}

// MARK: Unchecked Package Initializers

extension ColorValues {}

// MARK: Public Initializers

// Infallible:

extension ColorValues {
  public init(r: UInt8, g: UInt8, b: UInt8) {
    self.init(rawValues: .rgb(r: r, g: g, b: b))
  }
  
  public init(r: UInt8, g: UInt8, b: UInt8, a: UInt8) {
    self.init(rawValues: .rgba(r: r, g: g, b: b, a: a))
  }
}

// Failable:

//extension ColorValues {
//  /// rgb | rgba
//  init(hexString: String) throws {
//    fatalError()
//  }
//  
//  /// rgb | rgba
//  init(hex: UInt32) throws {
//    fatalError()
//  }
//}

//extension ColorValues {
//  /// lossy alpha
//  func rgbComponentsUInt8() ->
//  
//  /// if alpha value contained:
//  /// - keep as is
//  /// - replace with new
//  ///
//  /// if no alpha:
//  /// - opaque
//  /// - set value
//  func rgbaComponentsUInt8(alpha: ) // 2 / 3 different functions?
//}
