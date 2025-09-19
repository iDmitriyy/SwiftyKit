//
//  DataKeyErrorInfo.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 19/09/2025.
//

import ErrorInfo
import OrderedCollections
import struct Foundation.Data

struct DataKeyErrorInfo {
  private var storage: KeyAugmentationErrorInfoGeneric<OrderedDictionary<Data, any ErrorInfoValueType>>
}

@available(macOS 16.0.0, *)
struct LimitedCountErrorInfo<let count: Int, Element> {
  
  func ddd() {
    Self.count
  }
}
