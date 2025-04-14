//
//  EnumCaseName.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 15.12.2024.
//

@_silgen_name("swift_EnumCaseName")
fileprivate func _swift_getEnumCaseName<T>(_ value: T) -> UnsafePointer<CChar>?

/// Returns the case name of enum.
/// https://forums.swift.org/t/getting-the-name-of-a-swift-enum-value/35654/17
@_spi(SwiftyKitBuiltinFuncs)
public func _getEnumCaseName<T>(for value: T) -> String? {
  guard let stringPtr = _swift_getEnumCaseName(value) else { return nil }
  return String(validatingCString: stringPtr)
}

/// Возвращает название кейса енама вместе с названием параметров и их Типами.
/// Например, для case baz(val: Int, String) вернёт строку "baz(val: Int, String)"
///
/// Warning: will not work properly if reflection is disabled in build settings.
@_spi(SwiftyKitBuiltinFuncs) @_unavailableInEmbedded
public func _getEnumSignature<T>(value: T) -> String { // TODO: - remove reflection
  let reflection = Mirror(reflecting: value)
  let children = reflection.children
  guard !children.isEmpty else { return _getEnumCaseName(for: value) ?? "" }
  
  var signature = ""
  
  // у енамов тут 1 элемент если есть associated values, в ином случае пустой массив
  for case let item in children {
    // Обычно параметры кейса енама имеют displayStyle равный .tuple. Но так бывает не всегда. Например, если параметром
    // кейса енама будет функция, вроде case foo((Double, Double) -> Double), то displayStyle равен nil.
    let shouldSurroundWithBraces = (Mirror(reflecting: item.value).displayStyle != .tuple)
    let caseName = (item.label ?? "_") // название кейса
    let argsTypeDescr = String(describing: type(of: item.value))
    // Если с case'ом связан не кортеж параметров, а что-то иное, добавляем скобки
    let args = shouldSurroundWithBraces ? "(" + argsTypeDescr + ")" : argsTypeDescr
    signature += (caseName + args)
  }
  
  return signature
}
