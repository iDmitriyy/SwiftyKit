//
//  RandomSuffix.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 28/07/2025.
//

private import FoundationExtensions
private import NonEmpty

// MARK: Random Suffix

extension ErrorInfoFunctions {
  internal static func randomSuffix() -> String {
    var result = ""
    result.reserveCapacity(3)
    result.append(String.englishAlphabetUppercasedString.randomElement())
    result.append(String.englishAlphabetUppercasedString.randomElement())
    result.append(String(describing: UInt.random(in: 0...9)))
    return result
  }
}
