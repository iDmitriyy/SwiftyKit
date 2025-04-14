//
//  PrettyDescriptionTests.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 14.12.2024.
//

import Testing
@testable import IndependentDeclarations

struct PrettyDescriptionTests {
  private let assertMessage = "Invalid output"
  
  @Test func testPrettyDescriptionForString() {
    let input = "Hello World"
    #expect(prettyDescription(any: input) == input)
  }
  
  @Test func testPrettyDescriptionForOptionalString() {
    let input: String? = "Hello World"
    let expectedOutput = "Hello World"
    #expect(prettyDescription(any: input) == expectedOutput)
  }
  
  @Test func testPrettyDescriptionForNonOptionalLiteral() {
    let expectedOutput = "10"
    #expect(prettyDescription(any: 10) == expectedOutput)
  }
  
  @Test func testCustomStringConvertible() throws {
    let val1: Int = 1
    let expectedOutput = "1"
    
    #expect(prettyDescription(any: val1) == expectedOutput)
    
    do {
      let val1Any: Any = val1 as Any
      #expect(prettyDescription(any: val1Any) == expectedOutput)
    }
  }
  
  @Test func testCustomStringConvertibleOptionalWithNil() throws {
    let singleOptVal: Int? = nil
    let doubleOptVal: Int?? = nil
    let tripleOptVal: Int??? = nil
    
    let expectedOutput = "nil"
    
    #expect(String(describing: singleOptVal) == expectedOutput)
    #expect(String(describing: doubleOptVal) == expectedOutput)
    #expect(String(describing: tripleOptVal) == expectedOutput)
    
    #expect(prettyDescription(any: singleOptVal) == expectedOutput)
    #expect(prettyDescription(any: doubleOptVal) == expectedOutput)
    #expect(prettyDescription(any: tripleOptVal) == expectedOutput)
    
    do {
      let singleOptAny: Any = singleOptVal as Any
      let doubleOptAny: Any = doubleOptVal as Any
      let tripleOptAny: Any = tripleOptVal as Any
      
      #expect(prettyDescription(any: singleOptAny) == expectedOutput)
      #expect(prettyDescription(any: doubleOptAny) == expectedOutput)
      #expect(prettyDescription(any: tripleOptAny) == expectedOutput)
      
      let singleOptAnyAny: Any = (Optional.some(singleOptAny) as Any)
      let doubleOptAnyAny: Any = (Optional.some(doubleOptAny) as Any)
      let tripleOptAnyAny: Any = (Optional.some(tripleOptAny) as Any)
      
      #expect(prettyDescription(any: singleOptAnyAny) == expectedOutput)
      #expect(prettyDescription(any: doubleOptAnyAny) == expectedOutput)
      #expect(prettyDescription(any: tripleOptAnyAny) == expectedOutput)
      
      let singleOptOptAnyAny: Any? = (Optional.some(singleOptAny) as Any)
      let doubleOptOptAnyAny: Any? = (Optional.some(doubleOptAny) as Any)
      let tripleOptOptAnyAny: Any? = (Optional.some(tripleOptAny) as Any)
      
      #expect(prettyDescription(any: singleOptOptAnyAny) == expectedOutput)
      #expect(prettyDescription(any: doubleOptOptAnyAny) == expectedOutput)
      #expect(prettyDescription(any: tripleOptOptAnyAny) == expectedOutput)
    }
  }
  
  // ⚠️ @iDmitriyy
  // FIXME: - testCustomStringConvertibleOptionalWithNil | testCustomStringConvertibleOptionalWithWrappedInt
  // code duplicated, can be rewritten as generic. The on;y differemce in them is expectedOutput – nil or 1,2,3
  
