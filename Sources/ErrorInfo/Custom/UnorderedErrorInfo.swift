//
//  UnorderedErrorInfo.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 26/07/2025.
//

/// [String: Any] || Unordered Type has one benefit prior to Ordered / Sorted Dictionary – keys have different order.
/// if logging system has strong limit on number of key-value pairs can be logged and drops ones that out of limit, it is not so big problem when keys have different order.
/// Each log in such situation will have different key-value pairs. From this mosaic a valuable picture of problem can be restored.
fileprivate struct UnorderedErrorInfo: ErrorInfoCollection {
  internal private(set) var storage: [String: any ValueType]
  
  fileprivate init(storage: [String: any ValueType]) {
    self.storage = storage
  }
  
  public init() {
    self.init(storage: [:])
  }
}

// MARK: Collection IMP

extension UnorderedErrorInfo {
  public typealias Index = Dictionary<String, any Sendable>.Index
  
  public typealias Element = (key: String, value: any ValueType)
  
  public var isEmpty: Bool { storage.isEmpty }
  
  public var count: Int { storage.count }
  
  public var startIndex: Index { storage.startIndex }
  
  public var endIndex: Index { storage.endIndex }
  
  subscript(position: Index) -> Element {
    storage[position]
  }
  
  func index(after i: Index) -> Index {
    storage.index(after: i)
  }
}

// MARK: CustomStringConvertible IMP

extension UnorderedErrorInfo {
  public var description: String { String(describing: storage) }
  
  public var debugDescription: String { String(reflecting: storage) }
}
