//
//  ErrorInfo.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 14.12.2024.
//

import struct OrderedCollections.OrderedDictionary

// MARK: - Error Info

public protocol InformativeError: Error {
  associatedtype ErrorInfoType: ErrorInfoProtocol
  
  var info: ErrorInfoType { get }
}

/// This approach addresses several important concerns:
/// - Thread Safety: The Sendable requirement is essential to prevent data races and ensure safe concurrent access.
/// - String Representation: Requiring CustomStringConvertible forces developers to provide meaningful string representations for stored values, which is invaluable for debugging and logging. It also prevents unexpected behavior when converting values to strings.
/// - Collision Resolution: The Equatable requirement allows to detect and potentially resolve collisions if different values are associated with the same key. This adds a layer of robustness.
public typealias ErrorInfoValueType = CustomStringConvertible & Equatable & Sendable

public protocol ErrorInfoProtocol: Collection, Sendable, CustomStringConvertible, CustomDebugStringConvertible {
  typealias ValueType = Sendable
  
  var isEmpty: Bool { get }
  
  var count: Int { get }
  
//  func merge(with other: Self)
  
  /// e.g. Later it can be decided to keep reference types as is, but interoplate value-types at the moment of passing them to ErrorInfo subscript.
  @_disfavoredOverload subscript(_: String, _: UInt) -> (any ValueType)? { get set }
  
//  static func merged(_ infos: Self...) -> Self
//  func asLegacyDictionary() -> [String: Any]
}

// extension ErrorInfoProtocol {
//  public init(dictionaryLiteral elements: (String, (any ValueType)?)..., line: UInt = #line) {
//    elements.forEach { key, value in
//      self[key, line] = value
//    }
//  }
// }

public struct ErrorInfo: ErrorInfoProtocol {
  public static let empty: Self = Self()
  
  public subscript(position: Int) -> Slice<ErrorInfo> {
    _read {
      fatalError()
    }
  }
  
  public var isEmpty: Bool { storage.isEmpty }
  
  public var count: Int { storage.count }
  
  public func index(after i: Int) -> Int { storage.keys.index(after: i) }
  
  public var startIndex: Int { storage.keys.startIndex }
  
  public var endIndex: Int { storage.keys.endIndex }
  
  // TODO: - add tests for elements ordering stability
  public var description: String { String(describing: storage) }
  
  public var debugDescription: String { String(reflecting: storage) }
  
  public var asStringDict: [String: String] {
//    storage.mapValues { String(describing: $0) }
    fatalError()
  }
  
  internal private(set) var storage: OrderedDictionary<String, any ValueType>
  
  fileprivate init(storage: OrderedDictionary<String, any ValueType>) {
    self.storage = storage
  }
  
  public init() {
    self.init(storage: OrderedDictionary<String, any ValueType>())
  }
  
  public init(legacyUserInfo: [String: Any],
              valueInterpolation: (Any) -> String = { prettyDescription(any: $0) }) {
    self.init()
    legacyUserInfo.forEach { key, value in storage[key] = valueInterpolation(value) }
  }
}

// MARK: Get / Set

extension ErrorInfo {
  @_disfavoredOverload
  public subscript(key: String, line: UInt = #line) -> (any ValueType)? {
    @available(*, unavailable, message: "This is a set only subscript")
    get { storage[key] }
    set(maybeValue) {
      let value = maybeValue ?? prettyDescription(any: maybeValue)
      _addValue(value, forKey: key, line: line)
    }
  }
  
  // TODO: - think about design of such using of ErronInfoKey.
  // Subscript duplicated, check if cimpiler hamdle when root subscript getter become available or not
  // - add ability to add NonSendable values via sending and wrapping them into a Sendable wrapper

  @_disfavoredOverload
  public subscript(key: ErronInfoKey, _: UInt = #line) -> (any ValueType)? {
    get { storage[key.rawValue] }
    set { self[key.rawValue] = newValue }
  }
  
  public subscript(key: ErronInfoKey) -> String? { self[key.rawValue] }
  
  public subscript(key: String) -> String? { storage[key] as? String }
  
