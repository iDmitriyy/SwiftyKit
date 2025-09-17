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
 "time_ME7@MVC_40_idx1"
 ?? may be line can be omited and idx shpuld be used. If error identity(source specifier) is equal, mostly often it is the same
 file. So line number seems to look like a noise. This looks better:
 "time_ME7@MVC^idx0"
 "time_ME7@MVC^idx1"
 
  > This way the following code will add all 1000 values. In comparison, dictionary will save last value.
 ```
   for number in 1...1000 {
     errorInfo["a"] = number
   }
 ```
 However, it is not a typical situation when someone adds 1000 diferrent values for the same key.
 
 
 Opened equestions:
 - should all error info types itself be iterable (or iterable keyValues View should better be provided)? - For now Sequence
 is inherited by root errorInfo protocol, so all instances are iterable and conforms to Sequence.
 - should errorInfo's have `func removeValue(forKey:)`? For now not.
 */
