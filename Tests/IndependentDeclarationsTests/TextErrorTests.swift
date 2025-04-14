//
//  TextErrorTests.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 15.12.2024.
//

import Foundation
@testable import IndependentDeclarations
import Testing

struct TextErrorTests {
  @Test func textReflected() {
    let text = "Value 5 is out of bounds"
    let error = TextError(text: text)
    
    #expect(String(describing: error) == text)
    #expect(String(reflecting: error) == text)
    #expect("\(error)" == text)
    // TODO: - add file line to desccription & debug desccription
    let anyError: any Error = error
    #expect(String(describing: anyError) == text)
    #expect(String(reflecting: anyError) == text)
    #expect("\(anyError)" == text)
    
    let nsError: NSError = error as NSError
    #expect(String(describing: nsError) == text)
    #expect(String(reflecting: nsError) == text)
    #expect("\(nsError)" == text)
    #expect(nsError.description == text)
    
    #expect(nsError.localizedDescription != text)
    #expect(nsError.domain == "IndependentDeclarations.TextError")
    #expect(nsError.code == 1)
    #expect(nsError.userInfo.isEmpty)
    #expect(nsError.underlyingErrors.isEmpty)
  }
}
