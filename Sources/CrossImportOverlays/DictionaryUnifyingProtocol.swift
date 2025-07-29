//
//  DictionaryUnifyingProtocol.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 28/07/2025.
//

public import protocol IndependentDeclarations.DictionaryUnifyingProtocol
public import struct OrderedCollections.OrderedDictionary

extension OrderedDictionary: DictionaryUnifyingProtocol {
  public init(minimumCapacity: Int) {
    self.init(minimumCapacity: minimumCapacity, persistent: false)
  }
}

// + #nonEmptyString macro
