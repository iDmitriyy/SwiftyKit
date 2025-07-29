//
//  ColorValuesCodable.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 29/07/2025.
//

/// ! Separate Decoding & Coding annotations, while making possible to use the same format for both.
///
/// You can create your own convenience  formats specific for your project:
/// ```
/// extension CodableColorFormat {
///   static func rgbObjectDefault() -> Self ( rgbStructure(r: "red", g: "green", b: "blue") )
/// }
/// ```

struct CodableColorFormat {
  enum InternalFormat {
    case hexStringRGB
    case hexStringRGBA
    case hexStringARGB
    case arrayRGB
    case arrayRGBA
    case arrayARGB
    /// Field names must be spicified for (r, g, b) components.
    case rgbStructure(r: String, g: String, b: String)
    /// Field names must be spicified for (r, g, b, a) components.
    case rgbaStructure(r: String, g: String, b: String, a: String)
    // ...
  }
}
