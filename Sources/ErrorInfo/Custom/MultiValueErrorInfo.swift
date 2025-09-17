//
//  MultiValueErrorInfo.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 07/08/2025.
//

import OrderedCollections
import IndependentDeclarations
import NonEmpty

/// If a key collision happens, the values are put into a container
struct MultiValueErrorInfo: IterableErrorInfo {
  typealias Key = String
  typealias Value = any ErrorInfoValueType
  typealias Element = (key: String, value: any ErrorInfoValueType)
  
  private var storage: MultiValueErrorInfoGeneric<String, any ErrorInfoValueType>
  
  init() {
    self.storage = MultiValueErrorInfoGeneric<String, any ErrorInfoValueType>()
  }
  
  func makeIterator() -> some IteratorProtocol<Element> {
    storage.makeIterator()
  }
  
  mutating func _addResolvingCollisions(value: any ErrorInfoValueType, forKey key: String) {
    storage._addResolvingCollisions(value: value, forKey: key)
  }
}

// MARK: - MultiValueErrorInfo Generic

struct MultiValueErrorInfoGeneric<Key: Hashable, Value>: IterableErrorInfo {
  typealias Element = (key: Key, value: Value)
  
  func makeIterator() -> some IteratorProtocol<Element> {
    MultiValueIterator(storage: storage)
  }
  
  private typealias ValueWrapper = Either<Value, NonEmptyArray<Value>>
  
  private var storage: OrderedDictionary<Key, ValueWrapper>
  
  init() {
    self.storage = [:]
  }
  
  // TODO: - add omitEqualValues arg
  mutating func _addResolvingCollisions(value: Value, forKey key: Key) {
    if let existing = storage[key] {
      switch existing {
      case .left(let currentValue):
        if ErrorInfoFuncs.isApproximatelyEqualAny(currentValue, value) {
          ()
        } else {
          let array = NonEmptyArray(currentValue, value)
          storage[key] = .right(array)
        }
      case .right(let array):
        if !array.contains(where: { ErrorInfoFuncs.isApproximatelyEqualAny($0, value) }) {
          var array = array
          array.append(value)
          storage[key] = .right(array)
        }
      }
    } else {
      storage[key] = .left(value)
    }
  }
}

extension MultiValueErrorInfoGeneric: Sendable where Key: Sendable, Value: Sendable {}

extension MultiValueErrorInfoGeneric {
  // MARK: Iterator
  
  private struct MultiValueIterator: IteratorProtocol {
    typealias Element = (key: Key, value: Value)
    
    private var storageIterator: OrderedDictionary<Key, ValueWrapper>.Iterator
    private var subIteration: SubIteration?
    
    private struct SubIteration {
      let key: Key
      let values: Array<Value>
      let lastUsedIndex: Array<Value>.Index
    }
    
    init(storage: OrderedDictionary<Key, ValueWrapper>) {
      storageIterator = storage.makeIterator()
    }
    
    mutating func next() -> Element? {
      if let sub = subIteration {
        let currentIndex = sub.lastUsedIndex + 1
        if sub.values.indices.contains(currentIndex) {
          let result = (sub.key, sub.values[currentIndex])
          self.subIteration = SubIteration(key: sub.key,
                                           values: sub.values,
                                           lastUsedIndex: currentIndex)
          return result
        } else {
          subIteration = nil
          return _storageIteratorNext()
        }
      } else {
        return _storageIteratorNext()
      }
    }
    
    private mutating func _storageIteratorNext() -> Element? {
      if let (key, wrapper) = storageIterator.next() {
        switch wrapper {
        case .left(let singleVlue):
          return (key, singleVlue)
        case .right(let multipleValues):
          let index: Int = 0
          let result = (key, multipleValues.rawValue[index])
          self.subIteration = SubIteration(key: key,
                                           values: multipleValues.rawValue,
                                           lastUsedIndex: index)
          return result
        }
      } else {
        return nil
      }
    }
  }
}
