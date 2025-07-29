//
//  KeyPath.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 14.04.2025.
//

extension KeyPath {
  /// https://github.com/apple/swift-evolution/blob/main/proposals/0369-add-customdebugdescription-conformance-to-anykeypath.md
  @inlinable
  internal func asErrorInfoKeyString() -> String {
    String(reflecting: self)
  }
}
