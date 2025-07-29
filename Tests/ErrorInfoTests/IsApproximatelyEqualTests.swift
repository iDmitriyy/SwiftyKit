//
//  IsApproximatelyEqualTests.swift
//  swifty-kit
//
//  Created by tmp on 29/07/2025.
//

import Foundation
@testable import ErrorInfo
import Testing

struct IsApproximatelyEqualTests {
  @Test func notEquatableObjectsEquality() throws {
    final class RefType {}
    
    let obj1 = RefType()
    let obj2 = RefType()
  }
  
  @Test func equatableObjectsEquality() throws {
    final class RefType {
      let value: Int
      init(value: Int) {
        self.value = value
      }
    }
    
    
  }
  
  @Test func equalNumbers() throws {
    ErrorInfoFunctions.isApproximatelyEqual("5", 5)
    /*
     "5" Int(5)
     Int(5) UInt(5)
     Int(5) Double(5)
     Decimal(5) Double(5)
     */
  }
  
  @Test func equatableValuesEquality() throws {
    
  }
  
  @Test func notEquatableValuesEquality() throws {
    
  }
  
  @Test func stringsEquality() throws {
    // LATIN SMALL LETTER E WITH ACUTE
    let eLatin = "\u{E9}"
    
    // LATIN SMALL LETTER E and COMBINING ACUTE ACCENT
    let eCombined = "\u{65}\u{301}"
    
    eLatin == eCombined
    eLatin._isIdentical(to: eCombined)
    
    eLatin.hash == eCombined.hash
    eLatin.hashValue == eCombined.hashValue
  }
}
