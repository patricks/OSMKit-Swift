//
//  Error.swift
//  Pods
//
//  Created by David Chiles on 2/8/16.
//
//

import Foundation

enum JSONParsingError: Error {
    case invalidJSONStructure
    case cannotDecodeKey(key: JSONKeys)
}
