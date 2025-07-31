//
//  UpdatableCopyMacroTests.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 30/07/2025.
//

//import SwiftSyntaxMacrosTestSupport

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import SwiftSyntaxMacrosGenericTestSupport
import SwiftSyntax
import SwiftDiagnostics

#if canImport(MacroImps)
import MacroImps
import MacroSymbols
//import Macros
import XCTest

final class UpdatableCopyMacroTests: XCTestCase {
  private let macros = ["UpdatableCopyMacro": UpdatableCopyMacro.self]
  
  func testExpansionWithValidStruct() {
//    print("_____________ UpdatableCopyMacro")
    let input = """
        struct Product {
          let name: String
          let price: Double
          let oldPrice: Double?
        }
      """
    
    let expected = """
        struct Product {
          let name: String
          let price: Double
          let oldPrice: Double?
        }
      """
    // func copyUpdating()
    assertMacroExpansion(input,
                         expandedSource: expected,
                         macros: macros,
                         indentationWidth: .spaces(2))
  }
}

extension UpdatableCopyMacroTests {
//  @UpdatableCopy
//  struct Product {
//    let name: String
//    let price: Double
//    let oldPrice: Double?
//  }
}

#endif
