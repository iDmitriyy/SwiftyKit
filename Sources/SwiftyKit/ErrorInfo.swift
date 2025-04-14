//
//  ErrorInfo.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 14.12.2024.
//

public import struct OrderedCollections.OrderedDictionary

// MARK: - Error Info

public typealias ErrorInfoValueType = CustomStringConvertible & Equatable & Sendable

public protocol ErrorInfoProtocol: Sendable, CustomStringConvertible, CustomDebugStringConvertible {
  typealias ValueType = CustomStringConvertible & Equatable & Sendable
  
  var isEmpty: Bool { get }
  
  var count: Int { get }
  
//  func merge(with other: Self)
  
  /// e.g. Later it can be decided to keep reference types as is, but interoplate value-types at the moment of passing them to ErrorInfo subscript.
//  subscript(_: String, _: UInt) -> (any ValueType)? { get set }
  
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
  public var _asStringDict: [String: String] { storage.mapValues { String(describing: $0) } }
  
  public var isEmpty: Bool { storage.isEmpty }
  
  public var isNotEmpty: Bool { !isEmpty }
  
  public var count: Int { storage.count }
  
  // TODO: - add tests for elements ordering stability
  public var description: String { String(describing: storage) }
  
  public var debugDescription: String { String(reflecting: storage) }
  
  fileprivate private(set) var storage: [String: any ValueType]
  
  fileprivate init(storage: [String: any ValueType]) {
    self.storage = storage
  }
  
  public init() {
    self.init(storage: [:])
  }
  
  public init(legacyUserInfo: [String: Any]) {
    self.init(storage: legacyUserInfo.mapValues { prettyDescription(any: $0) })
  }
  
  /// set-only subscript, always returns nil trying get value
  /// Future improvements: make real set-only subscript when it becomes available in future Swift versions
  /// https://forums.swift.org/t/set-only-subscripts/32858
  @_disfavoredOverload
  public subscript(key: String, line: UInt = #line) -> (any ValueType)? {
    @available(*, unavailable, message: "This is a set only subscript")
    get { nil }
    set(maybeValue) {
      let value = maybeValue ?? prettyDescription(any: maybeValue)
      _addValue(value, forKey: key, line: line)
    }
  }
  
  public subscript(key: String, line: UInt = #line) -> String? {
    get { storage[key] as? String }
  }
  
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
      _mergeErrorInfo(&storage, with: [dict], line: line)
    }
  }
  
  public func addingKeyPrefix(_ keyPrefix: String,
                              uppercasingFirstLetter uppercasing: Bool = true,
                              line: UInt = #line) -> Self {
    let storageCopy = storage
    let prefixed = addKeyPrefix(keyPrefix, toKeysOf: storageCopy, uppercasingFirstLetter: uppercasing, line: line)
    return Self(storage: prefixed)
  }
  
  // MARK: Static Funcs
  
  // TODO: - merge method with consuming generics instead of variadic ...
  
  public static func merge(_ otherInfos: Self..., to errorInfo: inout Self, line: UInt = #line) {
    _mergeErrorInfo(&errorInfo.storage, with: otherInfos.map { $0.storage }, line: line)
  }
  
  public static func merge(_ otherInfo: Self,
                           to errorInfo: inout Self,
                           addingKeyPrefix keyPrefix: String,
                           uppercasingFirstLetter uppercasing: Bool = true,
                           line: UInt = #line) {
    mergeErrorInfo(otherInfo.storage,
                   to: &errorInfo.storage,
                   addingKeyPrefix: keyPrefix,
                   uppercasingFirstLetter: uppercasing,
                   line: line)
  }
  
  public static func merged(_ errorInfo: Self, _ otherInfos: Self..., line: UInt = #line) -> Self {
    var errorInfoRaw = errorInfo.storage
    _mergeErrorInfo(&errorInfoRaw, with: otherInfos.map { $0.storage }, line: line)
    return Self(storage: errorInfoRaw)
  }
  
  public static func merged(_ errorInfo: ErrorOrderedInfo,
                            _ otherInfos: ErrorOrderedInfo...,
                            line: UInt = #line) -> ErrorOrderedInfo {
    var errorInfoRaw = errorInfo.storage
    _mergeErrorInfo(&errorInfoRaw, with: otherInfos.map { $0.storage }, line: line)
    return ErrorOrderedInfo(storage: errorInfoRaw)
  }
  
