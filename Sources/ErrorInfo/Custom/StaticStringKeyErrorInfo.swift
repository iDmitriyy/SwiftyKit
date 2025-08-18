//
//  StaticStringKeyErrorInfo.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 07/08/2025.
//

import OrderedCollections

struct StaticStringKeyErrorInfo {
  internal private(set) var storage: OrderedDictionary<StaticString, any ErrorInfoValueType>
  
  func sss(str: StaticString) {
    
  }
}

extension StaticString: Hashable {
  public func hash(into hasher: inout Hasher) {
    withUTF8Buffer { utf8Buffer in
      for uint8 in utf8Buffer {
        hasher.combine(uint8)
      }
    }
  }
  
  public static func == (lhs: Self, rhs: Self) -> Bool {
    fatalError()
  }
}

// let uniqueFileNames: Set<StaticString> = []