  public mutating func add(key: String, optionalValue: (any ValueType)?, line: UInt = #line) {
    guard let value = optionalValue else { return }
    _addValue(value, forKey: key, line: line)
  }
  
//  public mutating func add(key: String, anyValue: Any, line: UInt = #line) {
//    // use cases:
//    // взятие по ключу значения из [String: Any]. Если оно nil, то Тип мы и не узнаем. Если не nil, может быть полезно
//    // id instance из ObjC
//    // >> нужны доработки, т.к. реальный Тип значения получить удается не всегда
//    var typeDescr: String { " (T.Type=" + "\(type(of: anyValue))" + ") " }
//    _addValue(typeDescr + prettyDescription(any: anyValue), forKey: key, line: line)
//  }
  
  private mutating func _addValue(_ value: any ValueType, forKey key: String, line: UInt) {
    if !storage.hasValue(forKey: key) {
      storage[key] = value
    } else {
      let dict = [key: value]
      ErrorInfoFunctions._mergeErrorInfo(&storage, with: [dict], line: line)
    }
  }
}

// MARK: Prefix & Suffix

extension ErrorInfo {
  public func addingKeyPrefix(_ keyPrefix: String,
                              uppercasingFirstLetter uppercasing: Bool = true,
                              line: UInt = #line) -> Self {
    let storageCopy = storage
    let prefixed = ErrorInfoFunctions.addKeyPrefix(keyPrefix, toKeysOf: storageCopy, uppercasingFirstLetter: uppercasing, line: line)
    return Self(storage: prefixed)
  }
}

// MARK: Merge

extension ErrorInfo {
  // TODO: - merge method with consuming generics instead of variadic ...
  
  public static func merge(_ otherInfos: Self..., to errorInfo: inout Self, line: UInt = #line) {
    ErrorInfoFunctions._mergeErrorInfo(&errorInfo.storage, with: otherInfos.map { $0.storage }, line: line)
  }
  
  public static func merge(_ otherInfo: Self,
                           to errorInfo: inout Self,
                           addingKeyPrefix keyPrefix: String,
                           uppercasingFirstLetter uppercasing: Bool = true,
                           line: UInt = #line) {
    ErrorInfoFunctions.mergeErrorInfo(otherInfo.storage,
                                      to: &errorInfo.storage,
                                      addingKeyPrefix: keyPrefix,
                                      uppercasingFirstLetter: uppercasing,
                                      line: line)
  }
  
  public static func merged(_ errorInfo: Self, _ otherInfos: Self..., line: UInt = #line) -> Self {
    var errorInfoRaw = errorInfo.storage
    ErrorInfoFunctions._mergeErrorInfo(&errorInfoRaw, with: otherInfos.map { $0.storage }, line: line)
    return Self(storage: errorInfoRaw)
  }
}

// MARK: collect values from KeyPath

extension ErrorInfo {
  @inlinable
  public static func collect<T, each V: ErrorInfo.ValueType>(from instance: T,
                                                             keys key: repeat KeyPath<T, each V>) -> Self {
    func collectEach(_ keyPath: KeyPath<T, some ErrorInfo.ValueType>, root: T, to info: inout Self) {
      info[keyPath.asErrorInfoKeyString()] = root[keyPath: keyPath]
    }
    // ⚠️ @iDmitriyy
    // _TODO: - add tests
    var info = Self()
    
    repeat collectEach(each key, root: instance, to: &info)
    
    return info
  }
}

fileprivate struct _ErrorInfoGeneric<Key, Value, DictType: DictionaryUnifyingProtocol>: Sendable
  where DictType.Key == Key, DictType.Value == Value, DictType: Sendable {
  typealias ValueType = ErrorInfo.Value
  
  fileprivate private(set) var storage: DictType
  
  // TODO: - imp
  // - may be make current ErrorInfo ordedred & delete ErrorOrderedInfo.
//  public var _asStringDict: DictType { storage.mapValues { String(describing: $0) } }
  
  fileprivate init(storage: DictType) {
    self.storage = storage
  }
}
