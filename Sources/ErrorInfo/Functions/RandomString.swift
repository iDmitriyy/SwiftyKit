//
//  RandomString.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 28/07/2025.
//

private import FoundationExtensions
private import NonEmpty
private import StdLibExtensions

// MARK: Random Suffix

private let randomStringCharctersSource =
  String.englishAlphabetUppercasedString + String.englishAlphabetLowercasedString + String.arabicNumeralsString

extension ErrorInfoFuncs {
  internal static func randomSuffix() -> String {
    randomAlphaNumericString(count: 3)
  }
  
  internal static func randomAlphaNumericString(count: Int) -> String {
    let count = count.boundedWith(1, .max)
    var result = String(minimumCapacity: count)
    for _ in 0..<count {
      // calling randomStringCharctersSource.randomElement() 3 times causes situation where a duplicated string
      // most often created in range of 200-1000 calls, while there are 46,656 combinations.
      // This ought to be be improved to a variant where duplicate is created after ~ 5_000 calls in average
      result.append(randomStringCharctersSource.randomElement())
    }
    return result
  }
}
