//
//  Sequence.swift
//  swifty-kit
//
//  Created by tmp on 21/09/2025.
//

extension Sequence {
  @inlinable @inline(__always)
  public consuming func apply<T>(_ transform: (consuming Self) -> T) -> T { transform(self) }
}
