//
//  UInt8KeyErrorInfo.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 07/08/2025.
//

/// collisions are ressolved by adding an 1000
struct UInt8KeyErrorInfo {
  
}

extension UInt8KeyErrorInfo {
  struct CustomKey {
    let rawValue: UInt8
    
    fileprivate init(rawValue: UInt8) {
      self.rawValue = rawValue
    }
  }
}

// keys:
// range 1...9(<100)
// range 100..<200(<1000)
extension UInt8KeyErrorInfo.CustomKey {
  static let a = Self(rawValue: 0)
  static let aa = Self(rawValue: 10)
  static let zz = Self(rawValue: 20)
  static let aaa = Self(rawValue: 30)
  static let bbb = Self(rawValue: 40)
  static let ccc = Self(rawValue: 50)
  static let zzz = Self(rawValue: 255)
}

