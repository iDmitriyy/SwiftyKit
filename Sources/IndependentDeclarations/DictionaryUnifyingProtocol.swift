//
//  DictionaryUnifyingProtocol.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 14.12.2024.
//

extension Dictionary: DictionaryUnifyingProtocol {
//  public func mapValues<T, E>(_ transform: (Value) throws(E) -> T) throws(E) -> Dictionary<Key, Value> where E : Error {
//    
//  }
}

// MARK: - Dictionary Unifying RootProtocol

/// Рутовый протокол для работы с разным словарями в generic контексте
public protocol DictionaryUnifyingRootProtocol<Key, Value>: Swift.Sequence where Element == (key: Key, value: Value) {
  associatedtype Key: Hashable
  associatedtype Value
  
  associatedtype Keys: Swift.Collection<Key>, Equatable
  associatedtype Values: Swift.Collection<Value> // у словарей здесь MutableCollection, надо изучить насколько это
  // безопасно для NonEmpty
  
  associatedtype Iterator
  associatedtype Index: Comparable
  
  var keys: Keys { get }
  var values: Values { get }
  
  var count: Int { get }
  
  func index(forKey key: Key) -> Index?
}

// MARK: - _Dictionary Unifying NonEmpty Protocol

/// Протокол для работы со словарями в generic контексте. Содержит только операции, безопасные для NonEmpty словарей, и само собой для любых других.
public protocol DictionaryUnifyingNonEmptyProtocol<Key, Value>: DictionaryUnifyingRootProtocol {
  subscript(key: Key) -> Value? { get }
  
  @discardableResult
  mutating func updateValue(_ value: Value, forKey key: Key) -> Value?
    
  /// with NonEmptyDictionary filter function returns Dictionary
  associatedtype FilterResultType: DictionaryUnifyingNonEmptyProtocol<Key, Value>
  func filter(_ isIncluded: (Self.Element) throws -> Bool) rethrows -> FilterResultType
  
  // todo
//  func remapValues<T, E>(_ transform: (Value) throws(E) -> T) throws(E) -> Self
//  func remapValues<T>(_ transform: (Value) throws -> T) rethrows -> SelfType<Key, T>
//  func compactMapValues<T>(_ transform: (Value) throws -> T?) rethrows -> SelfType<Key, T>
  
  mutating func merge(_ keysAndValues: some Sequence<(Key, Value)>,
                      uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows

  func merging(_ other: some Sequence<(Key, Value)>,
               uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows -> Self
}

/// Для совместимости мёржа словарей разных Типов друг с другом.
/// Возникает ошибка компилятора что кортеж (key: Key, value: Value) не соответствует  (Key, Value)
extension DictionaryUnifyingNonEmptyProtocol {
  public mutating func merge(_ keysAndValues: some Sequence<(key: Key, value: Value)>,
                             uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows {
    let mapped: LazyMapSequence = keysAndValues.lazy.map { ($0.0, $0.1) }
    try merge(mapped, uniquingKeysWith: combine)
  }

  public func merging(_ other: some Sequence<(key: Key, value: Value)>,
                      uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows -> Self {
    let mapped: LazyMapSequence = other.lazy.map { ($0.0, $0.1) }
    return try merging(mapped, uniquingKeysWith: combine)
  }
}

// MARK: - _Dictionary UnifyingProtocol

/// Протокол для работы со словарями в generic контексте. Содержит операции, неприменимые к NonEmpty
public protocol DictionaryUnifyingProtocol<Key, Value>: DictionaryUnifyingNonEmptyProtocol {
  init()
  init(minimumCapacity: Int)
  
  init(uniqueKeysWithValues keysAndValues: some Sequence<(Key, Value)>)
  
  init(_ keysAndValues: some Sequence<(Key, Value)>, uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows
  
  mutating func reserveCapacity(_ minimumCapacity: Int)
  
  subscript(key: Key) -> Value? { get set }
  subscript(key: Key, default defaultValue: @autoclosure () -> Value) -> Value { get set }
  
  mutating func removeValue(forKey key: Key) -> Value?
  mutating func removeAll(keepingCapacity keepCapacity: Bool)
  mutating func remove(at index: Self.Index) -> Self.Element
}

// ⚠️ @iDmitriyy
// TODO: - inspect NonEmpty._DictionaryProtocol

extension DictionaryUnifyingRootProtocol {
  @inlinable
  public func hasValue(forKey key: Key) -> Bool {
    index(forKey: key) != nil
  }
}
