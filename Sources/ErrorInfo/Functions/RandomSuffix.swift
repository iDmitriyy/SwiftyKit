//
//  RandomSuffix.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 28/07/2025.
//

private import FoundationExtensions
private import NonEmpty

// MARK: Random Suffix

private let randomStringCharctersSource =
  String.englishAlphabetUppercasedString + String.englishAlphabetLowercasedString + String.arabicNumeralsString

extension ErrorInfoFuncs {
  internal static func randomSuffix() -> String {
    let count = 3
    
    // calling randomStringCharctersSource.randomElement() 3 times causes situation where duplicated random string
    // most often created after 200-1000 calls, while there are 46,656 combinations.
    var result = String(minimumCapacity: count)
    for _ in 0..<count {
      result.append(randomStringCharctersSource.randomElement())
    }
    
    return result
  }
}
