//
//  ErrorInfoKeysTransformTests.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 16.04.2025.
//

import Foundation
@testable import SwiftyKit
import Testing

struct ErrorInfoKeysTransformTests {
  private static let expectedToBeUnmodified: [String] = [
    "string.with.dots",
    "",
    " ",
    "  ",
  ]
  
  private let keys: [String] = [
    "snake_case_key",
    "camelCaseKey",
    "kebab-case-key",
    "PascalCaseKey",
    "____many___underscores__",
    "----many---hyphens--",
    "RepeatedUPPERCASE"
  ] + expectedToBeUnmodified
  // TODO: Add not only english capitalized
  
  @Test func fromAnyStyleToCamelCased() throws {
    let camelCased = keys.map(ErronInfoKey.fromAnyStyleToCamelCased(string:))
    
    let expected = [
      "snakeCaseKey",
      "camelCaseKey",
      "kebabCaseKey",
      "pascalCaseKey",
      "manyUnderscores",
      "manyHyphens",
      "repeatedUPPERCASE"
    ] + Self.expectedToBeUnmodified
    
    #expect(camelCased == expected)
  }
}
