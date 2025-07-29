//
//  ColorValuesCodable.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 29/07/2025.
//

/// ! Separate Decoding & Coding annotations, while making possible to use the same format for both.
///
/// You can create convenience  formats specific for your project:
/// ```
/// extension CodableColorFormat {
///   static func rgbObjectDefault() -> Self ( rgbObject(r: "red", g: "green", b: "blue") )
/// }
/// ```

struct CodableColorFormat {
  enum InternalFormat {
    case hexStringRGB
    case hexStringRGBA
    case arrayRGB
    case arrayRGBA
    /// Field names must be spicified for (r, g, b) components.
    case rgbStructure(r: String, g: String, b: String)
    /// Field names must be spicified for (r, g, b, a) components.
    case rgbaStructure(r: String, g: String, b: String, a: String)
    // ...
  }
}
