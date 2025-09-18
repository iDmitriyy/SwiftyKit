//
//  RandomString.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 28/07/2025.
//

private import StdLibExtensions
import NonEmpty

// MARK: Random Suffix

//private let alphaNumericCharctersString =
//  String.englishAlphabetUppercasedString + String.englishAlphabetLowercasedString + String.arabicNumeralsString

private let alphaNumericAsciiSet: Set<UInt8> = mutate(value: Set<UInt8>()) {
  $0.formUnion(97...122) // lowerCaseAsciiRange
  $0.formUnion(65...90) // upperCaseAsciiRange
  $0.formUnion(48...57) // numericAsciiRange
}

private let allPrintableNoWhitespaceAsciiSet: Set<UInt8> = mutate(value: Set<UInt8>()) {
  $0.formUnion(33...126) // all printable characters except space
  
  // remove also some others symbols, that are reserved by ErrorInfo functions or often used in error-info keys.
  // e.g. folder path path can be used as a key.
  $0.remove(ErrorInfoMerge.suffixBeginningForSubcriptAsciiCode)
  $0.remove(ErrorInfoMerge.suffixBeginningForMergeAsciiCode)
  $0.remove(45) // -
  $0.remove(47) // /
  $0.remove(92) // \
  $0.remove(95) // _
}

extension ErrorInfoFuncs {
  internal static func randomSuffix() -> NonEmptyString {
    // 11,451,456 combinations ,
    // duplicated string statistically created after several thousands for count = 4
    // for count == 3 duplicate appears in range 200-1000 calls in average
    randomPrintableAsciiCharsString(count: 4)
  }
  
  ///
  /// Ascii codes in range 33...126 – all printable symbols except space.
  private static func randomPrintableAsciiCharsString(count: Int) -> NonEmptyString {
    let count = count.boundedWith(1, .max)
        
    let zeroIndexChar = Character(UnicodeScalar(alphaNumericAsciiSet.randomElement()!))
    var result: NonEmptyString = NonEmptyString(zeroIndexChar)
    for index in 1..<count {
      let randomAsciiNumber: UInt8 = if index == 0 || index == count - 1 {
        alphaNumericAsciiSet.randomElement()!
      } else {
        // in the middle of the string extended charset is used
        allPrintableNoWhitespaceAsciiSet.randomElement()!
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
