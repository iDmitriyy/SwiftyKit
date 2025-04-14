//
//  EnumCaseNameTests.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 15.12.2024.
//

import Testing
@testable import Functions

struct EnumCaseNameTests {
  // swiftlint:disable duplicate_enum_cases
  private enum TestEnum {
    case bar
    case bar2(value: Int)
    case bar2(val: String)
    case baz(val: Int, String)
    case baz(val: UInt, bal: (String, ty: Double))
    case foo((Double, Double) -> Double)
    case foo2(function: (Double, Double) -> Double)
    case arrayCase([Double])
    case dictCase(dict: [String: Double])
  }
  
  private let enumInstances: [TestEnum] = [
    TestEnum.bar,
    TestEnum.bar2(value: 2),
    TestEnum.bar2(val: "bar2"),
    TestEnum.baz(val: 3, "baz3"),
    TestEnum.baz(val: 4, bal: ("bal", ty: 4)),
    TestEnum.foo(max),
    TestEnum.foo2(function: max),
    TestEnum.arrayCase([]),
    TestEnum.dictCase(dict: [:]),
  ]
  
  @Test func getSignatures() {
    let signatures: [String] = [
      "bar",
      "bar2(value: Int)",
      "bar2(val: String)",
      "baz(val: Int, String)",
      "baz(val: UInt, bal: (String, ty: Double))",
      "foo((Double, Double) -> Double)",
      "foo2(function: (Double, Double) -> Double)",
      "arrayCase(Array<Double>)",
      "dictCase(dict: Dictionary<String, Double>)",
    ]
    
    let computedSignatures = enumInstances.map { _getEnumSignature(value: $0) }
    
    #expect(signatures == computedSignatures,
                   "Описание название кейса, его параметров или их Типа не совпадает с тем, как написано в исходниках")
  }
  
  @Test func getNames() {
    let names: [String] = [
      "bar",
      "bar2",
      "bar2",
      "baz",
      "baz",
      "foo",
      "foo2",
      "arrayCase",
      "dictCase",
    ]
    
    let computedNames = enumInstances.map { _getEnumCaseName(for: $0) }
    
    #expect(names == computedNames, "Название кейса енама некорректное")
  }
}

struct EnumSignatureTests {
  private enum TestEnum {
    case caseWithoutAssociatedValues
    case caseWithAssociatedValues(Int, String, Double)
  }
  
  @Test func getEnumSignature_caseWithoutAssociatedValues() {
    let value = TestEnum.caseWithoutAssociatedValues
    let signature = _getEnumSignature(value: value)
    #expect(signature == "caseWithoutAssociatedValues")
  }
  
  @Test func getEnumSignature_caseWithAssociatedValues() {
    let value = TestEnum.caseWithAssociatedValues(10, "Test", 5.5)
    let signature = _getEnumSignature(value: value)
    #expect(signature == "caseWithAssociatedValues(Int, String, Double)")
  }
  
  @Test func getEnumSignature_caseWithFunction() {
    enum TestEnum {
      case caseWithFunction((Double, Double) -> Double)
    }
    let value = TestEnum.caseWithFunction { (a: Double, b: Double) -> Double in
      a + b
    }
    let signature = _getEnumSignature(value: value)
    #expect(signature == "caseWithFunction((Double, Double) -> Double)")
  }
  
  @Test func getEnumSignature_caseWithNilDisplayStyle() {
    enum TestEnum {
      case caseWithOptionalFunc(func: ((Double, Double) -> Double)?)
      case caseWithFuncOptionalReturn(((Double, Double) -> Double?))
      case caseWithOptionalFuncOptionalReturn(((Double, Double) -> Double?)?)
    }
    let caseWithOptionalFunc = TestEnum.caseWithOptionalFunc(func: nil)
    let caseWithFuncOptionalReturn = TestEnum.caseWithFuncOptionalReturn({ _, _ in nil })
    let caseWithOptionalFuncOptionalReturn = TestEnum.caseWithOptionalFuncOptionalReturn(nil)
    
    #expect(_getEnumSignature(value: caseWithOptionalFunc) ==
                   "caseWithOptionalFunc(func: Optional<(Double, Double) -> Double>)")
    #expect(_getEnumSignature(value: caseWithFuncOptionalReturn) ==
                   "caseWithFuncOptionalReturn((Double, Double) -> Optional<Double>)")
    #expect(_getEnumSignature(value: caseWithOptionalFuncOptionalReturn) ==
                   "caseWithOptionalFuncOptionalReturn(Optional<(Double, Double) -> Optional<Double>>)")
  }
}
