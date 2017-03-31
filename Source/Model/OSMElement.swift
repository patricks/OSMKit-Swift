//
//  OSMObject.swift
//  OSMKit
//
//  Created by David Chiles on 12/11/15.
//
//

import Foundation

public enum OSMElementType: String {
    case node
    case way
    case relation
}

public class OSMElement: OSMIdentifiable {
    public var osmIdentifier: Int64 = -1

    public var version: Int = 0
    public var changeset: Int64 = 0
    public var userIdentifier: Int64 = 0
    public var username: String?
    public var visible = true

    public var tags: [String: String]?
    public var timestampString: String?
    public var timeStamp: Date? {
        if let timestamp = timestampString {
            return DateFormatter.defaultOpenStreetMapDateFormatter().date(from: timestamp)
        }
        return nil
    }

    init(xmlAttributes: [String: String]) {
        // OSM id
        guard let idString = xmlAttributes[XMLAttributes.id.rawValue], let id = Int64(idString) else {
            return
        }

        self.osmIdentifier = id

        // OSM version
        if let versionString = xmlAttributes[XMLAttributes.version.rawValue], let version = Int(versionString) {
            self.version = version
        }

        // OSM changeset
        if let changesetString = xmlAttributes[XMLAttributes.changeset.rawValue], let changeset = Int64(changesetString) {
            self.changeset = changeset
        }

        // OSM  userId
        if let userIdentifierString = xmlAttributes[XMLAttributes.uid.rawValue], let userIdentifier = Int64(userIdentifierString) {
            self.userIdentifier = userIdentifier
        }

        // OSM User
        if let userString = xmlAttributes[XMLAttributes.user.rawValue] {
            self.username = userString
        }

        // OSM timestamp
        if let timeStampString = xmlAttributes[XMLAttributes.timestamp.rawValue] {
            self.timestampString = timeStampString
        }

        // OSM Visible
        if let visibleString = xmlAttributes[XMLAttributes.visible.rawValue] {
            switch visibleString {
            case "true":
                self.visible = true
            case "false":
                self.visible = false
            default:
                break
            }
        }
    }

    public func addTag(key: String, value: String) {
        if let _ = self.tags {
            self.tags![key] = value
        } else {
            self.tags = [String: String]()
            self.addTag(key: key, value: value)
        }
    }
}
