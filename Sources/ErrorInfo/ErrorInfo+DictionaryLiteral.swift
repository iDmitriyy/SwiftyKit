//
//  ErrorInfo+DictionaryLiteral.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 26/07/2025.
//

// MARK: Expressible By Dictionary Literal

extension ErrorInfo: ExpressibleByDictionaryLiteral {
  public typealias Value = (any ErrorInfoValueType)?
  public typealias Key = String
  // FIXME: can optional ErrorInfoValueType be used without conflict with ErrorInfoIterable protocol
  // Alternative: if optionals are impossible for DictionaryLiteral usage, then add functionBuilder initialization that allows
  // optional values
  
  public init(dictionaryLiteral elements: (String, Value)...) {
    self.init()
    elements.forEach { key, value in self[key] = value }
  }
}
