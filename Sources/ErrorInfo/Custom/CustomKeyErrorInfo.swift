//
//  CustomKeyErrorInfo.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 07/08/2025.
//

import OrderedCollections

struct CustomKeyErrorInfo {
  private(set) var storage: OrderedDictionary<Key, any ErrorInfoValueType>
  
  struct Key: Hashable {
    let string: String
    let tag: Tag
    
    enum Tag {
      case yellow
      case orange
      case blue
    }
  }
  
  struct Key2 {
    let value: UInt8
    let tags: Tags
    
    struct Tags: OptionSet {
      var rawValue: UInt32
      
      init(rawValue: UInt32) {
        self.rawValue = rawValue
      }
      
      static let waitsForConnectivity = Tags(rawValue: 1 << 0)
      static let allowCellular = Tags(rawValue: 1 << 1)
      static let multipathTCPAllowed = Tags(rawValue: 1 << 2)
    }
  }
}
