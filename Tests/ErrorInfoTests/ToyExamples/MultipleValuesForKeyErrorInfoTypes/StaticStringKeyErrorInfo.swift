//
//  StaticStringKeyErrorInfo.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 07/08/2025.
//

import ErrorInfo
import OrderedCollections

struct StaticStringKeyErrorInfo: Sequence {
  typealias Key = StaticString
  typealias Value = any ErrorInfoValueType
  typealias Element = (key: Key, value: Value)
  
  private typealias DictType = OrderedDictionary<StaticStringHashableAdapter, ErrorInfoMultiValueContainer<Value>>
  private typealias MultiValueStorage = MultiValueErrorInfoGeneric<DictType, Value>
  
  private var storage: MultiValueStorage
  
  func makeIterator() -> some IteratorProtocol<Element> {
    IteratorAdapter(storage.makeIterator())
  }
}

// MARK: IteratorAdapter

extension StaticStringKeyErrorInfo {
  private struct IteratorAdapter<Iterator: IteratorProtocol>: IteratorProtocol
    where Iterator.Element == (key: StaticStringHashableAdapter, value: Value) {
    private var wrappedIterator: Iterator
    
    init(_ wrappedIterator: Iterator) {
      self.wrappedIterator = wrappedIterator
    }
    
    mutating func next() -> (key: Key, value: Value)? {
      wrappedIterator.next().map { key, value in (key.wrappedValue, value) }
    }
  }
}

// MARK: StaticString Hashable Adapter

internal struct StaticStringHashableAdapter: Hashable {
  let wrappedValue: StaticString
  
  init(_ wrappedValue: StaticString) {
    self.wrappedValue = wrappedValue
  }
  
  func hash(into hasher: inout Hasher) {
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
          byte == rhsBuffer[index]
        }
      }
    }
  }
}
