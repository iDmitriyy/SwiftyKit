//
//  PrettyDescription.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 14.12.2024.
//

private import Foundation

// TODO: - remove foundation

// MARK: - Pretty Description for Any & Optional<T>

/// Cleans up the string representation of any value (including deeply nested optionals) by removing redundant "Optional(...)" wrappers.
///
/// Example:
/// ```
/// prettyDescriptionOfOptional(any: Optional(Optional(42)))        // "42"
/// prettyDescriptionOfOptional(any: Optional<Optional<Int>>.none)  // "nil"
/// prettyDescriptionOfOptional(any: "Hello")                       // "Hello"
/// ```
/// - Parameter any: A value of type `Any`, which may or may not be an optional.
/// - Returns: A String representing the unwrapped value or "nil"
public func prettyDescriptionOfOptional(any: Any) -> String {
  if let optional = any as? (any CustomStringConvertible)? {
    return prettyDescriptionOfOptional(any: optional)
  } else if Mirror(reflecting: any).displayStyle == .optional {
    var string = String(describing: any)
    while let range = string.range(of: "Optional(") {
      let descr = string.replacingCharacters(in: range, with: "")
      string = descr.last == ")" ? String(descr.dropLast()) : descr
    }
    return string
  } else {
    return String(describing: any)
  }
}

/// Cleans up the string representation of any value (including deeply nested optionals) by removing redundant "Optional(...)" wrappers.
///
/// Example:
/// ```
/// prettyDescriptionOfOptional(any: Optional(Optional(42)))        // "42"
/// prettyDescriptionOfOptional(any: Optional<Optional<Int>>.none)  // "nil"
/// prettyDescriptionOfOptional(any: "Hello")                       // "Hello"
/// ```
/// - Parameter any: A value of type `T?`, which may or may not be an optional.
/// - Returns: A String representing the unwrapped value or "nil"
public func prettyDescriptionOfOptional<T>(any: T?) -> String {
  switch any {
  case .some(let value):
    // FIXME: provide better imp
    var string = String(describing: value)
    while let range = string.range(of: "Optional(") {
      let descr = string.replacingCharacters(in: range, with: "")
      string = descr.last == ")" ? String(descr.dropLast()) : descr
    }
    return string
  case .none:
    return String(describing: any) // "nil"
  }
}
