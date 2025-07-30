//
//  _ModuleImports.swift
//  swifty-kit
//
//  Created by tmp on 30/07/2025.
//

// Imports common for all files in module:

@_exported public import Foundation
@_exported public import IndependentDeclarations
@_exported public import StdLibExtensions
@_exported public import SwiftSyntax // can be replaced with public import in each file (macros are public so used symbols need to be public)
@_exported public import SwiftSyntaxMacros // can be replaced with public import in each file (macros are public so used symbols need to be public)
@_exported public import SwiftSyntaxBuilder // can be replaced with private import in each file
