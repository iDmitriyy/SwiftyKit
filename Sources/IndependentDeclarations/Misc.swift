//
//  Misc.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 14.04.2025.
//

extension String {
  /// Perfomant way to convert StaticString to String
  @inlinable
  public init(_ staticString: StaticString) {
    self = String(describing: staticString)
    // under the hood of `description` property the following is used: `withUTF8Buffer { String._uncheckedFromUTF8($0) }`
  }
}
