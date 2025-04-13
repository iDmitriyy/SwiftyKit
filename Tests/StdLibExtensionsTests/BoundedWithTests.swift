//
//  BoundedWithTests.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 15.12.2024.
//

import Testing
@testable import StdLibExtensions

struct BoundedWithTests {
  @Test func testBounded() throws {
    // --- Normal Cases ---

    // Positive Bounds
    // Между граничными значениями
    #expect(0.001.boundedWith(0, 1) == 0.001)
    #expect(0.5.boundedWith(0, 1) == 0.5)
    #expect(0.999.boundedWith(0, 1) == 0.999)

    // Равно граничному значению
    #expect(0.0.boundedWith(0, 1) == 0)
    #expect(1.0.boundedWith(0, 1) == 1)

    // Выходит за граничные значения
    #expect((-0.001).boundedWith(0, 1) == 0)
    #expect(1.001.boundedWith(0, 1) == 1)

    // NegativeBounds
    // Между граничными значениями
    #expect((-0.5).boundedWith(-1.0, 1) == -0.5)
    #expect(0.5.boundedWith(-1.0, 1) == 0.5)

    // Равно граничному значению
    #expect((-1.0).boundedWith(-1.0, 1) == -1)
    #expect(1.0.boundedWith(-1.0, 1) == 1)

    // Выходит за граничные значения
    #expect((-1.001).boundedWith(-1.0, 1) == -1)
    #expect(1.001.boundedWith(-1.0, 1) == 1)

    // --- Corner Cases ---

    // 1. lowerBound == upperBound
    #expect(0.5.boundedWith(1, 1) == 1)
    #expect(0.5.boundedWith(0, 0) == 0)
    #expect(0.5.boundedWith(0.5, 0.5) == 0.5)
    #expect(0.5.boundedWith(-1, -1) == -1)

    // 2. rhs < lhs
    // Между граничными значениями
    #expect(0.001.boundedWith(1, 0) == 0.001)
    #expect(0.5.boundedWith(1, 0) == 0.5)
    #expect(0.999.boundedWith(1, 0) == 0.999)

    // Равно граничному значению
    #expect(0.0.boundedWith(1, 0) == 0)
    #expect(1.0.boundedWith(1, 0) == 1)

    // Выходит за граничные значения
    #expect((-0.001).boundedWith(1, 0) == 0)
    #expect(1.001.boundedWith(1, 0) == 1)

    // NegativeBounds
    // Между граничными значениями
    #expect((-0.5).boundedWith(1, -1.0) == -0.5)
    #expect(0.5.boundedWith(1, -1.0) == 0.5)

    // Равно граничному значению
    #expect((-1.0).boundedWith(1, -1.0) == -1)
    #expect(1.0.boundedWith(1, -1.0) == 1)

    // Выходит за граничные значения
    #expect((-1.001).boundedWith(1, -1.0) == -1)
    #expect(1.001.boundedWith(1, -1.0) == 1)
    
    // FIXME: - add subnormal, leastGreatest / maxGreatest, Nan, infinities, -0
    // - remove code duplication
  }
}
