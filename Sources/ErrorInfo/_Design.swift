//
//  _Design.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 01/08/2025.
//

/*
 Introduction:
 Error-info instances are often merged in several situatuins:
 - in a context where their content is unknown, and we don't want to inspect their content or make assumptions about it.
 In this case some merging strategy is needed to resolve key collisions.
 - in context where some assumptions can be made, e.g. when network error shown in UI, it is reasonable that some of such errors
 contain keys like "requestURL", "decodingError", "file", "line".
 - in context where content of error-info instance is fully cintrolled. Examples:
   1. Mapping of complex data structure. top-level type creates top-level info, and in info from each child is accumulated
      in top-level container. Imagine a bundle od products: info for validation of the bundle itself can be prefixed like
      "Bundle_id\(id)_keyName", and for each product like "Product\(id)_keyName". This prevent collisions for such fields
      as price. Typically the bundle and each product in it have price, name, discount etc.
   2. visitor pattern: in this case each element can add some info to visitor-owned info. In this case for each info, returned
      from each element, a prefix like element identity can be added to keys.
 
 
 Design principles:
 - Error-info instances must be able to merge.
 - Merge operation must prevent data loss. Legacy [String: Any], as a dictionary type, have merge function, but it only
 allows to choose one of two values when resolving collisions, which mostly always cause data loss, except situations when values
 were equal. If they are refernce-types, they can be equal by ==, but be different instances comparing with ===. This knowledge
 can be important.
 - As such, Error-info types must provide merging strategies to prevent data loss. Lets see to some of them (when keys collision happens):
   1. put all values to array or some other container. While it is possible, there is a lack of information from each context
     which value was.
   2. modify equal keys (one or both) to resolve collisions. Some variants:
      - add a random suffix / prefix to one of two keys
      - add `file_line` to one of or both key, so it is at least clear where Error info instance was created. As Error infos are created
        a lot in codebase, this can be bad for binary size.
        ? Inspect if binary size increases when #fileID is used many time in the same file. Does compiler create many StaticString
        or it is smart enough to create one string for each file and share it.
      - add some short version of #fileID (3 chars). This need a macro or some other kind of compile-time evaluation,
        and some sharing of this short string to prevent making lots of equal values.
     When error infos are merged in context of errors or error-chains, error domain and code can be used for resolving collision.
     Error domain and code can be used used as prefix / suffix.
 - All Error-info Types, that will be made in future, should able to be compatible with each other for merging.
 
 
 Usage / applying:
 (AnyBaseError -> AnyErrorChainable(Adapter))
 - Concrete error types can either use errorInfo with either `keyAugmentation` or `multipleValues` strategy.
 ?? Which strategy is commonly preferred.
 - When errors chain summary info is merged, if collision happens then it is good to understand from each error each value
 was. Donator index can be used if two errors have the same domain, code, identity (e.g. file shortand)
 In very rare cases when 2 errors:
    - have the same domain ("ME" – MappingError)
    - have the same code (7)
    - created in different files and short variants of these file names are equal ("MVC" – MainViewController | MapViewController)
    - created at the same line in those different files (40)
  a random donator index is added.
 Index is increasing from right to left, where most deep error is always at index 0. New codes alwas appear at the left side and
 will be at endIndex + 1
 Example: during collision resolution of 2 diferent values the following keys were created:
 "time_ME7@MVC_40_idx0"
 "time_ME7@MVC_40_idx2"
 ?? may be line can be omited and idx shpuld be used. If error identity(source specifier) is equal, mostly often it is the same
 file. So line number seems to look like a noise. This looks better:
 "time_ME7@MVC^idx0" || "time_ME7@MVC[i0]" || "time_ME7@MVC[0]"
 "time_ME7@MVC^idx1" || "time_ME7@MVC[i2]" || "time_ME7@MVC[2]"
 
  > This way the following code will add all 1000 values. In comparison, dictionary will save last value.
 ```
   for number in 1...1000 {
     errorInfo["a"] = number
   }
 ```
 However, it is not a typical situation when someone adds 1000 diferrent values for the same key.
 
 
 Hashability:
 Error-info types / implementations can technically be hashable / equatable, but it seems there are no valid reasons to do so.
 Error info instances can contain semantically equal content, but differently represented (as Integer or String for example).
 Comparing two Error-infos with exact same content seems to be wrong operation from perspective of practical usage.
 
 
 Opened equestions:
 - should all error info types itself be iterable (or iterable keyValues View should better be provided)? - For now Sequence
 is inherited by root errorInfo protocol, so all instances are iterable and conforms to Sequence.
 - should errorInfo's have `func removeValue(forKey:)`? For now not.
 - which collisison resultion strategy should be default?
 
 
 Rationale:
 While Error types are quite common, there is still no error-info type for holding payload or addtional details of error.
 For now it is typical to use [String: Any] dict, but it has several pitfals:
    - it is not Sendable and thus not concurency compatible
    - is error prone because almost everything can be put as Any
    - previous value is lost when new value is set for a given key
    - merging 2 of such dicts can cause collisions which are not easy to resolve
    - data loss due to lack of builtin merging strategies
 
 Error protocol itself inherits from Sendable, so some Sendable container is needed to hold error's info.
 General purpose Error-info types have:
  Key == String
  Value == any ErrorInfoValueType
 
 typealias ErrorInfoValueType = CustomStringConvertible & Equatable & Sendable
  
 This choice for ErrorInfoValueType addresses several important concerns:
  - Thread Safety: The Sendable requirement is essential to prevent data races and ensure safe concurrent access.
  - String Representation: Requiring CustomStringConvertible forces developers to provide meaningful string representations for stored values, which is invaluable for debugging and logging. It also prevents unexpected results when converting values to strings.
  - Collision Resolution: The Equatable requirement allows to detect and resolve collisions if different values are associated with the same key. This adds a layer of robustness.
 
 Currently the library provides 3 Error-info Types with String keys:
 - ErrorInfo (Value == any ErrorInfoValueType) uses OrderedMultiValueDictionary under the hood. It preserves values appending order which can be helpful for debugging and tracing.
 - UnorderedErrorInfo (Value == any ErrorInfoValueType) uses Swift.Dictionary
 - LegacyErrorInfoc (Value == Any)
 
 In common, there are 2 strategies for collision resolving:
 1) `key augmentation`. For String-keyed containers (more precisely to say Collection-based-key containers)
 2) `multiple values for key`
 
 Which one should be used as a default is an opened question. Initially I only used `key augmentation`, which was enough for our needs.
 It seems there is no need to make key augmentation when collision just happens. Collisions very rarely happens when adding values
 via subscript on the client side.
 The main source of collisions is when error infos of multiple errors are merged.
 When it happens, it reasonable to disambiguate from each error each value was and augment keys with error domain and code, for example.
 
 For an error type it seems `multiple values for key` is sematically preferred. error instance may have several different values
 if error info was passed around the code and finally landed to error initializer.
 When several of such error are merged to a Dictionary then:
 - collisions inside error are resolved by key augmentation, where value.collisionSpecifier is used (e.g. as an suffix)
 - collisions between errors are also resolved by key augmentation, but some kind of error identity used (e.g. domain + code)
 
 `key augmentation` error-info containers can simply wrap OrderedDictionary as a backing storage.
 For `multiple values for key` special OrderedMultiValueDictionary is needed. It can be optimized, but all in all its backing
 storage implementation has bigger overhead.
 
 (test the followng case, the keys are correctly augmented with error domain / code)
 NE2 ["T.Type": type1, "timeStamp": time1, "id": 2, "ne": "ne"]
 ME14 ["decodingDate": date1, "timeStamp": time0, "id": 1, "me": "me"]
 JM4 ["decodingDate": date0, "T.Type": type0, "id": 0, "jm": "jm"]
 
 Value Collisions:
 There is a choice whether equal values should be added or not. By default they are not added.
 ```
 func foo() {
   var info: ErrorInfo = ["a": 1]
   info["a"] = 1 // not added as 1 is already stored for key "a"
   info["a"] = 2 // added, now there are 2 values for key "a"
   info["a"] = "2" // added, Integer(2) and String("2") are treated as different values
 }
 ```
 For comparison `func isApproximatelyEqualAny` is used.
 
 ```
 func foo<T>(anyValue: T) {
   var legacyInfo: [String: Any] = ["a": anyValue] // no warning
   
   var errorInfo: ErrorInfo = ["a": anyValue] // ⛔️ compiler error
   var errorInfo: ErrorInfo = ["a": String(describing: anyValue)] // ok
 }
 ```
 
 ```
 func foo() {
   var errorInfo: ErrorInfo = ["a": "Hello"]
   bar(&errorInfo)
 }
 
 func bar(_ errorInfo: inout ErrorInfo) {
   errorInfo["a"] = "World"
 }
 ```
 
 Library was made for String-keyed containers in mind. Neverheless it is designed generically, so any Key types can used, see
 [toy examples] folder.
 */
