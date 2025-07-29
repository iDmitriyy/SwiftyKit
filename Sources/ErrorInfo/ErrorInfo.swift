//
//  ErrorInfo.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 14.12.2024.
//

import struct OrderedCollections.OrderedDictionary
public import func IndependentDeclarations.prettyDescription // for default valueInterpolation with prettyDescription
import IndependentDeclarations
import CrossImportOverlays

public struct ErrorInfo: ErrorInfoCollection {
  public static let empty: Self = Self()
  
  // TODO: - add tests for elements ordering stability
  
  public func asStringDict() -> [String: String] {
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
              valueInterpolation: @Sendable (Any) -> String = { prettyDescription(any: $0) }) {
    self.init()
    legacyUserInfo.forEach { key, value in storage[key] = valueInterpolation(value) }
  }
}

// MARK: Collection IMP

extension ErrorInfo {
  public typealias Index = Int
  
  public typealias Element = (key: String, value: any ValueType)
  
  public var isEmpty: Bool { storage.isEmpty }
  
  public var count: Int { storage.count }
  
  public var startIndex: Index { storage.keys.startIndex }
  
  public var endIndex: Index { storage.keys.endIndex }
  
  public subscript(position: Index) -> Element {
    storage.elements[position]
  }
  
  public func index(after i: Index) -> Index { storage.keys.index(after: i) }
}

// MARK: CustomStringConvertible IMP

extension ErrorInfo {
  public var description: String { String(describing: storage) }
  
  public var debugDescription: String { String(reflecting: storage) }
}

// MARK: Get / Set

extension ErrorInfo {
  @_disfavoredOverload
  public subscript(key: String, line: UInt = #line) -> (any ValueType)? {
    @available(*, unavailable, message: "This is a set only subscript")
    get { storage[key] }
    set(maybeValue) {
      // TODO: when nil then T.Type is unknown but should be known
      let value = maybeValue ?? prettyDescription(any: maybeValue)
      _addValue(value, forKey: key, line: line)
    }
  }
  
  // TODO: - think about design of such using of ErronInfoKey.
  // Subscript duplicated, check if compiler hamdle when root subscript getter become available or not
  // - add ability to add NonSendable values via sending and wrapping them into a Sendable wrapper

  @_disfavoredOverload
  public subscript(key: ErronInfoKey, line: UInt = #line) -> (any ValueType)? {
    get { storage[key.rawValue] }
    set { self[key.rawValue, line] = newValue }
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
