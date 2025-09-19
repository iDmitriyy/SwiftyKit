//
//  MultiValueErrorInfo.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 07/08/2025.
//

import ErrorInfo
import OrderedCollections

/// If a key collision happens, the values are put into a container
struct MultiValueErrorInfo: IterableErrorInfo {
  typealias Key = String
  typealias Value = any ErrorInfoValueType
  typealias Element = (key: String, value: any ErrorInfoValueType)
  
  private typealias DictType = OrderedDictionary<String, ErrorInfoMultiValueContainer<Value>>
  
  private var storage: MultiValueErrorInfoGeneric<DictType, Value>
  
  init() {
    storage = MultiValueErrorInfoGeneric<DictType, Value>()
  }
  
  func makeIterator() -> some IteratorProtocol<Element> {
    storage.makeIterator()
  }
  
  mutating func _addResolvingCollisions(value: any ErrorInfoValueType, forKey key: String, omitIfEqual: Bool) {
    storage.appendResolvingCollisions(key: key, value: value, omitEqualValue: omitIfEqual)
  }
}

