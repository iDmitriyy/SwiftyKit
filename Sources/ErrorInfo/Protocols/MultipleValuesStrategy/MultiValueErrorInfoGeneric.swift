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
 Save relative order of apending values. Example:
 info = init(sequence: [(key1, A), (key2, B), (key1, C), (key2, D)]). No matter for which key each value was added, the order
 of values is: A, B, C, D. This order should be during iteration.
 If ordered dictionary with array of values is used then the following order will be during iteration:
 (key1, A), (key1, C), (key2, B), (key2, D)
 which differs from the order values were appended
 */

import Foundation
import NonEmpty
import OrderedCollections

fileprivate struct Ordered_MultiValueErrorInfoGeneric_<Key: Hashable, Value> {}

extension Ordered_MultiValueErrorInfoGeneric_ {
  struct MultiValueOrderedStorage {
    private var elements: [Value]
    private var elementsIndices: [Key: NonEmpty<IndexSet>]
    
    typealias OrderedIndexSet = NonEmpty<OrderedSet<Int>>
    
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

// MARK: - Ordered MultiValueDictionary

struct OrderedMultiValueDictionary<Key: Hashable, Value>: Sequence {
  typealias Element = (key: Key, value: Value)
  
  private var entries: [(key: Key, value: Value)] = []
  private var keyIndices: [Key: NonEmptyOrderedIndexSet] = [:]
  
  var keys: some Collection<Key> { keyIndices.keys }
  
  var count: Int { entries.count }
  
  subscript(key: Key) -> NonEmpty<some Collection<Value>>? {
    allValues(forKey: key)
  }
  
  func allValues(forKey key: Key) -> NonEmpty<some Collection<Value>>? {
    guard let indices = keyIndices[key] else { return Optional<NonEmptyArray<Value>>.none }
    // TODO: need smth more optimal instead of allocating new Array, e.g.:
    // 1) MultiValueContainer enum | case single(element: ), case multiple(elements: )
    // 2) for multiple elements NonEmptyArray<Value>
    return indices._asHeapNonEmptyOrderedSet.map { entries[$0].value }
  }
  
  func hasValue(forKey key: Key) -> Bool {
    keyIndices.hasValue(forKey: key)
  }
  
  func makeIterator() -> some IteratorProtocol<(key: Key, value: Value)> {
    var index = 0
    return AnyIterator {
      guard index < entries.endIndex else { return nil }
      let entry = entries[index]
      index += 1
      return entry
    }
  }
}

extension OrderedMultiValueDictionary {
  mutating func append(key: Key, value: Value) {
    let index = entries.endIndex
    if var indices = keyIndices[key] {
      indices.insert(index)
      keyIndices[key] = indices
    } else {
      keyIndices[key] = .single(index: index)
    }
    
    entries.append((key, value))
  }
  
  mutating func removeValues(forKey key: Key) {
    guard let indices = keyIndices[key] else { return }
    
    let indicesToRemove: RangeSet = RangeSet(indices._asHeapNonEmptyOrderedSet, within: entries)
    entries.removeSubranges(indicesToRemove)
  }
  
  mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
    entries.removeAll(keepingCapacity: keepCapacity)
    keyIndices.removeAll(keepingCapacity: keepCapacity)
  }
}

/// Introduced for implementing OrderedMultiValueDictionary. In most cases, Error-info types contain 1 value for a given key.
/// When there are multiple values for key, multiple indices are also stored. This `NonEmpty Ordered IndexSet` store single index as a value type, and heap allocated
/// OrderedSet is only created when there are 2 or more indices.
internal enum NonEmptyOrderedIndexSet {
  case single(index: Int)
  case multiple(indices: NonEmpty<OrderedSet<Int>>)
  
  var _asHeapNonEmptyOrderedSet: NonEmpty<OrderedSet<Int>> { // TODO: confrom Sequence protocol instead of this
    switch self {
    case let .single(index): NonEmpty(rawValue: OrderedSet<Int>(arrayLiteral: index))!
    case let .multiple(indices): indices
    }
  }
  // CollectionOfOne
  internal mutating func insert(_ newIndex: Int) {
    switch self {
    case .single(let currentIndex):
      self = .multiple(indices: NonEmpty<OrderedSet<Int>>(rawValue: [currentIndex, newIndex])!)
    case .multiple(let elements):
      var rawValue = elements.rawValue
      rawValue.append(newIndex)
      self = .multiple(indices: NonEmpty<OrderedSet<Int>>(rawValue: rawValue)!)
    }
  }
  
//  internal func contains(where predicate: (Int) throws -> Bool) rethrows -> Bool {
//    switch self {
//    case .single(let index): try predicate(index)
//    case .multiple(let indices): try indices.contains(where: predicate)
//    }
//  }
}

