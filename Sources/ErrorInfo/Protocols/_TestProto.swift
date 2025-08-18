//
//  _TestProto.swift
//  swifty-kit
//
//  Created by tmp on 08/08/2025.
//

func testProto(info: inout some ErrorInfoPrototype<String, any ErrorInfoValueType>) {
  info.addIfNotNil(optionalValue: 3, key: "")
  
}
