//
//  LegacyErrorInfo.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 16/09/2025.
//

// ?? can It be done as typeaalias
// LegacyErrorInfo = GenericValueErrorInfo<String, Any>

public struct LegacyErrorInfo: IterableErrorInfo {
  public typealias Key = String
  public typealias Value = Any
  public typealias Element = (key: String, value: Any)
  
  private var storage: KeyAugmentationErrorInfoGeneric<Dictionary<String, Any>>
  
  public func makeIterator() -> some IteratorProtocol<Element> {
    storage.makeIterator()
  }
  
  public init(_ info: [String: Any]) {
    storage = KeyAugmentationErrorInfoGeneric(info)
  }
}

extension LegacyErrorInfo {
  // TODO: this method should be an overload for default implementation
  public func asDictionary() -> [String: Any] {
    storage._dict
  }
}
