//
//  ColorFunctions.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 29/07/2025.
//

private import Foundation  // FIXME: remove Foundation

//package func argbUInt8(argbHexString string: String) throws -> (a: UInt8, r: UInt8, g: UInt8, b: UInt8) {
//  let (a, r, g, b) = try rgbaUInt8(rgbaHexString: string)
//  return (a, r, g, b)
//}

package func rgbaUInt8(rgbaHexString string: String) throws -> (r: UInt8, g: UInt8, b: UInt8, a: UInt8) {
  let (uint64, hexDigits) = try _validatedUInt64(hexString: string)

  let r, g, b, a: UInt64
  switch hexDigits.count { // 4 possible lengths after removing the #
  case 3:  // RGB (12-bit)
    let r_ = (uint64 & 0xf00) >> 8
    r = (r_ * 16) + r_

    let g_ = (uint64 & 0x0f0) >> 4
    g = (g_ * 16) + g_

    let b_ = uint64 & 0x00f
    b = (b_ * 16) + b_

    a = 16
  case 4:  // RGBA (16-bit)
    let r_ = (uint64 & 0xf000) >> 12
    r = (r_ * 16) + r_

    let g_ = (uint64 & 0x0f00) >> 8
    g = (g_ * 16) + g_

    let b_ = (uint64 & 0x00f0) >> 4
    b = (b_ * 16) + b_

    let a_ = uint64 & 0x000f
    a = (a_ * 16) + a_
  case 6:  // RRGGBB (24-bit)
    r = (uint64 & 0x00ff_0000) >> 16
    g = (uint64 & 0x0000_ff00) >> 8
    b = uint64 & 0x0000_00ff
    a = 255
  case 8:  // RRGGBBAA (32-bit)
    r = (uint64 & 0xff00_0000) >> 24
    g = (uint64 & 0x00ff_0000) >> 16
    b = (uint64 & 0x0000_ff00) >> 8
    a = uint64 & 0x0000_00ff
  default:
    throw TextError.message("Hex color string has invalid length")
  }

  let output = (UInt8(r), UInt8(g), UInt8(b), UInt8(a))
  return output
}

internal func _validatedUInt64(hexString string: String) throws -> (UInt64, hexDigits: String) {
  guard string.hasPrefix("#") else {
    throw TextError.message("Color hex string must start with # symbol")
  }

  let startAfterHashtag = string.index(string.startIndex, offsetBy: 1)
  let stringWithoutHashtag = String(string[startAfterHashtag...])

  let hexCharacters: Set<Character> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f"]
  for char in stringWithoutHashtag.lowercased() {
    guard hexCharacters.contains(char) else {
      throw TextError.message("invalidCharacters")
    }
  }

  guard stringWithoutHashtag.count > 0 else {
    throw TextError.message("hexColorStringCanNotBeEmpty")
  }

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
  
  return (uint64, stringWithoutHashtag)
}
