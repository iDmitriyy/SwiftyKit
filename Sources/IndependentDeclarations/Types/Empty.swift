//
//  Empty.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 14.12.2024.
//

public struct Empty: Hashable, Sendable, CustomStringConvertible {
  public var description: String { "Empty()" }
  
  public init() {}
}

//extension Empty: Codable {
//  public init(from decoder: any Decoder) { self.init() }
//}
