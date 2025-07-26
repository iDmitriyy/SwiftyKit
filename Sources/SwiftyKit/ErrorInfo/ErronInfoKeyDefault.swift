//
//  ErronInfoKeyDefault.swift
//  swifty-kit
//
//  Created by tmp on 26/07/2025.
//

extension ErronInfoKey {
  // By default names are given with snake_case, which can ba transformed to camelCase, kebab-case or PascalCase
  // formats when logging.
  // TODO: - inspet Swift codebases for styles
  
  public static let id = ErronInfoKey(uncheckedString: "id")
  public static let instanceID = ErronInfoKey(uncheckedString: "instance_id")
  public static let objectID = ErronInfoKey(uncheckedString: "object_id")
  
  public static let status = ErronInfoKey(uncheckedString: "status")
  public static let statusID = ErronInfoKey(uncheckedString: "status_id")
  public static let rawStatus = ErronInfoKey(uncheckedString: "raw_status")
  
  public static let state = ErronInfoKey(uncheckedString: "state")
  public static let invalidState = ErronInfoKey(uncheckedString: "invalid_state")
  public static let unexpectedState = ErronInfoKey(uncheckedString: "unexpected_state")
  public static let sourceState = ErronInfoKey(uncheckedString: "source_state")
  public static let targetState = ErronInfoKey(uncheckedString: "target_state")
  
  public static let value = ErronInfoKey(uncheckedString: "value")
  public static let rawValue = ErronInfoKey(uncheckedString: "raw_value")
  public static let stringValue = ErronInfoKey(uncheckedString: "string_value")
  public static let uncheckedValue = ErronInfoKey(uncheckedString: "unchecked_value")
  public static let instance = ErronInfoKey(uncheckedString: "instance")
  public static let object = ErronInfoKey(uncheckedString: "object")
  
  public static let requestURL = ErronInfoKey(uncheckedString: "request_url")
  public static let responseURL = ErronInfoKey(uncheckedString: "response_url")
  public static let responseData = ErronInfoKey(uncheckedString: "response_data")
  public static let responseJson = ErronInfoKey(uncheckedString: "response_json")
  public static let dataString = ErronInfoKey(uncheckedString: "data_string")
  public static let dataBytesCount = ErronInfoKey(uncheckedString: "data_bytes_count")
  
  public static let index = ErronInfoKey(uncheckedString: "index")
  public static let indices = ErronInfoKey(uncheckedString: "indices")
  
  public static let errorCode = ErronInfoKey(uncheckedString: "error_code")
  public static let errorDomain = ErronInfoKey(uncheckedString: "error_domain")
  
  public static let file = ErronInfoKey(uncheckedString: "file")
  public static let line = ErronInfoKey(uncheckedString: "line")
  public static let fileLine = ErronInfoKey(uncheckedString: "file_line")
  public static let function = ErronInfoKey(uncheckedString: "function")
  
  public static let message = ErronInfoKey(uncheckedString: "message")
  public static let debugMessage = ErronInfoKey(uncheckedString: "debug_message")
  public static let description = ErronInfoKey(uncheckedString: "description")
  public static let debugDescription = ErronInfoKey(uncheckedString: "debug_description")
}
