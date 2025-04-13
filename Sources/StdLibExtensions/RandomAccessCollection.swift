//
//  RandomAccessCollection.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 14.04.2025.
//

extension RandomAccessCollection {
  @inlinable @inline(__always)
  public subscript(at index: Index) -> Element? { // TODO: - ? @_alwaysEmitIntoClient || @inlinable
    guard indices.contains(index) else { return nil }
    return self[index]
  }
}
