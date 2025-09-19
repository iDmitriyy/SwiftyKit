//
//  UInt64KeyErrorInfo.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 07/08/2025.
//

/// collisions are ressolved by adding an 1000
struct UInt16KeyErrorInfo {
  
}

extension UInt16KeyErrorInfo {
  struct CustomKey {
    let rawValue: UInt16 // 65536
    
    fileprivate init(rawValue: UInt16) {
      self.rawValue = rawValue
    }
  }
}

// keys:
// range 1...9(<100)
// range 100..<200(<1000)
extension UInt16KeyErrorInfo.CustomKey {
  static let a = Self(rawValue: 0)
  static let aa = Self(rawValue: 1)
  static let zz = Self(rawValue: 9)
  static let aaa = Self(rawValue: 10)
  static let bbb = Self(rawValue: 11)
  static let ccc = Self(rawValue: 22)
  static let zzz = Self(rawValue: 99)
}

