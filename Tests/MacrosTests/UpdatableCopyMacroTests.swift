//
//  UpdatableCopyMacroTests.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 30/07/2025.
//

#if canImport(MacroImps)
import MacroImps
import Macros
import XCTest

final class UpdatableCopyMacroTests: XCTestCase {
  private let macros = ["URL": UpdatableCopyMacro.self]
  
}

extension UpdatableCopyMacroTests {
  @UpdatableCopy
  struct Product {
    let name: String
    let price: Double
    let oldPrice: Double?
  }
}

#endif
