//
//  CaseIterable.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 14.12.2024.
//

@_spi(SwiftyKitBuiltinTypes) import struct IndependentDeclarations.TextError

extension CaseIterable {
  public init<T>(value: T,
                 relatedTo keyPath: KeyPath<Self, T>,
                 predicate: (_ value: T, _ caseValue: T) -> Bool = { $0 == $1 }) throws where T: Equatable {
    let allCases = Self.allCases

    var rawInstance: Self?

    for next in allCases where predicate(value, next[keyPath: keyPath]) {
      rawInstance = next
      break
    }

    if let value = rawInstance {
      self = value
    } else {
      throw TextError.initError(withValue: value, keyPath: keyPath)
    }
  }

  public init<T>(value: T, relatedTo keyPath: KeyPath<Self, T>, fallBack: Self) where T: Equatable {
    do {
      try self.init(value: value, relatedTo: keyPath)
    } catch {
      self = fallBack
    }
  }

  public init(value stringValue: String, relatedTo keyPath: KeyPath<Self, String>, caseSensitive: Bool = true) throws {
    let allCases = Self.allCases
    
    var rawInstance: Self?
    for next in allCases {
      let nextValue = next[keyPath: keyPath]
      // TODO: - stringValue.isEqualCaseInsensitively(to: nextValue) instead of .lowercased()
      if caseSensitive ? stringValue == nextValue : stringValue.lowercased() == nextValue.lowercased() {
        rawInstance = next
        break
      }
    }
    
    if let instance = rawInstance {
      self = instance
    } else {
      throw TextError.initError(withValue: stringValue, keyPath: keyPath)
    }
  }
}

import IndependentDeclarations

extension TextError {
  fileprivate static func initError<R, P>(withValue value: P, keyPath: KeyPath<R, P>) -> Self {
    // ⚠️ @iDmitriyy
    // TODO: - keyPath нормально напечатается?
    Self(text: "CaseIterable \(R.self) init: Unknown value `\(value)` for keyPath: \(keyPath)")
  }
}
