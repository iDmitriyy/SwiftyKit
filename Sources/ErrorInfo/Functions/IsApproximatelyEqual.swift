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
    if let lhs = lhs as? (any Equatable), let rhs = rhs as? (any Equatable) {
      // use AnyHashable logic for equality comparison
//      AnyHashable(lhs) == AnyHashable(rhs)
      // TODO: What if ref types?
      isApproximatelyEqual(lhs, rhs)
    } else {
      // for two Anyobject instances string interpolation is address, so it is the same as === comparison.
      String(describing: lhs) == String(describing: rhs)
    }
  }
  
  private static func isApproximatelyEqual(_ lhs: some Equatable, _ rhs: some Equatable) -> Bool {
    let lhsAdapter = _EquatableAnyhashableAdapter(equatableValue: lhs)
    let rhsAdapter = _EquatableAnyhashableAdapter(equatableValue: rhs)
    return AnyHashable(lhsAdapter) == AnyHashable(rhsAdapter)
  }
  
  /// Used for using Equality comparison algorithm from AnyHashable struct for Equatable but not hashable instances.
  private struct _EquatableAnyhashableAdapter<T: Equatable>: Hashable {
    let equatableValue: T
    
    /// empty imp, hashValue not used
    func hash(into _: inout Hasher) {}
  }
}
