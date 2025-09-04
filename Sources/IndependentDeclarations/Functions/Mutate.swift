//
//  Mutate.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 14.12.2024.
//

@inlinable
public func mutate<T: ~Copyable, E>(value: consuming T, mutation: (inout T) throws(E) -> Void) throws(E) -> T {
  try mutation(&value)
  return value
}

@available(*, deprecated, message: "use configured(object:) for reference types instead")
public func mutate<T: AnyObject, E>(value: consuming T, mutation: (inout T) throws(E) -> Void) throws(E) -> T {
  try mutation(&value)
  return value
}

// TODO: - check new signatire on existing codebases
// make available for value types only
// make unavailable instead of deprecated (goal is to disalolw using it / compiler error). @available(*, unavailable doesn't
// achieve it making overload resolution to choose wrong function (for value types).
// ~Copyable classes

