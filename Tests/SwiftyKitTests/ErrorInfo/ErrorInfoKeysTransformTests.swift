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
  private static let expectedToStayUnmodified: [String] = [
    "",
    " ",
    "  ",
  ]
  
  private static let expectedModifiedForPascalOnly: [String] = [ // for pascal first char will be uppercased
    "string.with.dots",
    "string.WiTh.dOtS2",
    "string&WIth*|",
  ]
  
  private let keys: [String] = [
    "snake_case_key",
    "camelCaseKey",
    "kebab-case-key",
    "PascalCaseKey",
    "this-is-a-test-key",
    "This-Is-Mixed-CASE",
    "underscore_and-hyphen",
    "____many___underscores__",
    "----many---hyphens--",
    "_________", // only underscores
    "---------", // only hyphens
    "RepeatedUPPERCASE",
  ] + expectedToStayUnmodified + expectedModifiedForPascalOnly
  // TODO: Add not only english capitalized
  
  @Test func fromAnyStyleToCamelCased() throws {
    let camelCased = keys.map(ErronInfoKey.fromAnyStyleToCamelCased(string:))
    
    let expected = [
      "snakeCaseKey",
      "camelCaseKey",
      "kebabCaseKey",
      "pascalCaseKey",
      "thisIsATestKey",
      "thisIsMixedCASE",
      "underscoreAndHyphen",
      "manyUnderscores",
      "manyHyphens",
      "_________", // only underscores
      "---------", // only hyphens
      "repeatedUPPERCASE",
    ] + Self.expectedToStayUnmodified + Self.expectedModifiedForPascalOnly
    
    let diff = Set(camelCased).symmetricDifference(expected)
    #expect(diff.isEmpty, "\(diff)")
  }
  
  @Test func fromAnyStyleToPascalCased() throws {
    let pascalCased = keys.map(ErronInfoKey.fromAnyStyleToPascalCased(string:))
    
    let expected = [
      "SnakeCaseKey",
      "CamelCaseKey",
      "KebabCaseKey",
      "PascalCaseKey",
      "ThisIsATestKey",
      "ThisIsMixedCASE",
      "UnderscoreAndHyphen",
      "ManyUnderscores",
      "ManyHyphens",
      "_________", // only underscores
      "---------", // only hyphens
      "RepeatedUPPERCASE",
    ] + Self.expectedToStayUnmodified + Self.expectedModifiedForPascalOnly.map { $0.uppercasingFirstLetter() }
    
    let diff = Set(pascalCased).symmetricDifference(expected)
    #expect(diff.isEmpty, "\(diff)")
  }
}
