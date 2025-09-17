//
//  Collection.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 14.04.2025.
//

extension Collection {
  @inlinable @inline(__always)
  public var isNotEmpty: Bool { !isEmpty }
  
  @inlinable @inline(__always)
  public func apply<T>(transform function: (Self) -> T) -> T { function(self) }
}
