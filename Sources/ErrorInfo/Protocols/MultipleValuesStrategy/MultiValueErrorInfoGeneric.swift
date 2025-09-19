//
//  MultiValueErrorInfoGeneric.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 19/09/2025.
//

import IndependentDeclarations
public import typealias NonEmpty.NonEmptyArray

// MARK: - MultiValueErrorInfo Generic

/// Generic backing storage for implementing error info types with `MultipleValuesForKey` strategy
public struct MultiValueErrorInfoGeneric<Dict, Value>
  where Dict: DictionaryUnifyingProtocol, Dict.Value == ErrorInfoMultiValueContainer<Value> {
  public typealias Key = Dict.Key
  public typealias Element = (key: Key, value: Value)
  
  private var storage: Dict
  
  public init() {
    storage = Dict()
  }
  
  public func makeIterator() -> some IteratorProtocol<Element> {
    MultiValueIterator(storage: storage)
  }
}

// MARK: - Mutation Methods

extension MultiValueErrorInfoGeneric {
  public mutating func appendResolvingCollisions(key: Key, value: Value, omitEqualValue: Bool) {
    if storage.hasValue(forKey: key) {
      storage[key]?.append(value, omitIfEqual: omitEqualValue)
    } else {
      storage[key] = .single(element: value)
    }
  }
  
  public mutating func _mergeWith(other _: Self) {}
}

extension MultiValueErrorInfoGeneric where Dict.Key: RangeReplaceableCollection {
  public mutating func addKeyPrefix(_ keyPrefix: Dict.Key) {
    storage = ErrorInfoDictFuncs.addKeyPrefix(keyPrefix, toKeysOf: storage)
  }
}

// MARK: - Protocol Conformances

extension MultiValueErrorInfoGeneric: Sendable where Dict: Sendable {}

// MARK: - MultiValue Container

// TODO: add identity(source specifier) for collision
// so NonEmptyArray<Value> turns to NonEmptyArray<(Value, CollisionSpecifier)>

/// For keeping one or more values for a key
public enum ErrorInfoMultiValueContainer<T> {
  case single(element: T)
  case multiple(elements: NonEmptyArray<T>)
  
  fileprivate mutating func append(_ newElement: T, omitIfEqual: Bool) {
    let isEqualToCurrent: Bool
    let elementsWithAppendedNew: () -> NonEmptyArray<T> // for defered / lazy initialization
    switch self {
    case .single(let currentElement):
      isEqualToCurrent = ErrorInfoFuncs.isApproximatelyEqualAny(currentElement, newElement)
      elementsWithAppendedNew = { NonEmptyArray(currentElement, newElement) }
      
    case .multiple(var elements):
      isEqualToCurrent = elements.contains(where: { currentElement in
        ErrorInfoFuncs.isApproximatelyEqualAny(currentElement, newElement)
      })
            
      elementsWithAppendedNew = {
        elements.append(newElement)
        return elements
      }
    }
    
    // if both `isEqualToCurrent` and `omitIfEqual` are true then value must not be added. Otherwise add it.
    if isEqualToCurrent, omitIfEqual {
      return
    } else {
      self = .multiple(elements: elementsWithAppendedNew())
    }
  }
}

// MARK: Iterator

extension MultiValueErrorInfoGeneric {
  private struct MultiValueIterator: IteratorProtocol {
    typealias Element = (key: Key, value: Value)
    
    private var storageIterator: Dict.Iterator
    private var subIteration: SubIteration?
    
    private struct SubIteration {
      let key: Key
      let values: Array<Value>
      let lastUsedIndex: Array<Value>.Index
    }
    
    init(storage: Dict) {
      storageIterator = storage.makeIterator()
    }
    
    mutating func next() -> Element? {
      if let sub = subIteration {
        let currentIndex = sub.lastUsedIndex + 1
        if sub.values.indices.contains(currentIndex) {
          let result = (sub.key, sub.values[currentIndex])
          subIteration = SubIteration(key: sub.key,
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
        case .single(let element):
          return (key, element)
        case .multiple(let elements):
          let index: Int = 0
          let result = (key, elements.rawValue[index])
          subIteration = SubIteration(key: key,
                                      values: elements.rawValue,
                                      lastUsedIndex: index)
          return result
        }
      } else {
        return nil
      }
    }
  }
}

/*
 TODO:
 Save relative order of apending values. Now they are grouped by key. Example:
 info = init(sequence: [(key1, A), (key2, B), (key1, C), (key2, D)])
 If ordered dictionary is used then the following order will be during iteration:
 (key1, A), (key1, C), (key2, B), (key2, D)
 which differs from the order values were appended
 */

import Foundation
import NonEmpty

fileprivate struct Ordered_MultiValueErrorInfoGeneric_<Key: Hashable, Value> {
  
  
}

extension Ordered_MultiValueErrorInfoGeneric_ {
  struct MultiValueOrderedStorage {
    private var elements: [Value]
    private var elementsIndices: [Key: NonEmpty<IndexSet>]
    
    func elements(forKey key: Key) -> NonEmptyArray<Value>? {
      if let indices = elementsIndices[key] {
        indices.map { elements[$0] }
      } else {
        nil
      }
    }
    
    // FIXME: change IndexSet to RangeSet
    
    mutating func append(key: Key, value: Value, omitIfEqual: Bool) {
      if var indices = elementsIndices[key] {
        let isEqualToCurrent = indices.contains(where: { index in
          ErrorInfoFuncs.isApproximatelyEqualAny(elements[index], value)
        })
        
        if isEqualToCurrent, omitIfEqual {
          return
        } else {
          let index = elements.endIndex
          indices.insert(index)
          elements.append(value)
          elementsIndices[key] = indices
        }
      } else {
        let index = elements.endIndex
        elements.append(value)
        elementsIndices[key] = NonEmpty<IndexSet>(index)
      }
    }
    
//    mutating func removeAllValues(forKey: Key) {
//      // to removing a single value all indices need to be recalculated
//      // will be implemented if ever needed
//    }
  }
}
