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

private let alphaNumericCharctersString =
  String.englishAlphabetUppercasedString + String.englishAlphabetLowercasedString + String.arabicNumeralsString

private let lowerCaseAsciiRange: ClosedRange<UInt8> = 97...122
private let upperCaseAsciiRange: ClosedRange<UInt8> = 65...90
private let numericAsciiRange: ClosedRange<UInt8> = 48...57

private let alphaNumericAsciiSet: Set<UInt8> = mutate(value: Set<UInt8>()) {
  $0.formUnion(lowerCaseAsciiRange)
  $0.formUnion(upperCaseAsciiRange)
  $0.formUnion(numericAsciiRange)
}

private let allPrintableNoWhitespaceAsciiRange: Set<UInt8> = mutate(value: Set<UInt8>()) {
  $0.formUnion(33...126)
  $0.remove(35) // #
  $0.remove(36) // $
  $0.remove(45) // -
  $0.remove(47) // /
  $0.remove(92) // \
  $0.remove(95) // _
}

extension ErrorInfoFuncs {
  internal static func randomSuffix() -> String {
    // calling alphaNumericCharctersString.randomElement() 3 times causes situation where a duplicated string
    // most often created in range of 200-1000 calls, while there are 46,656 combinations.
    // This ought to be be improved to a variant where duplicate is created after ~ 5_000 calls in average
    return randomPrintableAsciiCharsString(count: 4) // 11,451,456 combinations , duplicate stistically created after several thousands
  }
  
  ///
  /// Ascii codes in range 33...126 – all printable symbols except space.
  private static func randomPrintableAsciiCharsString(count: Int) -> String {
    let count = count.boundedWith(1, .max)
    
    var result = String(minimumCapacity: count)
    for index in 0..<count {
      let randomAsciiNumber: UInt8
      if index == 0 || index == count - 1 {
        randomAsciiNumber = alphaNumericAsciiSet.randomElement()!
      } else {
        randomAsciiNumber = allPrintableNoWhitespaceAsciiRange.randomElement()!
      }
      
      result.append(Character(UnicodeScalar(randomAsciiNumber)))
    }
    return result
  }
  
//  internal static func randomAlphaNumericString(count: Int) -> String {
//    let count = count.boundedWith(1, .max)
//    var result = String(minimumCapacity: count)
//    for _ in 0..<count {
//      // calling randomStringCharctersSource.randomElement() 3 times causes situation where a duplicated string
//      // most often created in range of 200-1000 calls, while there are 46,656 combinations.
//      // This ought to be be improved to a variant where duplicate is created after ~ 5_000 calls in average
//      result.append(randomStringCharctersSource.randomElement())
//    }
//    return result
//  }
}
