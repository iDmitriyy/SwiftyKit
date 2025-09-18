//
//  ErrorInfoProtocols.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 28/07/2025.
//

import IndependentDeclarations

// MARK: - Error Info

/// This approach addresses several important concerns:
/// - Thread Safety: The Sendable requirement is essential to prevent data races and ensure safe concurrent access.
/// - String Representation: Requiring CustomStringConvertible forces developers to provide meaningful string representations for stored values, which is invaluable for debugging and logging. It also prevents unexpected results when converting values to strings.
/// - Collision Resolution: The Equatable requirement allows to detect and potentially resolve collisions if different values are associated with the same key. This adds a layer of robustness.
public typealias ErrorInfoValueType = CustomStringConvertible & Equatable & Sendable

public protocol NonSendableErrorInfoProtocol<ValueType> {
  associatedtype ValueType
}

public protocol ErrorInfoRequirement {
  associatedtype Key
  associatedtype ValueType

  // MARK: Add value
  
  func _getUnderlyingValue(forKey key: Key) -> ValueType?
  
  mutating func _addResolvingCollisions(value: ValueType, forKey key: Key)
  
//  func getUnderlyingStorage() -> some DictionaryUnifyingProtocol<String, ValueType>
  
  // MARK: Merge
  
  mutating func merge<each D>(_ donators: repeat each D, fileLine: StaticFileLine) where repeat each D: ErrorInfoRequirement
  
  // MARK: Prefix & Suffix
  
  // FIXME: keyPrefix is String and incompatible with generic Key.
  mutating func addKeyPrefix(_ keyPrefix: String, transform: PrefixTransformFunc)
}

extension ErrorInfoRequirement where ValueType == any Sendable {}

extension ErrorInfoRequirement { // MARK: Merge

  public consuming func merging<each D>(_ donators: repeat each D, fileLine: StaticFileLine) -> Self
    where repeat each D: ErrorInfoRequirement {
      merge(repeat each donators, fileLine: fileLine)
      return self
    }
}

extension ErrorInfoRequirement { // MARK: Prefix & Suffix

//  toKeysOf dict: inout Dict,
//  transform: PrefixTransformFunc
  
  public consuming func addingKeyPrefix(_ keyPrefix: String, transform: PrefixTransformFunc) -> Self {
    addKeyPrefix(keyPrefix, transform: transform)
    return self
  }
}

extension ErrorInfoRequirement {
  public init(legacyUserInfo _: [String: Any],
              valueInterpolation _: @Sendable (Any) -> String = { prettyDescriptionOfOptional(any: $0) }) {
//    self.init()
//    legacyUserInfo.forEach { key, value in storage[key] = valueInterpolation(value) }
    fatalError()
  }
  
  public func asStringDict() -> [String: String] {
    fatalError()
  }
  
  public func asStringDict(options _: ErrorInfoStringDictOptions) -> [String: String] {
    fatalError()
  }
}

public struct ErrorInfoStringDictOptions: OptionSet, Sendable {
  public var rawValue: UInt32
  
  public init(rawValue: UInt32) {
    self.rawValue = rawValue
  }
  
  /// "5.0 Double"
  /// "2.7 Float16"
  /// "3.14 Float32?"
  /// "nil Decimal?"
  static let typeForAllValues = Self(rawValue: 1 << 0)
  /// "nil String?"
  /// "nil UInt?"
  /// "5"
  static let typeForOptionalNilValues = Self(rawValue: 1 << 1)
}

func test(errorInfo: some ErrorInfoRequirement) {
  var errorInfo2 = errorInfo
  
  errorInfo.merging(errorInfo2, fileLine: .this())
  errorInfo.addingKeyPrefix("ME12", transform: .concatenation)
  errorInfo2.asStringDict()
  let infoWithLegacyData = type(of: errorInfo).init(legacyUserInfo: [:])
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
