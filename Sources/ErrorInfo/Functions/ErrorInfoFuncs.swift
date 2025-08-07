//
//  ErrorInfoFunctions.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 16.04.2025.
//

public import protocol IndependentDeclarations.DictionaryUnifyingProtocol
private import FoundationExtensions

// MARK: - Merge ErrorInfo

public enum ErrorInfoFuncs: Namespacing {}

extension ErrorInfoFuncs {
  /// https://github.com/apple/swift-evolution/blob/main/proposals/0369-add-customdebugdescription-conformance-to-anykeypath.md
  @inlinable
  internal static func asErrorInfoKeyString<R, V>(keyPath: KeyPath<R, V>) -> String {
    String(reflecting: keyPath)
  }
}
