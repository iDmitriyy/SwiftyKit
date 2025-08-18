//
//  InformativeError.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 07/08/2025.
//

public protocol InformativeError: Error {
  associatedtype ErrorInfoType: ErrorInfoCollection
  
  var info: ErrorInfoType { get }
}
