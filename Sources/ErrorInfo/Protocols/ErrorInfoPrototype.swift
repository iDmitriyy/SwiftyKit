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

func fff(dd: some ErrorInfoPrototype<String, Int>) {
  
}

public protocol ErrorInfoPartialCollection<Key, Value>: ~Copyable { // : IterableErrorInfo
  associatedtype Key // temp while developong as ~Copyable
  associatedtype Value // < delete
  typealias Element = (key: Key, value: Value) // < delete
  
  associatedtype Index
  associatedtype Indices: Collection where Self.Indices == Self.Indices.SubSequence
  
  var isEmpty: Bool { get }
  
  var count: Int { get }
  
  var startIndex: Index { get }
  
  var endIndex: Index { get }
  
  var indices: Self.Indices { get }
  
  func index(after i: Index) -> Index
  
  subscript(position: Index) -> Element { get }
}

public protocol ErrorInfoPrototype<Key, Value>: IterableErrorInfo {
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
  init(_ s: some Sequence<Element>) {
    fatalError()
  }
}

extension ErrorInfoMergeable {
//  mutating func merge<each D>(_ donators: repeat each D,
//                              fileLine: StaticFileLine) where repeat each D: ErrorInfoRootPrototype, repeat (each D).Key == Self.Key {
//    
//  }
  
  mutating func merge<D>(_ donator: D,
                         fileLine: StaticFileLine) where D: IterableErrorInfo, D.Key == Self.Key {
    
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

// MARK: - Merge Operations

//protocol ErrorInfoCollisionsResolvable<Key, Value>: IterableErrorInfo {
//  init(_ keyValues: some Sequence<Element>)
//}
//
//extension ErrorInfoMergeOp {}

public protocol ErrorInfoCollisionsResolvable_<Key, Value>: ~Copyable where Key: Hashable { // : IterableErrorInfo
  associatedtype Key
  associatedtype Value
  typealias Element = (key: Key, value: Value)
  
  associatedtype KeyValues: Sequence<Element>
  /// some keys can be repeated several times, in other words keys are not guaranteed be unique
  var keyValuesView: KeyValues { get }
  
  init()
  init(minimumCapacity: Int)
  
  // TODO: ??! is it possible to implement with no additional args?
  // subscript can be used, but it is not guaranteed to resolve collisions
//  mutating func mergeWith(_ keyValues: some Sequence<Element>)
  
  /// has default imp
//  init(_ keyValues: some Sequence<Element>) // TODO: sequence may have duplicated keys
}

// MARK: Default implementations

extension ErrorInfoCollisionsResolvable_ {
//  public init(_ keyValues: some Sequence<Element>) {
//    self.init()
//    self.mergeWith(keyValues)
//  }
//    
//  public consuming func mergedWith(_ keyValues: some Sequence<Element>) -> Self {
//    self.mergeWith(keyValues)
//    return self
//  }
}

//MARK: - Key Augmentation Collison Strategy

public protocol ErrorInfoUniqueKeysAugmentationStrategy<Key, Value>: ErrorInfoCollisionsResolvable_ {
  associatedtype OpaqueDictType: DictionaryUnifyingProtocol<Key, Value>
}

extension ErrorInfoUniqueKeysAugmentationStrategy {
//  static func merge(recipient: consuming some ErrorInfoMergeOp, donator: borrowing some IterableErrorInfo)
}

//MARK: - MultipleValues For Key Collison Strategy

public protocol ErrorInfoMultipleValuesForKeyStrategy<Key, Value>: ErrorInfoCollisionsResolvable_ {}

// ----------------------------------------------

//protocol ErrorInfoIterable<Key, Value>: ErrorInfoRootPrototype {
//  typealias Element = (key: Key, value: Value)
//  associatedtype KeyValues: Sequence<Element>
//
//  var keyValues: KeyValues { get }
//}

//protocol ErrorInfoHashableKey<Key, Value>: ErrorInfoPrototype where Key: Hashable {
//
//}
