//
//  _TestProto.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 08/08/2025.
//

func testProto(info: inout some ErrorInfoPrototype<String, any ErrorInfoValueType>) {
  info.addIfNotNil(3, key: "")
}

func errrrfff<K: Hashable, V>(errorInfo: some IterableErrorInfo<K, V>) {
  var count = 0
  for (key, value) in errorInfo {
    count += 1
  }
}

func ddwfsd<K: Hashable, V>(errorInfo: some Sequence<(key: K, value: V)>) {
//  seq.lazy
//  seq.enumerated()
  errorInfo.allSatisfy { e in true }
  errorInfo.map { $0 }
  errorInfo.first(where: { _ in true })
  errorInfo.count(where: { _ in true })
  errorInfo.underestimatedCount
  errorInfo.forEach { _ in }
  errorInfo.compactMap { $0 }
  errorInfo.contains(where: { _ in true})
  errorInfo.flatMap { $0 }
  errorInfo.reduce(into: Dictionary<K, V>()) { partialResult, e in
    partialResult[e.key] = e.value
  }
//  errorInfo.sorted { $0.key < $1.key }
  errorInfo.dropFirst()
  errorInfo.dropLast()
  errorInfo.filter { _ in true }
  //  errorInfo.max(by: T##((key: Hashable, value: V), (key: Hashable, value: V)) throws -> Bool)
  errorInfo.prefix(1)
  errorInfo.suffix(1)
  errorInfo.reversed()
  errorInfo.shuffled()
}
