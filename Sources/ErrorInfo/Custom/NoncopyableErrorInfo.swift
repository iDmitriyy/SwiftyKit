//
//  NoncopyableErrorInfo.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 07/08/2025.
//

import OrderedCollections

struct NoncopyableErrorInfo: ~Copyable, Sendable {
  internal private(set) var storage: OrderedDictionary<String, any ErrorInfoValueType>
}
