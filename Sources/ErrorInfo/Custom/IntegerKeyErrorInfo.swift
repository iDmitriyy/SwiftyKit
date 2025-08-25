//
//  IntegerKeyErrorInfo.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 07/08/2025.
//

struct IntegerKeyErrorInfo {
  
  struct CustomKey {
    let rawValue: UInt
  }
  
  // collisions are ressolved by adding an 1000
}


// keys:
// range 1...9(<100)
// range 100..<200(<1000)
extension IntegerKeyErrorInfo.CustomKey {
  static let a = Self(rawValue: 0)
  static let aa = Self(rawValue: 10)
  static let zz = Self(rawValue: 99)
  static let aaa = Self(rawValue: 100)
  static let bbb = Self(rawValue: 101)
  static let ccc = Self(rawValue: 202)
  static let zzz = Self(rawValue: 999)
}

