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
}