//  public static func mergeInfo(ofError error: any BaseError,
//                               to errorInfo: inout ErrorInfo,
//                               addingKeyPrefix keyPrefix: String,
//                               uppercasingFirstLetter uppercasing: Bool = true,
//                               line: UInt = #line) {
//    mergeErrorInfo(error.info.storage,
//                   to: &errorInfo.storage,
//                   addingKeyPrefix: keyPrefix,
//                   uppercasingFirstLetter: uppercasing,
//                   line: line)
//    mergeErrorInfo(error.primaryInfo.storage,
//                   to: &errorInfo.storage,
//                   addingKeyPrefix: keyPrefix,
//                   uppercasingFirstLetter: uppercasing,
//                   line: line)
//  }
//
//  public static func mergeInfo(ofError error: any Error,
//                               to errorInfo: inout ErrorInfo,
//                               addingKeyPrefix keyPrefix: String,
//                               uppercasingFirstLetter uppercasing: Bool = true,
//                               line: UInt = #line) {
//    if let baseError = error as? any BaseError {
//      mergeInfo(ofError: baseError,
//                to: &errorInfo,
//                addingKeyPrefix: keyPrefix,
//                uppercasingFirstLetter: uppercasing,
//                line: line)
//    } else {
//      let anyErrorUserInfo = ErrorInfo(legacyUserInfo: (error._userInfo as? [String: Any]) ?? [:])
//      mergeErrorInfo(anyErrorUserInfo.storage,
//                     to: &errorInfo.storage,
//                     addingKeyPrefix: keyPrefix,
//                     uppercasingFirstLetter: uppercasing,
//                     line: line)
//    }
//  }
  
  public static let empty: Self = Self()
}

extension ErrorInfo: ExpressibleByDictionaryLiteral {
  public typealias Value = (any ValueType)?
  public typealias Key = String
  
