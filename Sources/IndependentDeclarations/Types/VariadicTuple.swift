//
//  VariadicTuple.swift
//  swifty-kit
//
//  Created by tmp on 06/10/2025.
//

public struct VariadicTuple<each T> {
  public let elements: (repeat each T)
  
  public init(_ elements: repeat each T) {
    self.elements = (repeat each elements)
  }
}
