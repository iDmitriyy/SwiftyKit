//
//  ErrorInfoCollection.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 07/08/2025.
//

public protocol ErrorInfoCollection: Collection, CustomStringConvertible, CustomDebugStringConvertible {
  typealias ValueType = Sendable
//  associatedtype Key_: Hashable
  
//  typealias Element = (key: Key_, value: ValueType)
//  associatedtype ValueType: Sendable = ErrorInfoValueType
//  func merging(with other: some ErrorInfoCollection) -> Self
  
  /// e.g. Later it can be decided to keep reference types as is, but interoplate value-types at the moment of passing them to ErrorInfo subscript.
//  @_disfavoredOverload subscript(_: String, _: UInt) -> (any ValueType)? { get set }
  
//  static func merged(_ infos: Self...) -> Self
//  func asLegacyDictionary() -> [String: Any]
}
