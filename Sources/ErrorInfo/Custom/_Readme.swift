//
//  _Readme.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 15/09/2025.
//

/*
 Error-info types / implementations can tachnically be hashable / equatable, but it seems there are no valid  and robust
 reasons to do so. E.g. error info instances can contain semantically equal content, but differently represented (as Integer or String for example).
 Comparing two Error-infos with exact same content seems to be wrong operation from perspective of practical usage.
 For those narrow cases when hashable / equatable abilities are truly needed and justified, special error-inf type can be made.
 */
