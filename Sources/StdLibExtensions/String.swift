//
//  String.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 14.04.2025.
//

extension String {
  @inlinable @inline(__always)
  public init(minimumCapacity: Int) {
    self.init()
    reserveCapacity(minimumCapacity)
  }
}

extension StringProtocol {
  @inlinable
  public func lowercasingFirstLetter() -> String {
    prefix(1).lowercased() + dropFirst()
  }
  // TODO: - revise for perfomance improvements (check very large strings)
  // - make func consuming
  @inlinable
  public func uppercasingFirstLetter() -> String {
    prefix(1).uppercased() + dropFirst()
  }
}

// TODO: - imp
//extension String {
//  public static func make(utf8Data: Data, line: UInt = #line) -> String {}
//}

// TODO: - uses foundation, need to move to FoundationExtensions or reimplement with StdLib
/*
extension StringProtocol {
  /// Returns true if `other` is non-empty and contained within self by case-sensitive, non-literal search. Otherwise, returns false.
  ///
  /// Equivalent to
  /// ```
  /// range(of: string, options: .caseInsensitive) != nil
  /// ```
  public func containsCaseInsensitively(_ other: some StringProtocol) -> Bool {
    range(of: other, options: .caseInsensitive) != nil
  }
  
  ///  Compares the string value with another string in a case-insensitive manner.
  ///
  /// - Parameter other: The string to compare against in a case-insensitive manner.
  /// - Returns: `true` if the string value is equal to the other string (case-insensitive comparison), `false` otherwise.
  ///
  /// Usage Example:
  /// ```swift
  /// let str = "Hello, World!"
  /// let otherStr = "hello, world!"
  /// str.isEqualCaseInsensitive(to: otherStr) // true
  /// ```
  public func isEqualCaseInsensitively(to other: some StringProtocol) -> Bool {
    caseInsensitiveCompare(other) == .orderedSame
  }
}
*/
