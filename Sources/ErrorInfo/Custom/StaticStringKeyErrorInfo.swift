//
//  StaticStringKeyErrorInfo.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 07/08/2025.
//

import OrderedCollections

struct StaticStringKeyErrorInfo {
  internal private(set) var storage: OrderedDictionary<StaticStringHashableAdapter, any ErrorInfoValueType>
  
  func sss(str: StaticString) {
    
  }
}

struct StaticStringHashableAdapter: Hashable {
  let wrappedValue: StaticString
  
  init(_ wrappedValue: StaticString) {
    self.wrappedValue = wrappedValue
  }
  
  public func hash(into hasher: inout Hasher) {
    wrappedValue.withUTF8Buffer { utf8Buffer in
      for uint8 in utf8Buffer {
        hasher.combine(uint8)
      }
    }
  }
  // TODO: this is not proper imp
  static func == (lhs: StaticStringHashableAdapter, rhs: StaticStringHashableAdapter) -> Bool {
    lhs.wrappedValue.withUTF8Buffer { lhsBuffer in
      rhs.wrappedValue.withUTF8Buffer { rhsBuffer in
        guard lhsBuffer.count == rhsBuffer.count else { return false }
        
        return lhsBuffer.enumerated().allSatisfy { index, byte in
          rhsBuffer[index] == byte
        }
      }
    }
  }
}

// let uniqueFileNames: Set<StaticString> = []
