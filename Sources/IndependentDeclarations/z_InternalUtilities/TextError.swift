//
//  TextError.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 15.12.2024.
//

@usableFromInline package struct TextError: Error, CustomStringConvertible, CustomDebugStringConvertible {
  @usableFromInline package var description: String { text }
  @usableFromInline package var debugDescription: String { text }
  
  package let text: String
  package let source: StaticFileLine
  
  @usableFromInline package init(text: String, source: StaticFileLine = .this()) {
    self.text = text
    self.source = source
  }
}
