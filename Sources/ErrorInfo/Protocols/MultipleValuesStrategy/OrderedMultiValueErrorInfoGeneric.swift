//
//  OrderedMultiValueErrorInfoGeneric.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 20/09/2025.
//

/*
 TODO:
 Save relative order of apending values. Example:
 info = init(sequence: [(key1, A), (key2, B), (key1, C), (key2, D)]). No matter for which key each value was added, the order
 of values is: A, B, C, D. This order should be during iteration.
 If ordered dictionary with array of values is used then the following order will be during iteration:
 (key1, A), (key1, C), (key2, B), (key2, D)
 which differs from the order values were appended
 */

// import Foundation

public struct OrderedMultiValueErrorInfoGeneric<Key: Hashable, Value>: Sequence {
  public typealias Element = (key: Key, value: Value)
  
  private var _storage: OrderedMultiValueDictionary<Key, Value>
  
  public init() {
    self._storage = OrderedMultiValueDictionary<Key, Value>()
  }
  
  public func makeIterator() -> some IteratorProtocol<Element> {
    _storage.makeIterator()
  }
}

// MARK: - Mutation Methods

extension OrderedMultiValueErrorInfoGeneric {
  public mutating func appendResolvingCollisions(key: Key, value newValue: Value, omitEqualValue omitIfEqual: Bool) {
    if let currentValues = _storage.allValuesView(forKey: key) {
      let isEqualToCurrent = currentValues.contains(where: { currentValue in
        ErrorInfoFuncs.isApproximatelyEqualAny(currentValue, newValue)
      })
      
      // if both `isEqualToCurrent` and `omitIfEqual` are true then value must not be added. Otherwise add it.
      if omitIfEqual, isEqualToCurrent {
        return
      } else {
        _storage.append(key: key, value: newValue)
      }
    } else {
      _storage.append(key: key, value: newValue)
    }
  }
  
  public mutating func mergeWith(other _: Self) {}
}

// extension OrderedMultiValueErrorInfoGeneric where Key: RangeReplaceableCollection {
//  public mutating func addKeyPrefix(_ keyPrefix: Key) {
//    _storage = ErrorInfoDictFuncs.addKeyPrefix(keyPrefix, toKeysOf: _storage)
//  }
// }

// MARK: - Protocol Conformances

extension OrderedMultiValueErrorInfoGeneric: Sendable where Key: Sendable, Value: Sendable {}
