//
//  UnorderedErrorInfo.swift
//  swifty-kit
//
//  Created by tmp on 26/07/2025.
//

/// [String: Any] || Unordered Type has one benefit prior to Ordered / Sorted Dictionary – keys have different order.
/// if logging system has strong limit on number of key-value pairs can be logged and drops ones that out of limit, it is not so big problem when keys have different order.
/// Each log in such situation will have different key-value pairs,  though not full. From this mosaic a valuable picture of problem can be restored.
fileprivate struct UnorderedErrorInfo {}
