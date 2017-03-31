//
//  File.swift
//  OSMKit
//
//  Created by David Chiles on 12/17/15.
//  Copyright © 2015 David Chiles. All rights reserved.
//

import Foundation

private var dateFormatterSharedInstance: DateFormatter {
    // TODO: check if it really called once
    let instance = DateFormatter()
    instance.dateFormat = "YYYY-MM-dd'T'HH:mm:ssZ"

    return instance
}

public extension DateFormatter {
    // 2x speed increate using singlton from onceToken vs creating a new dateformatter each time it's used
    public class func defaultOpenStreetMapDateFormatter() -> DateFormatter {
        return dateFormatterSharedInstance
    }
}
