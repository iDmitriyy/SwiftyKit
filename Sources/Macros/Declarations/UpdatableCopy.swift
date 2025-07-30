//
//  UpdatableCopy.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 30/07/2025.
//

@attached(member, names: named(copy))
public macro UpdatableCopy() = #externalMacro(module: "MacroImps", type: "UpdatableCopyMacro")
