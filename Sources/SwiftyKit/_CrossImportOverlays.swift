//
//  _CrossImportOverlays.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 14.04.2025.
//

extension OrderedDictionary: DictionaryUnifyingProtocol {
  public init(minimumCapacity: Int) {
    self.init(minimumCapacity: minimumCapacity, persistent: false)
  }
}

// + #nonEmptyString macro
