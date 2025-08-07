//
//  IsApproximatelyEqual.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 28/07/2025.
//

// MARK: - is ApproximatelycEqual

extension ErrorInfoFuncs {
  // TODO: - add constraint T: CustomStringConvertible & Equatable & Sendable
  public static func isApproximatelyEqualAny<T>(_ lhs: T, _ rhs: T) -> Bool {
    if let lhs = lhs as? (any Hashable), let rhs = rhs as? (any Hashable) {
      AnyHashable(lhs) == AnyHashable(rhs) // use AnyHashable logic for equality comparison
      // TODO: What if ref types?
    } else {
      String(describing: lhs) == String(describing: rhs)
    }
  }
  
  public static func isApproximatelyEqualEquatable<T>(_ lhs: T, _ rhs: T) -> Bool where T: Equatable & CustomStringConvertible {
    let lhsAdapter = _EquatableAnyhashableAdapter(lhs)
    let rhsAdapter = _EquatableAnyhashableAdapter(rhs)
    return AnyHashable(lhsAdapter) == AnyHashable(rhsAdapter)
  }
  
  /// Used for using Equality comparison algorithm from AnyHashable struct for Equatable but not hashable values.
  private struct _EquatableAnyhashableAdapter<T: Equatable>: Hashable {
    let equatableValue: T
    
    init(_ equatableValue: T) {
      self.equatableValue = equatableValue
    }
    /// empty imp
    func hash(into hasher: inout Hasher) {}
  }
}
