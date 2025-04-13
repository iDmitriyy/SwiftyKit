//
//  FileLineTests.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 28.12.2024.
//

@testable import IndependentDeclarations
import Testing

struct FileLineTests {
  /*
   При запуске из скрипта какой будет #fileID ? Название модуля будет?
   */
  
  @Test func validInput() throws {
//    var invalidCharacters = CharacterSet(charactersIn: ":/")
//    invalidCharacters.formUnion(.newlines)
//    invalidCharacters.formUnion(.illegalCharacters)
//    invalidCharacters.formUnion(.controlCharacters)
    
    let fileID: StaticString = #fileID
    let filePath: StaticString = #filePath
    
    let fileIDs: [(fileID: StaticString, expected: (module: String, file: String))] = [
      ("longString_moduleName/longString_file.swift", ("longString_moduleName", "longString_file.swift")),
      ("moduleName/file.swift", ("moduleName", "file.swift")),
      ("moduleName/.swift", ("moduleName", ".swift")),
      ("A/B", ("A", "B")),
      (" / ", (" ", " ")),
      ("👍🏽/🎁", ("👍🏽", "🎁")),
    ]
    // + unioned scalars
    // + 47 scalars
    
    for (fileID, expected) in fileIDs { // test StaticString functions
      let fileID: StaticString = fileID
      let moduleName = extractModuleName(fromFileID: fileID)
      let fileName = extractFileName(fromFileID: fileID)
      #expect((moduleName, fileName) == expected)
    }
    
    for (fileID, expected) in fileIDs { // test String functions
      let fileID: String = String(fileID)
      let moduleName = extractModuleName(fromFileID: fileID)
      let fileName = extractFileName(fromFileID: fileID)
      #expect((moduleName, fileName) == expected)
    }
    
    print(fileID)
  }
  
  @Test func invalidInput() throws {
    let invalidFileIDs: [(fileID: StaticString, expected: (module: String, file: String))] = [
      ("/Users/userName/foo/bar/file.swift", ("/Users/userName/foo/bar", "file.swift")), // test for filePath
      ("file.swift", ("", "file.swift")),
      ("/file.swift", ("", "file.swift")),
      (".swift", ("", ".swift")),
      
      ("", ("", "")),
      (" ", ("", " ")),
      (".", ("", ".")),
      ("A", ("", "A")),
      
      ("/", ("", "")),
      ("//", ("/", "")),
      ("///", ("//", "")),
      ("/A/B/C", ("/A/B", "C")),
      ("A/B/C/D", ("A/B/C", "D")),
    ]
    
    for (fileID, expected) in invalidFileIDs { // test StaticString functions
      let fileID: StaticString = fileID
      let moduleName = extractModuleName(fromFileID: fileID)
      let fileName = extractFileName(fromFileID: fileID)
      #expect((moduleName, fileName) == expected)
    }
    
    for (fileID, expected) in invalidFileIDs { // test String functions
      let fileID: String = String(fileID)
      let moduleName = extractModuleName(fromFileID: fileID)
      let fileName = extractFileName(fromFileID: fileID)
      #expect((moduleName, fileName) == expected)
    }
  }
  
  // TODO: - imp
//  @Test func binaryStringDescr() {
//    #expect(Int.min.stringifiedBits == String(Int.min, radix: 2))
//    #expect(Int.max.stringifiedBits == String(Int.max, radix: 2))
//  }
}

// FIXME: - non-generic imp has ~= same speed as generic
// instead of full non-generic implementation can compare to smth similar

private func extractModuleName_ref(fileID staticString: StaticString) -> String {
  staticString.withUTF8Buffer { buffer in
    let slashValue: UInt8 = 47
    if let lastSlashIndex = buffer.lastIndex(of: slashValue) {
      let range = buffer.index(after: lastSlashIndex)...
      let bytes = buffer[range]
      let string = String(decoding: bytes, as: UTF8.self)
      return string
    } else {
      return String(decoding: buffer, as: UTF8.self)
    }
  }
}

private func extractFileName_ref(fileID staticString: StaticString) -> String {
  staticString.withUTF8Buffer { buffer in
    let slashValue: UInt8 = 47
    if let lastSlashIndex = buffer.lastIndex(of: slashValue) {
      let range = ..<lastSlashIndex
      let bytes = buffer[range]
      let string = String(decoding: bytes, as: UTF8.self)
      return string
    } else {
      return ""
    }
  }
}
