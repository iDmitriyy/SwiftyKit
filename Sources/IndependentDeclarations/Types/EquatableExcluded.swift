//
//  EquatableExcluded.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 14.12.2024.
//

public typealias EquatableExcluded = HashableExcluded

/// Exclude property from Equality comparison and hashValue.
@propertyWrapper
public struct HashableExcluded<T>: Equatable {
  public var wrappedValue: T
  
  public init(wrappedValue: T) {
    self.wrappedValue = wrappedValue
  }
  
  public init(_ wrappedValue: T) {
    self.init(wrappedValue: wrappedValue)
  }
  
  /// always true
  public static func == (lhs: Self, rhs: Self) -> Bool { true }
}

extension HashableExcluded: Hashable {
  /// Empty Implementation
  public func hash(into hasher: inout Hasher) {}
}

extension HashableExcluded: BitwiseCopyable where T: BitwiseCopyable {}

extension HashableExcluded: Sendable where T: Sendable {}


extension HashableExcluded: CustomStringConvertible where T: CustomStringConvertible {
  public var description: String { String(describing: wrappedValue) }
}

extension HashableExcluded: CustomDebugStringConvertible where T: CustomDebugStringConvertible {
  public var debugDescription: String { String(reflecting: wrappedValue) }
}
