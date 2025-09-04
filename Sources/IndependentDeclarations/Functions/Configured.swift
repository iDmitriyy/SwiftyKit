//
//  Configured.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 14.12.2024.
//

@inlinable
public func configured<T: AnyObject, E>(object: T, closure: (_ object: T) throws(E) -> Void) throws(E) -> T {
  try closure(object)
  // TODO: - ? sending T
  // consuming | borrowing
  return object
}

@inlinable
public func configure<T: AnyObject, E>(object: T, closure: (_ object: T) throws(E) -> Void) throws(E) {
  try closure(object)
}
