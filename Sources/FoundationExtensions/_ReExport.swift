//
//  _ReExport.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 14.04.2025.
//

@_exported public import class Foundation.Bundle
@_exported public import struct Foundation.CharacterSet
@_exported public import protocol Foundation.LocalizedError

@_exported import IndependentDeclarations

extension TextError: LocalizedError {
  @usableFromInline package var errorDescription: String? { text }
}
