//
//  Comparable.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 14.12.2024.
//

extension Comparable {
  @inlinable public func boundedWith(_ boundA: Self, _ boundB: Self) -> Self {
    guard boundA != boundB else { return boundA }

    return if boundA < boundB {
      min(boundB, max(self, boundA))
    } else {
      min(boundA, max(self, boundB))
    }
  }
  
  // TODO: - Add clamped() func with Range arg
}

extension Comparable where Self: FloatingPoint {
  @inlinable
  public func boundedWith(_ boundA: Self, _ boundB: Self) -> Self {
    guard boundA != boundB else { return boundA }
    
    return if boundA < boundB {
      Self.minimum(boundB, Self.maximum(self, boundA))
    } else {
      Self.minimum(boundA, Self.maximum(self, boundB))
    }
  }
}

/// Fixes a bug of Swift.min: https://developer.apple.com/forums/thread/5842
@inlinable public func min<T: FloatingPoint>(_ x: T, _ y: T) -> T {
  T.minimum(x, y)
}

/// Fixes a bug of Swift.max: https://developer.apple.com/forums/thread/5842
@inlinable public func max<T: FloatingPoint>(_ x: T, _ y: T) -> T {
  T.maximum(x, y)
}
