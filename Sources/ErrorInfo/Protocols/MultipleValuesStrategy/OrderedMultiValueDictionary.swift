//
//  OrderedMultiValueDictionary.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 20/09/2025.
//

public import struct NonEmpty.NonEmpty
private import typealias NonEmpty.NonEmptyArray
import OrderedCollections
import StdLibExtensions

// MARK: - Ordered MultiValueDictionary

public struct OrderedMultiValueDictionary<Key: Hashable, Value>: Sequence {
  public typealias Element = (key: Key, value: Value)
  
  private var _entries: [(key: Key, value: Value)]
  /// stores indices for all values for a key
  private var _keyEntryIndices: [Key: NonEmptyOrderedIndexSet] // TODO: ? use RangeSet instead of NonEmptyOrderedIndexSet?
  
  public var keys: some Collection<Key> { _keyEntryIndices.keys }
  
  public var count: Int { _entries.count }
  
  public init() {
    _entries = []
    _keyEntryIndices = [:]
  }
  
  public init(minimumCapacity: Int) {
    _entries = Array(minimumCapacity: minimumCapacity)
    _keyEntryIndices = Dictionary(minimumCapacity: minimumCapacity)
  }
  
  public func makeIterator() -> some IteratorProtocol<(key: Key, value: Value)> {
    _entries.makeIterator()
  }
}

extension OrderedMultiValueDictionary: Sendable where Key: Sendable, Value: Sendable {}

// MARK: Get methods

extension OrderedMultiValueDictionary {
  @available(*, deprecated, message: "allValuesView(forKey:)")
  public subscript(key: Key) -> NonEmpty<some Collection<Value>>? {
    allValues(forKey: key)
  }
  
//  func ddd() -> some ~Escapable {
//
//  }
  
  public func allValuesView(forKey key: Key) -> (some Sequence<Value>)? { // & ~Escapable
    if let indices = _keyEntryIndices[key] {
      let indexSet = RangeSet(indices._asHeapNonEmptyOrderedSet, within: _entries)
      return AllValuesForKeyView(entries: _entries, valueIndices: indexSet)
    } else {
      return nil as Optional<AllValuesForKeyView>
    }
  }
  
  @available(*, deprecated, message: "allValuesView(forKey:)")
  public func allValues(forKey key: Key) -> NonEmpty<some Collection<Value>>? {
    guard let indices = _keyEntryIndices[key] else { return Optional<NonEmptyArray<Value>>.none }
    // TODO: need smth more optimal instead of allocating new Array, e.g.:
    // 1) MultiValueContainer enum | case single(element: ), case multiple(elements: )
    // 2) for multiple elements NonEmptyArray<Value>
    return indices._asHeapNonEmptyOrderedSet.map { _entries[$0].value }
  }
  
  public func hasValue(forKey key: Key) -> Bool {
    _keyEntryIndices.hasValue(forKey: key)
  }
}

// MARK: Mutating methods

extension OrderedMultiValueDictionary {
  public mutating func append(key: Key, value: Value) {
    let index = _entries.endIndex
    if var indices = _keyEntryIndices[key] {
      indices.insert(index)
      _keyEntryIndices[key] = indices
    } else {
      _keyEntryIndices[key] = .single(index: index)
    }
    
    _entries.append((key, value))
  }
  
  public mutating func removeValues(forKey key: Key) {
    guard let indices = _keyEntryIndices[key] else { return }
    
    let indicesToRemove: RangeSet = RangeSet(indices._asHeapNonEmptyOrderedSet, within: _entries)
    _entries.removeSubranges(indicesToRemove)
  }
  
  public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
    _entries.removeAll(keepingCapacity: keepCapacity)
    _keyEntryIndices.removeAll(keepingCapacity: keepCapacity)
  }
}

// MARK: - AllValues ForKey View

extension OrderedMultiValueDictionary {
  /// Adapter for changing element type from (key: Key, value: Value) to Value
  private struct AllValuesForKeyView: Sequence { // TODO: : ~Escapable
    typealias Element = Value
    let entries: [(key: Key, value: Value)]
    let valueIndices: RangeSet<Int>
    
    func makeIterator() -> some IteratorProtocol<Value> {
      let slicedEntries = entries[valueIndices]
      var iterator = slicedEntries.makeIterator()
      return AnyIterator<Value> {
        iterator.next()?.value
      }
    }
  }
}

// MARK: - NonEmpty Ordered IndexSet

/// Introduced for implementing OrderedMultiValueDictionary. In most cases, Error-info types contain 1 value for a given key.
/// When there are multiple values for key, multiple indices are also stored. This `NonEmpty Ordered IndexSet` store single index as a value type, and heap allocated
/// OrderedSet is only created when there are 2 or more indices.
internal enum NonEmptyOrderedIndexSet {
  case single(index: Int)
  case multiple(indices: NonEmpty<OrderedSet<Int>>)
  
  @available(*, deprecated, message: "not optimal")
  internal var _asHeapNonEmptyOrderedSet: NonEmpty<OrderedSet<Int>> { // TODO: confrom Sequence protocol instead of this
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
