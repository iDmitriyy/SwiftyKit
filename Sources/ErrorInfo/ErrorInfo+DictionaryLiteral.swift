//
//  ErrorInfo+DictionaryLiteral.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 26/07/2025.
//

// MARK: Expressible By Dictionary Literal

extension ErrorInfo: ExpressibleByDictionaryLiteral {
  public typealias Value = any ErrorInfoValueType
  public typealias Key = String
  
  public init(dictionaryLiteral elements: (String, Value)...) {
    guard !elements.isEmpty else {
      self = .empty
      return
    }
    
    self.init()
    elements.forEach { key, value in self[key] = value }
  }
}
