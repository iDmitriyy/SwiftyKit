//
//  URLMacroTests.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 30/07/2025.
//

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import SwiftSyntaxMacrosGenericTestSupport
import SwiftSyntax
import SwiftDiagnostics

#if canImport(MacroImps)
import MacroImps
import XCTest

final class URLMacroTests: XCTestCase {
  private let macros = ["URL": URLMacro.self]

  func testExpansionWithMalformedURLEmitsError() {
    assertMacroExpansion(
      """
      let invalid = #URL("https://not a url.com:invalid-port/")
      """,
      expandedSource: """
        let invalid = #URL("https://not a url.com:invalid-port/")
        """,
      diagnostics: [
        DiagnosticSpec(
          message: #"malformed url: "https://not a url.com:invalid-port/""#,
          line: 1,
          column: 15,
          severity: .error
        )
      ],
      macros: macros,
      indentationWidth: .spaces(2)
    )
  }

  func testExpansionWithStringInterpolationEmitsError() {
    assertMacroExpansion(
      #"""
      #URL("https://\(domain)/api/path")
      """#,
      expandedSource: #"""
        #URL("https://\(domain)/api/path")
        """#,
      diagnostics: [
        DiagnosticSpec(message: "#URL requires a static string literal", line: 1, column: 1, severity: .error)
      ],
      macros: macros,
      indentationWidth: .spaces(2)
    )
  }

  func testExpansionWithValidURL() {
    assertMacroExpansion(
      """
      let valid = #URL("https://swift.org/")
      """,
      expandedSource: """
        let valid = URL(string: "https://swift.org/")!
        """,
      macros: macros,
      indentationWidth: .spaces(2)
    )
  }
}
#endif

