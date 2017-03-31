//
//  OSMIdentifiable.swift
//  OSMKit
//
//  Created by David Chiles on 12/11/15.
//
//

import Foundation

public protocol OSMIdentifiable {
    var osmIdentifier: Int64 { get set }
}
