//
//  FileIDComponents.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 30.12.2024.
//

// MARK: - FileID components extraction

// MARK: StaticString

public func extractModuleName(fromFileID fileID: StaticString) -> String {
  _componentFrom(fileID: fileID, makeComponent: { staticStringBuffer, lastSlashIndex in
    _componentBeforeSlash(fileIDBytes: staticStringBuffer, lastSlashIndex: lastSlashIndex)
  }, ifNoSlashFoundReturn: { _ in
    ""
  })
}

public func extractFileName(fromFileID fileID: StaticString) -> String {
  _componentFrom(fileID: fileID, makeComponent: { staticStringBuffer, lastSlashIndex in
    _componentAfterSlash(fileIDBytes: staticStringBuffer, lastSlashIndex: lastSlashIndex)
  }, ifNoSlashFoundReturn: { sourceStringBuffer in
    String(decoding: sourceStringBuffer, as: UTF8.self)
  })
}

// MARK: String

public func extractModuleName(fromFileID fileID: String) -> String {
  _componentFrom(fileID: fileID, makeComponent: { utf8View, lastSlashIndex in
    _componentBeforeSlash(fileIDBytes: utf8View, lastSlashIndex: lastSlashIndex)
  }, ifNoSlashFoundReturn: { _ in
    ""
  })
}

public func extractFileName(fromFileID fileID: String) -> String {
  _componentFrom(fileID: fileID, makeComponent: { utf8View, lastSlashIndex in
    _componentAfterSlash(fileIDBytes: utf8View, lastSlashIndex: lastSlashIndex)
  }, ifNoSlashFoundReturn: { sourceStringUTF8 in
    String(decoding: sourceStringUTF8, as: UTF8.self)
  })
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - decomposition & reuse

// MARK: FileID Component

@inline(__always)
fileprivate func _componentBeforeSlash<Buffer>(fileIDBytes: Buffer,
                                               lastSlashIndex: Buffer.Index)
  -> String where Buffer: BidirectionalCollection, Buffer.Element == UTF8.CodeUnit {
  let range = ..<lastSlashIndex
  let bytesBeforeSlash = fileIDBytes[range]
  return String(decoding: bytesBeforeSlash, as: UTF8.self)
}

@inline(__always)
fileprivate func _componentAfterSlash<Buffer>(fileIDBytes: Buffer,
                                              lastSlashIndex: Buffer.Index)
  -> String where Buffer: BidirectionalCollection, Buffer.Element == UTF8.CodeUnit {
  let range = fileIDBytes.index(after: lastSlashIndex)...
  let bytesAfterSlash = fileIDBytes[range]
  return String(decoding: bytesAfterSlash, as: UTF8.self)
}

// MARK: Slash Index Search

@inline(__always)
fileprivate func _componentFrom(fileID staticString: StaticString,
                                makeComponent: (UnsafeBufferPointer<UInt8>, UnsafeBufferPointer<UInt8>.Index) -> String,
                                ifNoSlashFoundReturn fallback: (UnsafeBufferPointer<UInt8>) -> String) -> String {
  __componentFrom(fileID: staticString,
                  getBytes: StaticString.withUTF8Buffer,
                  makeComponent: makeComponent,
                  ifNoSlashFoundReturn: fallback)
}

@inline(__always)
fileprivate func _componentFrom(fileID string: String,
                                makeComponent: (String.UTF8View, String.UTF8View.Index) -> String,
                                ifNoSlashFoundReturn fallback: (String.UTF8View) -> String) -> String {
  // `withUTF8View` is weird way to  pass `string.utf8` view
  // It is done because there are differences in accessing utf8 bytes for StaticString and String:
  // StaticString provide access to bytes via `withUTF8Buffer {}` closure
  // String has .utf8 property
  let withUTF8View: (String) -> (((String.UTF8View) -> String) -> String) = { string in
    { builder in builder(string.utf8) }
  }
  
  // ⚠️ @iDmitriyy
  // TODO: - benchmark utf8 buffer instead of utf8 view
  // if buffer avvailabloe then use it, else use utf8 view
//  string.withContiguousUTF8 { bufer in }
  
  return __componentFrom(fileID: string,
                         getBytes: withUTF8View,
                         makeComponent: makeComponent,
                         ifNoSlashFoundReturn: fallback)
}

/// Reusable function for searching slash `index`.
/// Reusing of this code guarantee that slash search algorithm is the same for both `fileName` and `moduleName` extraction functions,
/// because `fileName` and `moduleName` are mutualy exclusive parts of `fileID`.
@inline(__always)
fileprivate func __componentFrom<S, Buffer>(fileID string: S,
                                            getBytes: (S) -> (((Buffer) -> String) -> String),
                                            makeComponent: (Buffer, Buffer.Index) -> String,
                                            ifNoSlashFoundReturn fallback: (Buffer) -> String) -> String
  where S: CustomStringConvertible, Buffer: BidirectionalCollection, Buffer.Element == UTF8.CodeUnit {
  // TODO: - replace getBytes: (S) -> (((Buffer) -> String) -> String) with Span in Swift 6.2
  let getBytesBufferFunc = getBytes(string)
  let result = getBytesBufferFunc { utf8Bytes in
    if let lastSlashIndex = utf8Bytes.lastIndex(of: 47) {
      makeComponent(utf8Bytes, lastSlashIndex)
    } else {
      fallback(utf8Bytes)
    }
  }
  return result
}
