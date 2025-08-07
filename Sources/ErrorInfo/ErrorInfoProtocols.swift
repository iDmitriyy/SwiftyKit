//
//  ErrorInfoProtocols.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 28/07/2025.
//

import IndependentDeclarations

// MARK: - Error Info

public protocol InformativeError: Error {
  associatedtype ErrorInfoType: ErrorInfoCollection
  
  var info: ErrorInfoType { get }
}

/// This approach addresses several important concerns:
/// - Thread Safety: The Sendable requirement is essential to prevent data races and ensure safe concurrent access.
/// - String Representation: Requiring CustomStringConvertible forces developers to provide meaningful string representations for stored values, which is invaluable for debugging and logging. It also prevents unexpected behavior when converting values to strings.
/// - Collision Resolution: The Equatable requirement allows to detect and potentially resolve collisions if different values are associated with the same key. This adds a layer of robustness.
public typealias ErrorInfoValueType = CustomStringConvertible & Equatable & Sendable

public protocol ErrorInfoCollection: Collection, Sendable, CustomStringConvertible, CustomDebugStringConvertible {
  typealias ValueType = Sendable
//  associatedtype ValueType: Sendable = ErrorInfoValueType
//  func merging(with other: some ErrorInfoCollection) -> Self
  
  /// e.g. Later it can be decided to keep reference types as is, but interoplate value-types at the moment of passing them to ErrorInfo subscript.
//  @_disfavoredOverload subscript(_: String, _: UInt) -> (any ValueType)? { get set }
  
//  static func merged(_ infos: Self...) -> Self
//  func asLegacyDictionary() -> [String: Any]
}

/// If a collision happens, then two symbols are used as a start of random key suffix:
/// for subscript: `$` , e.g. "keyName$Ta5"
/// for merge functions: `#` , e.g. "keyName_don0_file_line_FileName_81_#Wng"
public protocol ErrorInfoType: ErrorInfoCollection {
  
}

internal protocol ErrorInfoRequirement {
  // MARK: Add value
  
  mutating func addResolvingCollisions(value: any ErrorInfoValueType, forKey key: String)
  
  // MARK: Merge
  
  mutating func merge<each D>(_ donators: repeat each D, fileLine: StaticFileLine) where repeat each D: ErrorInfoCollection
  
  // MARK: Prefix & Suffix
  
  mutating func addKeyPrefix(_ keyPrefix: String, fileLine: StaticFileLine)
}

extension ErrorInfoRequirement { // MARK: Add value
  mutating func addIfNotNil(optionalValue: (any ErrorInfoValueType)?, key: String) {
    guard let value = optionalValue else { return }
    addResolvingCollisions(value: value, forKey: key)
  }
  
  
}

extension ErrorInfoRequirement { // MARK: Merge
  public consuming func merging<each D>(_ donators: repeat each D, fileLine: StaticFileLine) -> Self
    where repeat each D: ErrorInfoCollection {
    self.merge(repeat each donators, fileLine: fileLine)
    return self
  }
}

extension ErrorInfoRequirement { // MARK: Prefix & Suffix
  public consuming func addingKeyPrefix(_ keyPrefix: String, fileLine: StaticFileLine = .this()) -> Self {
    self.addKeyPrefix(keyPrefix, fileLine: fileLine)
    return self
  }
}

func test(errorInfo: ErrorInfoCollection) {
  [3].isEmpty
  
  errorInfo.isEmpty
}

// extension ErrorInfoProtocol {
//  public init(dictionaryLiteral elements: (String, (any ValueType)?)..., line: UInt = #line) {
//    elements.forEach { key, value in
//      self[key, line] = value
//    }
//  }
// }

/// Default functions implementations for ErrorInfo types
internal protocol ErrorInfoInternalDefaultFuncs {
  associatedtype Storage: DictionaryUnifyingProtocol
  
  var storage: Storage { get }
}

extension ErrorInfo: ErrorInfoInternalDefaultFuncs {}
