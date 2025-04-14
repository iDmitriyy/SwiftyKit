//
//  Collection.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 14.04.2025.
//

extension Collection {
  @inlinable
  public var isNotEmpty: Bool { !isEmpty }
  
  @inlinable
  public func compactMap<ElementOfResult>() -> [ElementOfResult] where Element == ElementOfResult? {
    compactMap { $0 }
  }
  
  @inlinable @inline(__always)
  public func apply<T>(_ function: (Self) -> T) -> T {
    function(self)
  }
}
