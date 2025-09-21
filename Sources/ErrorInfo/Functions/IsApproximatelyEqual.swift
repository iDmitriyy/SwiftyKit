//
//  IsApproximatelyEqual.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 28/07/2025.
//

// MARK: - is Approximately Equal

extension ErrorInfoFuncs {
  /// Returns a Boolean value indicating whether two values are approximately equal.
  ///
  /// This method attempts to perform a flexible equality check between values of
  /// potentially unrelated types. It uses several strategies to determine equivalence:
  ///
  /// - If both `lhs` and `rhs` conform to `Equatable`, they are compared using
  ///   an `AnyHashable`-based equality algorithm.
  /// - If both types are reference types (`AnyObject`), and do not conform to `Equatable`,
  ///   identity (`===`) is used for comparison.
  /// - For value types or mixed types that do not conform to `Equatable`, equality is
  ///   determined by comparing their string descriptions via `String(describing:)`.
  ///
  /// This function is particularly useful when comparing values in generic or
  /// type-erased contexts (e.g., for diagnostics or internal equality checks).
  ///
  /// - Parameters:
  ///   - lhs: The left-hand value to compare.
  ///   - rhs: The right-hand value to compare.
  ///
  /// - Returns: `true` if the values are approximately equal; otherwise, `false`.
  public static func isApproximatelyEqualAny<L, R>(_ lhs: L, _ rhs: R) -> Bool {
    // @_specialize(where L == any ErrorInfoValueType, R == any ErrorInfoValueType)
    lazy var isEqualDynamicTypes = type(of: lhs) == type(of: rhs)
    
    return if let lhs = lhs as? (any Equatable), let rhs = rhs as? (any Equatable) {
      // use AnyHashable logic for equality comparison
//      AnyHashable(lhs) == AnyHashable(rhs)
      _isApproximatelyEqualEquatable(lhs, rhs)
    } else if L.self is any AnyObject.Type, R.self is any AnyObject.Type {
      // If not Equatable, classes are compared by ===
      (lhs as AnyObject) === (rhs as AnyObject)
    } else if let lhs = lhs as? (any CustomStringConvertible), let rhs = rhs as? (any CustomStringConvertible) {
      if isEqualDynamicTypes {
        String(describing: lhs) == String(describing: rhs)
      } else {
        // Instance of different Types can have equal string representation, e.g.:
        // struct Foo { let value: Int }
        // struct Bar { let value: Int }
        // so check if type(of: lhs) == type(of: rhs)
        false
      }
    } else {
      if isEqualDynamicTypes {
        String(describing: lhs) == String(describing: rhs)
      } else {
        // Optional has no conditional conformance to CustomStringConvertible when Wrapped == CustomStringConvertible.
        // Because of that String(describing:) for Optional.some(5) and 5 will have different Strings – "Optional(5)" and "5".
        // prettyDescriptionOfOptional solves this problem
        
        
        
        // FIXME: Foo(5) == Bar(5)
        // Use AnyOptionalProtocol.flattened()
        //        if let optionalLhs = lhs as? (any AnyOptionalProtocol) {
        //          if let optionalRhs = rhs as? (any AnyOptionalProtocol), optionalRhs.wrappedType() == optionalLhs.wrappedType() {
        //
        //          } else optionalLhs.wrappedType() == R.self {
        //
        //          } else {
        //
        //          }
        //        } else if let optionalRhs = rhs as? (any AnyOptionalProtocol), optionalRhs.wrappedType() == L.self {
        //
        //        } else {
        //          false
        //        }
        
        // Better imp:
        // if optionalLhs.flattened().wrappedType == optionalRhs.flattened().wrappedType {
        //
        // } else {
        //
        // }
        // or
        // _isOptional(L.self)
        
        prettyDescriptionOfOptional(any: lhs) == prettyDescriptionOfOptional(any: rhs)
      }
    }
  }
  
  private static func _isApproximatelyEqualEquatable(_ lhs: some Equatable, _ rhs: some Equatable) -> Bool {
    let lhsAdapter = _EquatableAnyhashableAdapter(equatableValue: lhs)
    let rhsAdapter = _EquatableAnyhashableAdapter(equatableValue: rhs)
    return AnyHashable(lhsAdapter) == AnyHashable(rhsAdapter)
  }
  
  /// Used for using Equality comparison algorithm from AnyHashable struct for Equatable but not hashable instances.
  private struct _EquatableAnyhashableAdapter<T: Equatable>: Hashable { // @_specialize(where T == any ErrorInfoValueType)
    let equatableValue: T
    
    /// empty imp, hashValue not used
    func hash(into _: inout Hasher) {}
  }
}

/// https://stackoverflow.com/questions/32645612/check-if-variable-is-an-optional-and-what-type-it-wraps/32781143#32781143
fileprivate protocol AnyOptionalProtocol {
  associatedtype Wrapped
  
  
}

extension AnyOptionalProtocol {
  func wrappedType() -> Wrapped.Type { Wrapped.self }
  func wrappedTypeAny() -> Any.Type { Wrapped.self }
}

// extension AnyOptionalProtocol {
//  func flattened() -> Wrapped? {
//
//  }
// }

//extension Optional: AnyOptionalProtocol {
//  func wrappedType() -> Wrapped.Type { Wrapped.self }
//}
