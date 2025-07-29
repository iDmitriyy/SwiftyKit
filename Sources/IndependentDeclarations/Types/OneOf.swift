//
//  OneOf.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 14.12.2024.
//

// MARK: - OneOf 3

public enum OneOf2<A: ~Copyable, B: ~Copyable>: ~Copyable {
  case first(A)
  case second(B)
}

extension OneOf2: Copyable where A: Copyable, B: Copyable {}

extension OneOf2: BitwiseCopyable where A: BitwiseCopyable, B: BitwiseCopyable {}

extension OneOf2: Equatable where A: Equatable, B: Equatable {}

extension OneOf2: Hashable where A: Hashable, B: Hashable {}

extension OneOf2: Comparable where A: Comparable, B: Comparable {}

extension OneOf2: Sendable where A: Sendable, B: Sendable {}

// MARK: - OneOf 3

public enum OneOf3<A: ~Copyable, B: ~Copyable, C: ~Copyable>: ~Copyable {
  case first(A)
  case second(B)
  case third(C)
}

extension OneOf3: Copyable where A: Copyable, B: Copyable, C: Copyable {}

extension OneOf3: BitwiseCopyable where A: BitwiseCopyable, B: BitwiseCopyable, C: BitwiseCopyable {}

extension OneOf3: Equatable where A: Equatable, B: Equatable, C: Equatable {}

extension OneOf3: Hashable where A: Hashable, B: Hashable, C: Hashable {}

extension OneOf3: Comparable where A: Comparable, B: Comparable, C: Comparable {}

extension OneOf3: Sendable where A: Sendable, B: Sendable, C: Sendable {}

// MARK: - OneOf 4

public enum OneOf4<A: ~Copyable, B: ~Copyable, C: ~Copyable, D: ~Copyable>: ~Copyable {
  case first(A)
  case second(B)
  case third(C)
  case fourth(D)
}

extension OneOf4: Copyable where A: Copyable, B: Copyable, C: Copyable, D: Copyable {}

extension OneOf4: BitwiseCopyable where A: BitwiseCopyable, B: BitwiseCopyable, C: BitwiseCopyable, D: BitwiseCopyable {}

extension OneOf4: Equatable where A: Equatable, B: Equatable, C: Equatable, D: Equatable {}

extension OneOf4: Hashable where A: Hashable, B: Hashable, C: Hashable, D: Hashable {}

extension OneOf4: Comparable where A: Comparable, B: Comparable, C: Comparable, D: Comparable {}

extension OneOf4: Sendable where A: Sendable, B: Sendable, C: Sendable, D: Sendable {}

// MARK: - OneOf 5

public enum OneOf5<A: ~Copyable, B: ~Copyable, C: ~Copyable, D: ~Copyable, E: ~Copyable>: ~Copyable {
  case first(A)
  case second(B)
  case third(C)
  case fourth(D)
  case fifth(E)
}

extension OneOf5: Copyable where A: Copyable, B: Copyable, C: Copyable, D: Copyable, E: Copyable {}

extension OneOf5: BitwiseCopyable where A: BitwiseCopyable, B: BitwiseCopyable, C: BitwiseCopyable, D: BitwiseCopyable, E: BitwiseCopyable {}

extension OneOf5: Equatable where A: Equatable, B: Equatable, C: Equatable, D: Equatable, E: Equatable {}

extension OneOf5: Hashable where A: Hashable, B: Hashable, C: Hashable, D: Hashable, E: Hashable {}

extension OneOf5: Comparable where A: Comparable, B: Comparable, C: Comparable, D: Comparable, E: Comparable {}

extension OneOf5: Sendable where A: Sendable, B: Sendable, C: Sendable, D: Sendable, E: Sendable {}
