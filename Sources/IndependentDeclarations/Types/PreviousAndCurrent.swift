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
  
  public mutating func update(by newValue: consuming T) {
    self = Self(previous: current, current: newValue)
  }
  
  public consuming func updated(by newValue: consuming T) -> Self {
    self.update(by: newValue)
    return self
  }
}

extension PreviousAndCurrent: Copyable where T: Copyable {
  public init(seed: consuming T) {
    self.init(previous: copy seed, current: seed)
  }
}

extension PreviousAndCurrent: BitwiseCopyable where T: BitwiseCopyable {}

extension PreviousAndCurrent: Equatable where T: Equatable {}

extension PreviousAndCurrent: Hashable where T: Hashable {}

extension PreviousAndCurrent: Sendable where T: Sendable {}
