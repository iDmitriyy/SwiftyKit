//
//  ColorFunctionsTests.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 29/07/2025.
//

@testable import IndependentDeclarations
import Testing

struct ColorFunctionsTests {
  @Test func rgbaUInt8_valid() throws {
    #expect(try rgbaUInt8(rgbaHexString: "#00000000") == (0, 0, 0, 0))
    #expect(try rgbaUInt8(rgbaHexString: "#01010101") == (1, 1, 1, 1))
    #expect(try rgbaUInt8(rgbaHexString: "#FFFFFFFF") == (255, 255, 255, 255))
    #expect(try rgbaUInt8(rgbaHexString: "#08102040") == (8, 16, 32, 64))
    #expect(try rgbaUInt8(rgbaHexString: "#0011AAFF") == (0, 17, 170, 255))
    
//    #expect(try argbUInt8(argbHexString: "#00000000") == (0, 0, 0, 0))
//    #expect(try argbUInt8(argbHexString: "#01010101") == (1, 1, 1, 1))
//    #expect(try argbUInt8(argbHexString: "#FFFFFFFF") == (255, 255, 255, 255))
//    #expect(try argbUInt8(argbHexString: "#08102040") == (8, 16, 32, 64))
//    #expect(try argbUInt8(argbHexString: "#0011AAFF") == (0, 17, 170, 255))
  }
}
