//
//  ErrorInfoProtocols.swift
//  swifty-kit
//
//  Created by tmp on 28/07/2025.
//

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

public protocol ErrorInfoType: ErrorInfoCollection {
  
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

internal protocol ErrorInfoInternal {
  associatedtype Storage
  
  var storage: Storage { get }
}

extension ErrorInfo: ErrorInfoInternal {}