  @Test func testCustomStringConvertibleOptionalWithWrappedInt() throws {
    let singleOptVal: Int? = 1
    let doubleOptVal: Int?? = 2
    let tripleOptVal: Int??? = 3
    
    #expect(String(describing: singleOptVal) == "Optional(1)")
    #expect(String(describing: doubleOptVal) == "Optional(Optional(2))")
    #expect(String(describing: tripleOptVal) == "Optional(Optional(Optional(3)))")
    
    #expect(prettyDescription(any: singleOptVal) == "1")
    #expect(prettyDescription(any: doubleOptVal) == "2")
    #expect(prettyDescription(any: tripleOptVal) == "3")
    
    do {
      let singleOptAny: Any = singleOptVal as Any
      let doubleOptAny: Any = doubleOptVal as Any
      let tripleOptAny: Any = tripleOptVal as Any
      
      #expect(prettyDescription(any: singleOptAny) == "1")
      #expect(prettyDescription(any: doubleOptAny) == "2")
      #expect(prettyDescription(any: tripleOptAny) == "3")
      
      let singleOptAnyAny: Any = (Optional.some(singleOptAny) as Any)
      let doubleOptAnyAny: Any = (Optional.some(doubleOptAny) as Any)
      let tripleOptAnyAny: Any = (Optional.some(tripleOptAny) as Any)
      
      #expect(prettyDescription(any: singleOptAnyAny) == "1")
      #expect(prettyDescription(any: doubleOptAnyAny) == "2")
      #expect(prettyDescription(any: tripleOptAnyAny) == "3")
      
      let singleOptOptAnyAny: Any? = (Optional.some(singleOptAny) as Any)
      let doubleOptOptAnyAny: Any? = (Optional.some(doubleOptAny) as Any)
      let tripleOptOptAnyAny: Any? = (Optional.some(tripleOptAny) as Any)
      
      #expect(prettyDescription(any: singleOptOptAnyAny) == "1")
      #expect(prettyDescription(any: doubleOptOptAnyAny) == "2")
      #expect(prettyDescription(any: tripleOptOptAnyAny) == "3")
    }
  }
  
  @Test func testNotCustomStringConvertible() throws {
    let val1: NotCustomStringConvertibleStruct = NotCustomStringConvertibleStruct(id: 1, name: "Name")
    
    #expect(String(describing: val1) == #"NotCustomStringConvertibleStruct(id: 1, name: Optional("Name"))"#)
    #expect(prettyDescription(any: val1) == #"NotCustomStringConvertibleStruct(id: 1, name: Optional("Name"))"#)
    
    do {
      let singleOptAny: Any = val1 as Any
      #expect(prettyDescription(any: singleOptAny) == #"NotCustomStringConvertibleStruct(id: 1, name: Optional("Name"))"#)
    }
  }
  
