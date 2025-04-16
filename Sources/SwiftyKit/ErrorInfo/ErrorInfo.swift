//
//  ErrorInfo.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 14.12.2024.
//

import struct OrderedCollections.OrderedDictionary

// MARK: - Error Info

public typealias ErrorInfoValueType = CustomStringConvertible & Equatable & Sendable

public protocol ErrorInfoProtocol: Sendable, CustomStringConvertible, CustomDebugStringConvertible {
  typealias ValueType = CustomStringConvertible & Equatable & Sendable
  
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
  public var isEmpty: Bool { storage.isEmpty }
  
  public var count: Int { storage.count }
  
  // TODO: - add tests for elements ordering stability
  public var description: String { String(describing: storage) }
  
  public var debugDescription: String { String(reflecting: storage) }
  
  public var asStringDict: [String: String] {
//    storage.mapValues { String(describing: $0) }
    fatalError()
  }
  
  fileprivate private(set) var storage: OrderedDictionary<String, any ValueType>
  
  fileprivate init(storage: OrderedDictionary<String, any ValueType>) {
    self.storage = storage
  }
  
  public init() {
    self.init(storage: OrderedDictionary<String, any ValueType>())
  }
  
//  public init(legacyUserInfo: [String: Any]) {
//    self.init()
//    legacyUserInfo.forEach { key, value in
//      storage[key] = prettyDescription(any: value)
//    }
//  }
  
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

  @_disfavoredOverload
  public subscript(key: ErronInfoKey, _: UInt = #line) -> (any ValueType)? {
    get { storage[key.string] }
    set { self[key.string] = newValue }
  }
  
  public subscript(key: ErronInfoKey) -> String? { self[key.string] }
  
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
  
  public func addingKeyPrefix(_ keyPrefix: String,
                              uppercasingFirstLetter uppercasing: Bool = true,
                              line: UInt = #line) -> Self {
    let storageCopy = storage
    let prefixed = ErrorInfoFunctions.addKeyPrefix(keyPrefix, toKeysOf: storageCopy, uppercasingFirstLetter: uppercasing, line: line)
    return Self(storage: prefixed)
  }
  
  // MARK: Static Funcs
  
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
  
  public static let empty: Self = Self()
}

extension ErrorInfo: ExpressibleByDictionaryLiteral {
  public typealias Value = any ValueType
  public typealias Key = String
  
  public init(dictionaryLiteral elements: (String, Value)...) {
    guard !elements.isEmpty else {
      self = .empty
      return
    }
    
    self.init()
    elements.forEach { key, value in self[key] = value }
  }
}

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