  public init(dictionaryLiteral elements: (String, Value)...) {
    guard !elements.isEmpty else {
      self = .empty
      return
    }
    
    self.init()
    elements.forEach { key, value in
      self[key] = value
    }
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

public struct ErrorOrderedInfo: Sendable {
  public typealias ValueType = ErrorInfo.ValueType
  
  internal private(set) var storage: OrderedDictionary<String, any ValueType>
  
  public var _asStringDict: OrderedDictionary<String, String> { storage.mapValues { String(describing: $0) } }
  
  fileprivate init(storage: OrderedDictionary<String, any ValueType>) {
    self.storage = storage
  }
  
  public init() { self.init(storage: [:]) }
  
  /// set-only subscript, always returns nil trying get value
  /// Future improvements: make real set-only subscript when it becomes available in future Swift versions
  /// https://forums.swift.org/t/set-only-subscripts/32858
  @_disfavoredOverload
  public subscript(key: String, line: UInt = #line) -> (any ValueType)? {
    @available(*, unavailable, message: "This is a set only subscript")
    get { nil }
    set(maybeValue) {
      let value = maybeValue ?? prettyDescription(any: maybeValue)
      _addValue(value, forKey: key, line: line)
    }
  }
  
  public subscript(key: String, line: UInt = #line) -> String? {
    get { storage[key] as? String }
  }
  
  public mutating func add(key: String, optionalValue: (any ValueType)?, line: UInt = #line) {
    guard let value = optionalValue else { return }
    _addValue(value, forKey: key, line: line)
  }
  
  private mutating func _addValue(_ value: any ValueType, forKey key: String, line: UInt) {
    if !storage.hasValue(forKey: key) {
      storage[key] = value
    } else {
      let dict = [key: value]
      _mergeErrorInfo(&storage, with: [dict], line: line)
    }
  }
  
  public static func merge(_ otherInfos: Self..., to errorInfo: inout Self, line: UInt = #line) {
    _mergeErrorInfo(&errorInfo.storage, with: otherInfos.map { $0.storage }, line: line)
  }
  
  public static let empty: Self = Self()
}

extension ErrorOrderedInfo: ExpressibleByDictionaryLiteral {
  public typealias Value = (any ValueType)?
  public typealias Key = String
  
  public init(dictionaryLiteral elements: (String, Value)...) {
    self.init()
    elements.forEach { key, value in
      self[key] = value
    }
  }
}

fileprivate struct _ErrorInfoGeneric<Key, Value, DictType: DictionaryUnifyingProtocol>: Sendable
where DictType.Key == Key, DictType.Value == Value, DictType: Sendable {
  typealias ValueType = ErrorInfo.ValueType
  
  fileprivate private(set) var storage: DictType
  
  // TODO: - imp
  // - may be make current ErrorInfo ordedred & delete ErrorOrderedInfo.
//  public var _asStringDict: DictType { storage.mapValues { String(describing: $0) } }
  
  fileprivate init(storage: DictType) {
    self.storage = storage
  }
}

// MARK: - Merge ErrorInfo

import protocol IndependentDeclarations.DictionaryUnifyingProtocol

// MARK: Dictionary

public func mergeErrorInfo<V>(_ otherInfo: some DictionaryUnifyingProtocol<String, V>,
                              to errorInfo: inout some DictionaryUnifyingProtocol<String, V>,
                              addingKeyPrefix keyPrefix: String,
                              uppercasingFirstLetter: Bool = true,
                              line: UInt = #line) {
  let prefixedOtherInfo = addKeyPrefix(keyPrefix, toKeysOf: otherInfo, uppercasingFirstLetter: uppercasingFirstLetter, line: line)
  mergeErrorInfo(prefixedOtherInfo, to: &errorInfo, line: line)
}

public func mergeErrorInfo<Dict, V>(_ otherInfos: Dict...,
                                    to errorInfo: inout some DictionaryUnifyingProtocol<String, V>,
                                    line: UInt = #line) where Dict: DictionaryUnifyingProtocol<String, V> {
  _mergeErrorInfo(&errorInfo, with: otherInfos, line: line)
}

public func mergedErrorInfos<V, Dict>(_ errorInfo: Dict, _ otherInfos: Dict..., line: UInt = #line)
  -> Dict where Dict: DictionaryUnifyingProtocol<String, V> {
  var errorInfo = errorInfo
  _mergeErrorInfo(&errorInfo, with: otherInfos, line: line)
  return errorInfo
}

/// The purpose of this function is to merge multiple dictionaries of error information into a single dictionary, handling any key collisions by appending a unique suffix to the key.
///
/// The function loops through each dictionary in the `otherInfos` array and for each dictionary, it loops through its key-value pairs.2
/// For each key-value pair, the function checks if the key already exists in the `errorInfo` dictionary.
/// If the key does not already contained in the `errorInfo` dictionary, the function simply adds this key-value pair to the `errorInfo` dictionary.
/// If it is contained, the function checks if the value is approximately equal to the existing value in the `errorInfo` dictionary.
/// If they are approximately equal, then the function leaves in the dictionary the value that is already there
/// If not, then the function modifies the key by appending a generated suffix consisting of the current line number and the `index` of the current dictionary in the `otherInfos` array.
/// The function then checks if the modified key already exists in the errorInfo dictionary.
/// If it does, it appends the index of the current dictionary to the suffix and checks again until it finds a key that does not exist in the `errorInfo` dictionary.
/// Once it finds a unique key, the function adds the key-value pair to the `errorInfo` dictionary.
private func _mergeErrorInfo<V>(_ errorInfo: inout some DictionaryUnifyingProtocol<String, V>,
                                with otherInfos: [some DictionaryUnifyingProtocol<String, V>],
                                line: UInt) {
  for (index, otherInfo) in otherInfos.enumerated() {
    for (key, value) in otherInfo {
      _addResolvingKeyCollisions(key: key,
                                 value: value,
                                 firstSuffix: { "^line_\(line)_idx\(index)" },
                                 otherSuffix: { "_r" + ErrorInfoImpFunctions.randomSuffix() },
                                 to: &errorInfo)
    } // end for (key, value)
  } // end for (index, otherInfo)
}

/// For key-value pair, the function checks if the key already exists in the `errorInfo` dictionary.
/// If the key does not already contained in the `errorInfo` dictionary, the function simply adds this key-value pair to the `errorInfo` dictionary.
/// If it is contained, the function checks if the value is approximately equal to the existing value in the `errorInfo` dictionary.
/// If they are approximately equal, then the function leaves in the dictionary the value that is already there
/// If not, then the function modifies the key by appending a generated suffix consisting of the current line number and the `index`.
/// The function then checks if the modified key already exists in the errorInfo dictionary.
/// If it does, it appends the index of the current dictionary to the suffix and checks again until it finds a key that does not exist in the `errorInfo` dictionary.
/// Once it finds a unique key, the function adds the key-value pair to the `errorInfo` dictionary.
internal func _addResolvingKeyCollisions<V>(key: String,
                                            value: V,
                                            firstSuffix: () -> String,
                                            otherSuffix: () -> String,
                                            to errorInfo: inout some DictionaryUnifyingProtocol<String, V>) {
  if let existingValue = errorInfo[key] {
    guard !ErrorInfoImpFunctions.isApproximatelyEqual(value, existingValue) else {
      return // если значения равны, оставляем в userInfo то которое уже в нём есть
    }
    
    // Возникновение коллизий маловероятно. Если оно всё же произошло, добавляем index
    // чтобы понять на каком участке цепочки возникла коллизия.
    // Например, если в 2х словарях возникла коллизия по ключу "decodingDate", получится такой порядок модификации ключа:
    // decodingDate ->
    let suffix = firstSuffix() // "decodingDate^line_81_idx1"
    var modifiedKey = key + suffix
    while let existingValue2 = errorInfo[modifiedKey] {
      if ErrorInfoImpFunctions.isApproximatelyEqual(value, existingValue2) {
        return
      } else {
        modifiedKey += otherSuffix() // "decodingDate^line_81_idx1_1"
      }
    }
    
    errorInfo[modifiedKey] = value
  } else { // если коллизии отсутствуют – кладём в словарь
    errorInfo[key] = value
  }
}

// MARK: Add Key Prefix

public func addKeyPrefix<V, Dict>(_ keyPrefix: String,
                                  toKeysOf dict: Dict,
                                  uppercasingFirstLetter: Bool = true,
                                  line _: UInt = #line) -> Dict where Dict: DictionaryUnifyingProtocol<String, V> {
  var prefixedKeysDict = Dict(minimumCapacity: dict.count)
  
  for (key, value) in dict {
    // Edge Case:
    // ["a": 1, "A": 2]
    // after adding `prefix` with uppercasingFirstLetter:
    // ["prefixA": 1, "prefixA^line_81_BF3": 2]
    let prefixedKey = keyPrefix + (uppercasingFirstLetter ? key.uppercasingFirstLetter() : key)
//    _addResolvingKeyCollisions(key: prefixedKey,
//                               value: value,
//                               firstSuffix: { "^line_\(line)_r" + BaseErrorImpFunctions.randomSuffix() },
//                               otherSuffix: BaseErrorImpFunctions.randomSuffix,
//                               to: &prefixedKeysDict)
    fatalError()
  }
  
  return prefixedKeysDict
}

public struct ErronInfoKey: Hashable, Sendable, CustomStringConvertible {
  public var description: String { string }
  
  fileprivate let string: String
  
  public init(_ string: String) {
    // TODO: - decide what to do if "", " " is passed.
    self.string = string
  }
  
  public init(_ string: NonEmptyString) {
    self.init(string.rawValue)
  }
}

extension ErronInfoKey {
  public static let id = ErronInfoKey("id")
  public static let status = ErronInfoKey("status")
}

// ⚠️ @iDmitriyy
// TODO: - think about design of such using of ErronInfoKey.
// Subscript duplicated, check if cimpiler hamdle when root subscript getter become available or not

extension ErrorInfo {
  public subscript(key: ErronInfoKey, _: UInt = #line) -> (any ValueType)? {
    get { storage[key.string] }
    set { storage[key.string] = newValue }
  }
}

public enum ErrorInfoImpFunctions: Namespacing {
  // TODO: - add constraint T: CustomStringConvertible & Equatable & Sendable
  public static func isApproximatelyEqual<T>(_ lhs: T, _ rhs: T) -> Bool {
    if let lhs = lhs as? (any Hashable), let rhs = rhs as? (any Hashable) {
      AnyHashable(lhs) == AnyHashable(rhs)
    } else {
      String(describing: lhs) == String(describing: rhs)
    }
  }
  
  fileprivate static func randomSuffix() -> String {
    String([String.englishAlphabetUppercasedString.randomElement(),
            String.englishAlphabetUppercasedString.randomElement()]) + "\(UInt.random(in: 1...9))"
  }
}
