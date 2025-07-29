//
//  TextError.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 15.12.2024.
//

@_spi(SwiftyKitBuiltinTypes)
public struct TextError: Error, CustomStringConvertible, CustomDebugStringConvertible {
  public var description: String { text }
  public var debugDescription: String { text }
  
  package let text: String
  package let source: StaticFileLine
  
  public init(text: String, source: StaticFileLine = .this()) {
    self.text = text
    self.source = source
  }
  
  public static func message(_ message: String, source: StaticFileLine = .this()) -> Self {
    Self(text: message, source: source)
  }
}
