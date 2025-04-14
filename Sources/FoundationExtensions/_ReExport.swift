//
//  _ReExport.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 14.04.2025.
//

@_exported public import class Foundation.Bundle
@_exported public import struct Foundation.CharacterSet
@_exported public import protocol Foundation.LocalizedError

//@_exported import IndependentDeclarations
//
//extension TextError: LocalizedError { // lead to compiler error in another package: Cannot find type 'TextError' in scope
//  @usableFromInline package var errorDescription: String? { text }
//}
