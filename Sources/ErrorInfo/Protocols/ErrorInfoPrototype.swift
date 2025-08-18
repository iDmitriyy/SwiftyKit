//
//  ErrorInfoPrototype.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 07/08/2025.
//

protocol ErrorInfoPrototype<Key, Value> {
  associatedtype Key
  associatedtype Value
  
  subscript(key: Key) -> Value? {
//    @available(*, unavailable, message: "This is a set only subscript")
    get
    set
  }
  
  func _getUnderlyingValue(forKey key: Key) -> Value?
  
  /// Unconditionally add a value to underliyng storage / buffer.
  mutating func _addResolvingCollisions(value: Value, forKey key: Key)
}

extension ErrorInfoPrototype {
  // MARK: Optional value
  
  mutating func addIfNotNil(optionalValue: Value?, key: Key) {
    guard let value = optionalValue else { return }
    _addResolvingCollisions(value: value, forKey: key)
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
  
  // Subscript duplicated, check if compiler hamdle when root subscript getter become available or not
  // - add ability to add NonSendable values via sending and wrapping them into a Sendable wrapper
  
  subscript(key: ErronInfoKey) -> Value? {
    get { self[key.rawValue] }
    set { self[key.rawValue] = newValue }
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
        let value: any Sendable = maybeValue ?? prettyDescription(any: maybeValue)
        _addResolvingCollisions(value: value, forKey: key)
      }
    }
}

// MARK: Mergeable

protocol ErrorInfoMergeable<Key, Value> {
  associatedtype Key
  associatedtype Value
  
  mutating func merge<each D>(_ donators: repeat each D, fileLine: StaticFileLine) where repeat each D: ErrorInfoRequirement
}

extension ErrorInfoMergeable where Key == String {}
