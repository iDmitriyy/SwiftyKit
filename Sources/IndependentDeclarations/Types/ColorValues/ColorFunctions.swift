//
//  ColorFunctions.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 29/07/2025.
//

private import Foundation // FIXME: remove Foundation

package func rgbaUInt8(hexString string: String) throws -> (UInt8, UInt8, UInt8, UInt8){
    guard string.hasPrefix("#") else {
      throw TextError.message("stringLiteralMustStartWithHashtag")
    }
    
    let startAfterHashtag = string.index(string.startIndex, offsetBy: 1)
    let stringWithoutHashtag = String(string[startAfterHashtag...])
    
    let hexCharacters: Set<Character> = [ "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f" ]
    for char in stringWithoutHashtag.lowercased() {
        guard hexCharacters.contains(char) else {
          throw TextError.message("invalidCharacters")
        }
    }
    
    guard stringWithoutHashtag.count > 0 else {
      throw TextError.message("hexColorStringCanNotBeEmpty")
    }
    
    let scanner = Scanner(string: stringWithoutHashtag)
    var uint64: UInt64 = 0
  
  try withUnsafeMutablePointer(to: &uint64) {
    if Scanner(string: stringWithoutHashtag).scanHexInt64($0) {
      // ⚠️ @iDmitriyy
      // TODO: - изучить работу scanHexInt64
      // записывает в Int64 но у нас UInt64
      // есть scanHexInt32 вместо Int64
      // можно смотреть на это как на ascii коды и делать быструю проверку 0-9 | A-F a-f , попробовать через RangesSet
      // IndexSet Set<UInt8>, чтобы не использовать Foundtion
      // use compiletime known values
      // compare speed of several imps
      ()
    } else {
      throw TextError.message("invalidHexString")
    }
  }
  
    let r, g, b, a: UInt64
    // 4 diffrent lengths after removing the #
    switch stringWithoutHashtag.count {
//    case 3: // RGB
//        let R = Double((hexNumber & 0xf00) >> 8 )
//        r = (( R * 16 ) + R ) /  255
//
//        let G = Double((hexNumber & 0x0f0) >> 4 )
//        g = (( G * 16 ) + G ) / 255
//
//        let B = Double(hexNumber & 0x00f)
//        b = (( B * 16 ) + B ) / 255
//
//        a = 1
//    case 4: // RGBA
//        let R = Double((hexNumber & 0xf000) >> 12 )
//        r = (( R * 16 ) + R ) /  255
//
//        let G = Double((hexNumber & 0x0f00) >> 8 )
//        g = (( G * 16 ) + G ) / 255
//
//        let B = Double((hexNumber & 0x00f0) >> 4 )
//        b = (( B * 16 ) + B ) / 255
//
//        let A = Double(hexNumber & 0x000f)
//        a = (( A * 16 ) + A ) / 255
//    case 6: // RRGGBB ( alpha -> 100% )
//        r = Double((hexNumber & 0xff0000) >> 16 ) / 255
//        g = Double((hexNumber & 0x00ff00) >> 8 ) / 255
//        b = Double(hexNumber & 0x0000ff) / 255
//        a = 1
//    case 8: // RRGGBBAA
//        r = Double((hexNumber & 0xff000000) >> 24) / 255
//        g = Double((hexNumber & 0x00ff0000) >> 16) / 255
//        b = Double((hexNumber & 0x0000ff00) >> 8) / 255
//        a = Double(hexNumber & 0x000000ff) / 255
    case 6: // RGB (24-bit)
      r = uint64 >> 16
      g = uint64 >> 8 & 0xFF
      b = uint64 & 0xFF
      a = 255
    case 8: // ARGB (32-bit)
      r = uint64 >> 16 & 0xFF
      g = uint64 >> 8 & 0xFF
      b = uint64 & 0xFF
      a = uint64 >> 24
    default:
      throw TextError.message("Hex color string has invalid length")
    }
  
  let output = (UInt8(r), UInt8(g), UInt8(b), UInt8(a))
  return output
}
