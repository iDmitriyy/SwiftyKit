//
//  ErrorInfo.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 14.12.2024.
//

import struct OrderedCollections.OrderedDictionary

import CrossImportOverlays

// public import func IndependentDeclarations.prettyDescriptionOfOptional // for default valueInterpolation with prettyDescription
import IndependentDeclarations
import OrderedCollections

public struct ErrorInfo: Sendable { // ErrorInfoCollection
  public typealias ValueType = ErrorInfoValueType
  public static let empty: Self = Self()
  
  // TODO: - add tests for elements ordering stability
  
  internal private(set) var storage: OrderedDictionary<String, any ValueType>
  
  fileprivate init(storage: OrderedDictionary<String, any ValueType>) {
    self.storage = storage
  }
  
  public init() {
    self.init(storage: OrderedDictionary<String, any ValueType>())
  }
}

// MARK: CustomStringConvertible IMP

extension ErrorInfo {
  public var description: String { String(describing: storage) }
  // FIXME: use @DebugDescription macro
  public var debugDescription: String { String(reflecting: storage) }
}

// MARK: Get / Set

extension ErrorInfo {
//  public mutating func add(key: String, anyValue: Any, line: UInt = #line) {
//    // use cases:
//    // взятие по ключу значения из [String: Any]. Если оно nil, то Тип мы и не узнаем. Если не nil, может быть полезно
//    // id instance из ObjC
//    // >> нужны доработки, т.к. реальный Тип значения получить удается не всегда
//    var typeDescr: String { " (T.Type=" + "\(type(of: anyValue))" + ") " }
//    _addValue(typeDescr + prettyDescription(any: anyValue), forKey: key, line: line)
//  }
  
  public subscript(_: Key) -> (Value)? {
    get { fatalError() }
    set(maybeValue) {}
  }
  
  func _getUnderlyingValue(forKey _: Key) -> (any ValueType)? {
    nil
  }
  
  mutating func _addResolvingCollisions(value: any ValueType, forKey key: Key) {
    // Here values are added by ErrorInfo subscript, so use subroutine of root merge-function to put value into storage, which
    // adds a random suffix if collision occurs
    // Pass unmodified key
    // shouldOmitEqualValue = true, in ccomparison to addKeyPrefix function.
    ErrorInfoDictFuncs.Merge
      ._putResolvingWithRandomSuffix(value,
                                     assumeModifiedKey: key,
                                     shouldOmitEqualValue: true, // TODO: explain why
                                     suffixFirstChar: ErrorInfoMerge.suffixBeginningForSubcriptScalar,
                                     to: &storage)
  }
}

// MARK: Prefix & Suffix

extension ErrorInfo {
  public mutating func addKeyPrefix(_ keyPrefix: String, transform: PrefixTransformFunc) {
    ErrorInfoDictFuncs.addKeyPrefix(keyPrefix,
                                    toKeysOf: &storage,
                                    transform: transform)
  }
  
  public consuming func addingKeyPrefix(_ keyPrefix: String, transform: PrefixTransformFunc) -> Self {
    addKeyPrefix(keyPrefix, transform: transform)
    return self
  }
}

// MARK: Merge

extension ErrorInfo {
  public mutating func merge<each D>(_: repeat each D) where repeat each D: ErrorInfoCollection {
    fatalError()
//    ErrorInfoDictFuncs.Merge._mergeErrorInfo
  }
  
  public consuming func merging<each D>(_ donators: repeat each D) -> Self where repeat each D: ErrorInfoCollection {
    merge(repeat each donators)
    return self
  }
}

// extension ErrorInfo {
//  // TODO: - merge method with consuming generics instead of variadic ...
//
//  public static func merge(_ otherInfos: Self..., to errorInfo: inout Self, line: UInt = #line) {
//    ErrorInfoFuncs._mergeErrorInfo(&errorInfo.storage, with: otherInfos.map { $0.storage }, line: line)
//  }
//
//  public static func merge(_ otherInfo: Self,
//                           to errorInfo: inout Self,
//                           addingKeyPrefix keyPrefix: String,
//                           uppercasingFirstLetter uppercasing: Bool = true,
//                           line: UInt = #line) {
//    ErrorInfoFuncs.mergeErrorInfo(otherInfo.storage,
//                                      to: &errorInfo.storage,
//                                      addingKeyPrefix: keyPrefix,
//                                      uppercasingFirstLetter: uppercasing,
//                                      line: line)
//  }
//
//  public static func merged(_ errorInfo: Self, _ otherInfos: Self..., line: UInt = #line) -> Self {
//    var errorInfoRaw = errorInfo.storage
//    ErrorInfoFuncs._mergeErrorInfo(&errorInfoRaw, with: otherInfos.map { $0.storage }, line: line)
//    return Self(storage: errorInfoRaw)
//  }
// }

extension ErrorInfo {
  public init(legacyUserInfo: [String: Any],
              valueInterpolation: @Sendable (Any) -> String = { prettyDescriptionOfOptional(any: $0) }) {
    self.init()
    legacyUserInfo.forEach { key, value in storage[key] = valueInterpolation(value) }
  }
  
  public func asStringDict() -> [String: String] { // TODO: shouls be a protocol default imp
    var dict = [String: String](minimumCapacity: storage.count)
    storage.forEach { key, value in // TODO: use builtin initializer of OrderedDict instead of foreach
      dict[key] = String(describing: value)
    }
    return dict
  }
}

// MARK: collect values from KeyPath

extension ErrorInfo {
  // public static func fromKeys<T, each V: ErrorInfo.ValueType>(of instance: T,
  @inlinable
  public static func collect<R, each V: ErrorInfo.ValueType>(from instance: R,
                                                             keys key: repeat KeyPath<R, each V>) -> Self {
    func collectEach(_ keyPath: KeyPath<R, some ErrorInfo.ValueType>, root: R, to info: inout Self) {
      let keyPathString = ErrorInfoFuncs.asErrorInfoKeyString(keyPath: keyPath)
      info[keyPathString] = root[keyPath: keyPath]
    }
    // ⚠️ @iDmitriyy
    // _TODO: - add tests
    var info = Self()
    
    repeat collectEach(each key, root: instance, to: &info)
    
    return info
  }
}

// MARK: Collection IMP

// extension ErrorInfo {
//  public typealias Index = Int
//
//  public typealias Element = (key: String, value: any ValueType)
//
//  public var isEmpty: Bool { storage.isEmpty }
//
//  public var count: Int { storage.count }
//
//  public var startIndex: Index { storage.keys.startIndex }
//
//  public var endIndex: Index { storage.keys.endIndex }
//
//  public subscript(position: Index) -> Element {
//    storage.elements[position]
//  }
//
//  public func index(after i: Index) -> Index { storage.keys.index(after: i) }
// }
