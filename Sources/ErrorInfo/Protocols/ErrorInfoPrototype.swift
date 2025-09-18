//
//  ErrorInfoPrototype.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 07/08/2025.
//

public protocol IterableErrorInfo<Key, Value>: Sequence where Key: Hashable, Self.Iterator.Element == (key: Key, value: Value) {
  associatedtype Key
  associatedtype Value
}

public protocol ErrorInfoPartialCollection<Key, Value>: ~Copyable { // : IterableErrorInfo
  associatedtype Key // temp while developong as ~Copyable
  associatedtype Value // < delete
  typealias Element = (key: Key, value: Value) // < delete
  
//  associatedtype Index
//  associatedtype Indices: Collection where Self.Indices == Self.Indices.SubSequence
  
  var isEmpty: Bool { get }
  
  var count: Int { get }
}

public protocol ErrorInfoPrototype<Key, Value>: IterableErrorInfo {
  subscript(_: Key) -> Value? {
//    @available(*, unavailable, message: "This is a set only subscript")
    get
    set
  }
  
  func _getUnderlyingValue(forKey key: Key) -> Value?
  
  // is it needed?
//  func removeValue(forKey key: Key) -> Value?
  
  /// Unconditionally add a value to underliyng storage / buffer.
  mutating func _unconditionallyAddResolvingCollisions(value: Value, forKey key: Key)
}

extension ErrorInfoPrototype {
  // MARK: Optional value
  
  mutating func addIfNotNil(_ optionalValue: Value?, key: Key) {
    if let value = optionalValue {
      _unconditionallyAddResolvingCollisions(value: value, forKey: key)
    }
  }
}

// MARK: Hashable

extension ErrorInfoPrototype where Key == String {
  // TODO: - think about design of such using of ErronInfoKey.
  
  // Subscript duplicated, check if compiler handle when root subscript getter become available or not
  // - add ability to add NonSendable values via sending and wrapping them into a Sendable wrapper
  
  subscript(key: ErronInfoKey) -> Value? {
    get { self[key.rawValue] }
    set { self[key.rawValue] = newValue }
  }
  
  /// Default imp for StaticString
  subscript(key: StaticString) -> Value? {
    get { self[String(key)] }
    set { self[String(key)] = newValue }
  }
  
  // merge
  // prefix
}

// MARK: Sendable

import IndependentDeclarations

protocol ErrorInfoSendableValue<Key, Value>: ErrorInfoPrototype where Value == any Sendable {
  associatedtype Key
  associatedtype Value
}

extension ErrorInfoSendableValue { // MARK: Add value

  // MARK: Subscripts
    
  @_disfavoredOverload
  public subscript(key: Key) -> (Value)? {
    @available(*, unavailable, message: "This is a set only subscript")
    get { _getUnderlyingValue(forKey: key) }
    set(maybeValue) {
      // TODO: when nil then T.Type is unknown but should be known
      let value: any Sendable = maybeValue ?? prettyDescriptionOfOptional(any: maybeValue)
      _unconditionallyAddResolvingCollisions(value: value, forKey: key)
    }
  }
}

// MARK: Mergeable

protocol ErrorInfoMergeable<Key, Value>: IterableErrorInfo {
//  mutating func merge<each D>(_ donators: repeat each D, fileLine: StaticFileLine) where repeat each D: ErrorInfoRootPrototype
}

extension ErrorInfoMergeable {
  /// Mergable ErrorInfo can be inited from a sequence with duplicated keys and values
  init(_: some Sequence<Element>) {
    fatalError()
  }
}

extension ErrorInfoMergeable {
//  mutating func merge<each D>(_ donators: repeat each D,
//                              fileLine: StaticFileLine) where repeat each D: ErrorInfoRootPrototype, repeat (each D).Key == Self.Key {
//
//  }
  
  mutating func merge<D>(_: D,
                         fileLine _: StaticFileLine) where D: IterableErrorInfo, D.Key == Self.Key {}
  
  mutating func merge<DValue, E>(_: some Sequence<(key: Key, value: DValue)>,
                                 mapValue _: (DValue) throws(E) -> Value,
                                 fileLine _: StaticFileLine) {}
}

extension ErrorInfoMergeable {
  mutating func merge(_: some Sequence<(key: Key, value: Value)>,
                      fileLine _: StaticFileLine) {}
}

extension ErrorInfoMergeable where Key == String {}

// ----------------------------------------------

// protocol ErrorInfoIterable<Key, Value>: ErrorInfoRootPrototype {
//  typealias Element = (key: Key, value: Value)
//  associatedtype KeyValues: Sequence<Element>
//
//  var keyValues: KeyValues { get }
// }

// protocol ErrorInfoHashableKey<Key, Value>: ErrorInfoPrototype where Key: Hashable {
//
// }
