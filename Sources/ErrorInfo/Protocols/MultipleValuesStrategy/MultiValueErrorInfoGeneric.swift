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
  public mutating func appendResolvingCollisions(key: Key, value: Value, omitEqualValue omitIfEqual: Bool) {
    if storage.hasValue(forKey: key) {
      storage[key]?.append(value, omitIfEqual: omitIfEqual)
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
    let isEqualToCurrent: () -> Bool // for defered / lazy computation
    let elementsWithAppendedNew: () -> NonEmptyArray<T> // for defered / lazy computation
    switch self {
    case .single(let currentElement):
      isEqualToCurrent = { ErrorInfoFuncs.isApproximatelyEqualAny(currentElement, newElement) }
      elementsWithAppendedNew = { NonEmptyArray(currentElement, newElement) }
      
    case .multiple(var elements):
      isEqualToCurrent =  {
        elements.contains(where: { currentElement in
          ErrorInfoFuncs.isApproximatelyEqualAny(currentElement, newElement)
        })
      }
            
      elementsWithAppendedNew = {
        elements.append(newElement)
        return elements
      }
    }
    
    // if both `isEqualToCurrent` and `omitIfEqual` are true then value must not be added. Otherwise add it.
    if omitIfEqual, isEqualToCurrent() {
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
