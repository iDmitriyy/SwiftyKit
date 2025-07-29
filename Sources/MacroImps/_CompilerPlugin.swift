//
//  _CompilerPlugin.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 29/07/2025.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct MacroPlugin: CompilerPlugin {
  let providingMacros: [any Macro.Type] = [
        StringifyMacro.self,
        ColorValuesFromHexMacro.self,
//        URLMacro.self,
    ]
}
