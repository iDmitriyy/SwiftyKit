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
        ColorValuesFromRGBAHexMacro.self,
        UpdatableCopyMacro.self,
        URLMacro.self,
    ]
}
