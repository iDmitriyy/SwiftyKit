//
//  PreviousAndCurrent.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 14.12.2024.
//

public struct PreviousAndCurrent<T: ~Copyable>: ~Copyable {
  public private(set) var previous: T
  public private(set) var current: T
  
  public init(previous: consuming T, current: consuming T) {
    self.previous = previous
    self.current = current
  }
  
  public mutating func put(_ latest: consuming T) {
    self = Self(previous: current, current: latest)
  }
  
  public consuming func putting(_ latest: consuming T) -> Self {
    self.put(latest)
    return self
  }
}

extension PreviousAndCurrent: Copyable where T: Copyable {
  public init(initial: consuming T) {
    self.init(previous: copy initial, current: initial)
  }
}

extension PreviousAndCurrent: BitwiseCopyable where T: BitwiseCopyable {}

extension PreviousAndCurrent: Equatable where T: Equatable {}

extension PreviousAndCurrent: Hashable where T: Hashable {}

extension PreviousAndCurrent: Sendable where T: Sendable {}
