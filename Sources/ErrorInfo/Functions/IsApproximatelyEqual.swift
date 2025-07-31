//
//  IsApproximatelyEqual.swift
//  swifty-kit
//
//  Created by tmp on 28/07/2025.
//

// MARK: - is ApproximatelycEqual

extension ErrorInfoFuncs {
  // TODO: - add constraint T: CustomStringConvertible & Equatable & Sendable
  public static func isApproximatelyEqual<T>(_ lhs: T, _ rhs: T) -> Bool {
    if let lhs = lhs as? (any Hashable), let rhs = rhs as? (any Hashable) {
      AnyHashable(lhs) == AnyHashable(rhs) // use AnyHashable logic for equality comparison
      // TODO: What if ref types? 
    } else {
      String(describing: lhs) == String(describing: rhs)
    }
  }
}
