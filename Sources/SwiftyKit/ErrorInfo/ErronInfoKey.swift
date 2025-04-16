//
//  ErronInfoKey.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 16.04.2025.
//

public struct ErronInfoKey: Hashable, Sendable, CustomStringConvertible, CustomDebugStringConvertible {
  public var description: String { string }
  
  public var debugDescription: String { string }
  
  internal let string: String
  
  public init(_ string: String) {
    self.string = string
  }
  
  public init(_ string: NonEmptyString) {
    self.init(string.rawValue)
  }
}

extension ErronInfoKey {
  // By default names are given with snake_case, which can ba transformed to camelCase, kebab-case or PascalCase
  // formats when logging.
  
  public static let id = ErronInfoKey("id")
  public static let instanceID = ErronInfoKey("instance_id")
  public static let status = ErronInfoKey("status")
  
  public static let requestURL = ErronInfoKey("request_url")
  public static let responseURL = ErronInfoKey("response_url")
  public static let responseData = ErronInfoKey("response_data")
  public static let responseJson = ErronInfoKey("response_json")
  
  public static let file = ErronInfoKey("file")
  public static let line = ErronInfoKey("line")
  public static let fileLine = ErronInfoKey("file_line")
}
