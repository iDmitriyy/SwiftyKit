//
//  LegacyErrorInfo.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 16/09/2025.
//

// ?? can It be done as typeaalias
// LegacyErrorInfo = GenericValueErrorInfo<String, Any>

struct LegacyErrorInfo: IterableErrorInfo {
  typealias Key = String
  typealias Value = Any
  typealias Element = (key: String, value: Any)
  
  private var storage: [String: Any]
  
  func makeIterator() -> some IteratorProtocol<Element> {
    storage.makeIterator()
  }
  
  init(_ info: [String: Any]) {
    self.storage = info
  }
}
