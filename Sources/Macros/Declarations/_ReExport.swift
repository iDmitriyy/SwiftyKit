//
//  _ReExport.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 29/07/2025.
//

@_exported public import MacroSymbols

/*
 apple examples: https://github.com/swiftlang/swift-syntax/tree/main/Examples/Sources/MacroExamples
 
 MemberwiseInit https://github.com/gohanlon/swift-memberwise-init-macro?tab=readme-ov-file#explicitly-ignore-properties
 
 #URL
 #HexColors 
 #Equatable #Hashable  | usage: Hashable(includingOnly:) Hashable(allExcept:)
 @OptionSet
 @PrivateEnumInitializers | for structs with private backing enum, generate static-func initializers with cases names.
 @DebugDescription
 
 #NewEnumWithoutAssociatedValues  | #NewEnum(name: String? = nil, accessLevel: A? = nil)
 
 Inspect:
 https://github.com/krzysztofzablocki/Swift-Macros
 EnumOptionSet
 CodableOptionSet
 SampleBuilder
 ? PropertyTracer | only for debug
 SmartLogMacro
 SwiftCopyable  | hobby: hobby has no ?? and old value. Seems to be error in documantation or imp
 
 https://github.com/jakkornat/CaseEquatable
 
 https://github.com/pointfreeco/swift-case-paths
 
 https://github.com/ShenghaiWang/SwiftMacros :
 @ConformToEquatable
 @ConformToHashable
 #formatDate
 */
