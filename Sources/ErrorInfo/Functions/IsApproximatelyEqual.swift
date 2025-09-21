//
//  IsApproximatelyEqual.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 28/07/2025.
//

// MARK: - is Approximately Equal

extension ErrorInfoFuncs {
  // TODO: - add constraint T: CustomStringConvertible & Equatable & Sendable
  public static func isApproximatelyEqualAny<L, R>(_ lhs: L, _ rhs: R) -> Bool {
    if let lhs = lhs as? (any Equatable), let rhs = rhs as? (any Equatable) {
      // use AnyHashable logic for equality comparison
//      AnyHashable(lhs) == AnyHashable(rhs)
      isApproximatelyEqual(lhs, rhs)
    } else {
      if L.self is any AnyObject.Type {
        if R.self is any AnyObject.Type {
          // If not Equatable, classes are compared by ===
          (lhs as AnyObject) === (rhs as AnyObject)
        } else {
          false
        }
      } else {
        String(describing: lhs) == String(describing: rhs)
      }
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
