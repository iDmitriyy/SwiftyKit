//
//  PrettyDescription.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 14.12.2024.
//

private import Foundation

// TODO: - remove foundation

// MARK: - Pretty Description for Any & Optional<T>

public func prettyDescription(any: Any) -> String {
  if let optional = any as? (any CustomStringConvertible)? {
    return prettyDescription(any: optional)
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

public func prettyDescription<T>(any: T?) -> String {
  switch any {
  case .some(let value):
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
