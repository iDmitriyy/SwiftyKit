//
//  _TestProto.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 08/08/2025.
//

func testProto(info: inout some ErrorInfoPrototype<String, any ErrorInfoValueType>) {
  info.addIfNotNil(3, key: "")
  
}
