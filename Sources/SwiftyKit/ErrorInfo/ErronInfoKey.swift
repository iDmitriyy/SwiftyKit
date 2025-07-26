//
//  ErronInfoKey.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 16.04.2025.
//

public struct ErronInfoKey: Hashable, Sendable, CustomStringConvertible, CustomDebugStringConvertible, RawRepresentable {
  public typealias RawValue = String
  
  /// A new instance initialized with `rawValue` will be equivalent to this instance.
  public let rawValue: String
  
  public var description: String { rawValue }
  
  public var debugDescription: String { rawValue }
  
  /// Creates a new instance with the specified raw value.
  ///
  /// - Parameter rawValue: The raw value to use for the new instance.
  ///
  /// Rationale: error info keys are used to be read by humans, so there 2 minimal requirements:
  /// 1. no new-line symbols
  /// 2. contains at least one symbol except whitespaces
  public init?(rawValue: String) {
    guard rawValue.containsCharacters(except: .whitespaces),
          !rawValue.containsCharacters(in: .newlines) else { return nil }
    self.init(uncheckedString: rawValue)
  }
  
  internal init(uncheckedString: String) {
    self.rawValue = uncheckedString
  }
}

extension ErronInfoKey {
  public func withPrefix(_ prefix: String) -> Self {
    Self(uncheckedString: prefix + rawValue)
  }
  
  public func withSuffix(_ suffix: String) -> Self {
    Self(uncheckedString: rawValue + suffix)
  }
}
