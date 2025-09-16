//
//  ErrorInfoPrototype.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 07/08/2025.
//

public protocol ErrorInfoRootPrototype<Key, Value>: Sequence where Self.Element == (key: Key, value: Value) {
  associatedtype Key
  associatedtype Value
}

func fff(dd: some ErrorInfoPrototype<String, Int>) {
  
}

public protocol ErrorInfoPrototype<Key, Value>: ErrorInfoRootPrototype {
  subscript(key: Key) -> Value? {
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

protocol ErrorInfoHashableKey<Key, Value>: ErrorInfoPrototype where Key: Hashable {
  associatedtype Key
  associatedtype Value
  
  // merge
  // prefix
}

extension ErrorInfoHashableKey where Key == String {
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

protocol ErrorInfoMergeable<Key, Value>: ErrorInfoRootPrototype {
  associatedtype Key
  associatedtype Value
  
//  mutating func merge<each D>(_ donators: repeat each D, fileLine: StaticFileLine) where repeat each D: ErrorInfoRootPrototype
}

extension ErrorInfoMergeable {
//  mutating func merge<each D>(_ donators: repeat each D,
//                              fileLine: StaticFileLine) where repeat each D: ErrorInfoRootPrototype, repeat (each D).Key == Self.Key {
//    
//  }
  
  mutating func merge<D>(_ donator: D,
                         fileLine: StaticFileLine) where D: ErrorInfoRootPrototype, D.Key == Self.Key {
    
  }
  
  mutating func merge<DValue, E>(_ donator: some Sequence<(key: Key, value: DValue)>,
                                 mapValue: (DValue) throws(E) -> Value,
                                 fileLine: StaticFileLine) {
    
  }
}

extension ErrorInfoMergeable {
  mutating func merge(_ donator: some Sequence<(key: Key, value: Value)>,
                      fileLine: StaticFileLine) {
    
  }
}

extension ErrorInfoMergeable where Key == String {}

func errrrfff<K: Hashable, V>(errorInfo: some ErrorInfoRootPrototype<K, V>) {
  var count = 0
  for (key, value) in errorInfo {
    count += 1
  }
}

func ddwfsd<K: Hashable, V>(errorInfo: some Sequence<(key: K, value: V)>) {
//  seq.lazy
//  seq.enumerated()
  errorInfo.allSatisfy { e in true }
  errorInfo.map { $0 }
  errorInfo.first(where: { _ in true })
  errorInfo.count(where: { _ in true })
  errorInfo.underestimatedCount
  errorInfo.forEach { _ in }
  errorInfo.compactMap { $0 }
  errorInfo.contains(where: { _ in true})
  errorInfo.flatMap { $0 }
  errorInfo.reduce(into: Dictionary<K, V>()) { partialResult, e in
    partialResult[e.key] = e.value
  }
//  errorInfo.sorted { $0.key < $1.key }
  errorInfo.dropFirst()
  errorInfo.dropLast()
  errorInfo.filter { _ in true }
  //  errorInfo.max(by: T##((key: Hashable, value: V), (key: Hashable, value: V)) throws -> Bool)
  errorInfo.prefix(1)
  errorInfo.suffix(1)
  errorInfo.reversed()
  errorInfo.shuffled()
}

//protocol ErrorInfoIterable<Key, Value>: ErrorInfoRootPrototype {
//  typealias Element = (key: Key, value: Value)
//  associatedtype KeyValues: Sequence<Element>
//
//  var keyValues: KeyValues { get }
//}
