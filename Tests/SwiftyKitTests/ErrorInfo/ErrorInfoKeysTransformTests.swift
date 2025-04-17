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
    "...",
  ]
    
  private let keys: [String] = [
    "snake_case_key",
    "camelCaseKey",
    "kebab-case-key",
    "PascalCaseKey",
    "this-is-a-test-key",
    "This-Is-Mixed-CASE",
    "underscore_and-hyphen",
    "testäöüßÄÖÜ",
    "ßteßt",
    "____many___underscores__",
    "----many---hyphens--",
    "_________", // only underscores
    "---------", // only hyphens
    "RepeatedUPPERCASE",
    "string.with.dots",
    "string.WiTh.dOtS2",
    "string&WIth*|",
  ] + expectedToStayUnmodified
  // TODO: Add not only english capitalized
  
  // MARK: - Tests
  
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
      "testäöüßÄÖÜ",
      "ßteßt",
      "manyUnderscores",
      "manyHyphens",
      "_________", // only underscores
      "---------", // only hyphens
      "repeatedUPPERCASE",
      "string.with.dots",
      "string.WiTh.dOtS2",
      "string&WIth*|",
    ] + Self.expectedToStayUnmodified
    
    let diff = Set(camelCased).subtracting(expected)
    #expect(diff.isEmpty)
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
      "TestäöüßÄÖÜ",
      "SSteßt",
      "ManyUnderscores",
      "ManyHyphens",
      "_________", // only underscores
      "---------", // only hyphens
      "RepeatedUPPERCASE",
      "String.with.dots",
      "String.WiTh.dOtS2",
      "String&WIth*|",
    ] + Self.expectedToStayUnmodified
    
    let diff = Set(pascalCased).subtracting(expected)
    #expect(diff.isEmpty)
  }
  
  @Test func fromAnyStyleToSnakeCased() throws {
    let snakeCased = keys.map(ErronInfoKey.fromAnyStyleToSnakeCased(string:))
    
    let expected = [
      "snake_case_key",
      "camel_case_key",
      "kebab_case_key",
      "pascal_case_key",
      "this_is_a_test_key",
      "this_is_mixed_case",
      "underscore_and_hyphen",
      "testäöüß_äöü",
      "ßteßt",
      "____many___underscores__",
      "____many___hyphens__",
      "_________", // only underscores
      "_________", // only hyphens
      "repeated_uppercase",
      "string.with.dots",
      "string._wi_th.d_ot_s2",
      "string&_with*|",
    ] + Self.expectedToStayUnmodified
    
    let diff = Set(snakeCased).subtracting(expected)
    #expect(diff.isEmpty)
  }
  
  @Test func fromAnyStyleToKebabCased() throws {
    let snakeCased = keys.map(ErronInfoKey.fromAnyStyleToSnakeCased(string:))
    
    let expected = [
      "snake_case_key",
      "camel_case_key",
      "kebab_case_key",
      "pascal_case_key",
      "this_is_a_test_key",
      "this_is_mixed_case",
      "underscore_and_hyphen",
      "testäöüß_äöü",
      "ßteßt",
      "____many___underscores__",
      "____many___hyphens__",
      "_________", // only underscores
      "_________", // only hyphens
      "repeated_uppercase",
      "string.with.dots",
      "string._wi_th.d_ot_s2",
      "string&_with*|",
    ] + Self.expectedToStayUnmodified
    
    let diff = Set(snakeCased).subtracting(expected)
    #expect(diff.isEmpty)
  }
}