  @Test func testNotCustomStringConvertibleOptionalWrapped() throws {
    let singleOptVal: NotCustomStringConvertibleStruct? = NotCustomStringConvertibleStruct(id: 1, name: "Name")
    let doubleOptVal: NotCustomStringConvertibleStruct?? = NotCustomStringConvertibleStruct(id: 2, name: "Name")
    let tripleOptVal: NotCustomStringConvertibleStruct??? = NotCustomStringConvertibleStruct(id: 3, name: "Name")
    
    // У Типа, обёрнутого в Optional, и при этом не конформящего CustomStringConvertible, при преобразовании в строку получаем
    // "Optional(StdToolsTests.PrettyDescriptionTests.(unknown context at $11144b83c).SomeStruct(id: 1, name: "Name"))"
    // вместо "Optional(SomeStruct(id: 1, name: "Name"))"
    // https://bugs.swift.org/browse/SR-6787?page=com.atlassian.jira.plugin.system.issuetabpanels%3Acomment-tabpanel&showAll=true
    
//    XCTAssertEqual(String(describing: singleOptVal),
//                   #"NotCustomStringConvertibleStruct(SomeStruct(id: 1, name: "Name"))"#,
//                   assertMessage)
//    XCTAssertEqual(String(describing: doubleOptVal),
//                   #"NotCustomStringConvertibleStruct(SomeStruct(id: 2, name: "Name"))"#,
//                   assertMessage)
//    XCTAssertEqual(String(describing: tripleOptVal),
//                   #"NotCustomStringConvertibleStruct(SomeStruct(id: 3, name: "Name"))"#,
//                   assertMessage)
    
    // Поэтому проверяем чуть иначе: вместо XCTAssertEqual проверяем что строка не содержит Optional и содержит
    // данные структуры
    do {
      let singleOptValString = prettyDescription(any: singleOptVal)
      #expect(!singleOptValString.contains("Optional")
        && singleOptValString.contains(#"NotCustomStringConvertibleStruct(id: 1, name: "Name")"#))
      
      let doubleOptValString = prettyDescription(any: doubleOptVal)
      #expect(!doubleOptValString.contains("Optional")
        && doubleOptValString.contains(#"NotCustomStringConvertibleStruct(id: 2, name: "Name")"#))
      
      let tripleOptValString = prettyDescription(any: tripleOptVal)
      #expect(!tripleOptValString.contains("Optional")
        && tripleOptValString.contains(#"NotCustomStringConvertibleStruct(id: 3, name: "Name")"#))
    }

    do {
      let singleOptAny: Any = singleOptVal as Any
      let doubleOptAny: Any = doubleOptVal as Any
      let tripleOptAny: Any = tripleOptVal as Any

      let singleOptAnyString = prettyDescription(any: singleOptAny)
      #expect(!singleOptAnyString.contains("Optional")
        && singleOptAnyString.contains(#"NotCustomStringConvertibleStruct(id: 1, name: "Name")"#))
      
      let doubleOptAnyString = prettyDescription(any: doubleOptAny)
      #expect(!doubleOptAnyString.contains("Optional")
        && doubleOptAnyString.contains(#"NotCustomStringConvertibleStruct(id: 2, name: "Name")"#))
      
      let tripleOptAnyString = prettyDescription(any: tripleOptAny)
      #expect(!tripleOptAnyString.contains("Optional")
        && tripleOptAnyString.contains(#"NotCustomStringConvertibleStruct(id: 3, name: "Name")"#))
    }
  }
  
  @Test func testNotCustomStringConvertibleOptionalNil() throws {
    let singleOptVal: NotCustomStringConvertibleStruct? = nil
    let doubleOptVal: NotCustomStringConvertibleStruct?? = nil
    let tripleOptVal: NotCustomStringConvertibleStruct??? = nil
    
    let expectedOutput = "nil"
    do {
      #expect(prettyDescription(any: singleOptVal) == expectedOutput)
      #expect(prettyDescription(any: doubleOptVal) == expectedOutput)
      #expect(prettyDescription(any: tripleOptVal) == expectedOutput)
    }

    do {
      let singleOptAny: Any = singleOptVal as Any
      let doubleOptAny: Any = doubleOptVal as Any
      let tripleOptAny: Any = tripleOptVal as Any

      #expect(prettyDescription(any: singleOptAny) == expectedOutput)
      #expect(prettyDescription(any: doubleOptAny) == expectedOutput)
      #expect(prettyDescription(any: tripleOptAny) == expectedOutput)
      
      let singleOptAnyAny: Any = (Optional.some(singleOptAny) as Any)
      let doubleOptAnyAny: Any = (Optional.some(doubleOptAny) as Any)
      let tripleOptAnyAny: Any = (Optional.some(tripleOptAny) as Any)
      
      #expect(prettyDescription(any: singleOptAnyAny) == expectedOutput)
      #expect(prettyDescription(any: doubleOptAnyAny) == expectedOutput)
      #expect(prettyDescription(any: tripleOptAnyAny) == expectedOutput)
    }
  }
  
  @Test func testPrettyDescriptionForCustomDescription() {
    struct CustomStringConvertibleStruct: CustomStringConvertible {
      var description: String { "Custom Description" }
    }
    
    let val = CustomStringConvertibleStruct()
    let singleOptVal: CustomStringConvertibleStruct? = val
    let doubleOptVal: CustomStringConvertibleStruct?? = val
    let tripleOptVal: CustomStringConvertibleStruct??? = val
    
    let expectedOutput = "Custom Description"
    #expect(prettyDescription(any: val) == expectedOutput)
    #expect(prettyDescription(any: singleOptVal) == expectedOutput)
    #expect(prettyDescription(any: doubleOptVal) == expectedOutput)
    #expect(prettyDescription(any: tripleOptVal) == expectedOutput)
    
    #expect(prettyDescription(any: val as Any) == expectedOutput)
    #expect(prettyDescription(any: singleOptVal as Any) == expectedOutput)
    #expect(prettyDescription(any: doubleOptVal as Any) == expectedOutput)
    #expect(prettyDescription(any: tripleOptVal as Any) == expectedOutput)
  }
}

/// Структура, которая не конформит CustomStringConvertible
private struct NotCustomStringConvertibleStruct {
  let id: UInt64
  let name: String?
}
