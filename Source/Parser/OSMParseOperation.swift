//
//  OSMParseOperation.swift
//  OSMKit
//
//  Created by David Chiles on 12/21/15.
//  Copyright © 2015 David Chiles. All rights reserved.
//

import Foundation

internal class OSMParseOperation: Operation {

    var type: OSMElementType?
    var attributes: [String: String]?
    var tagAttributes: [[String: String]] = {
        return [[String: String]]()
    }()

    lazy var wayNodeAttributes: [[String: String]] = {
        return [[String: String]]()
    }()

    lazy var relationMemberAttributes: [[String: String]] = {
        return [[String: String]]()
    }()

    let completion: (_ element: OSMElement) -> Void

    init(completion: @escaping (_ element: OSMElement) -> Void) {
        self.completion = completion
    }

    func add(elementName: XMLName, attributes: [String: String]) {
        switch elementName {
        case .node:
            self.type = .node
            self.attributes = attributes
        case .way:
            self.type = .way
            self.attributes = attributes
        case .relation:
            self.type = .relation
            self.attributes = attributes
        case .tag:
            self.tagAttributes.append(attributes)
        case .wayNode:
            self.wayNodeAttributes.append(attributes)
        case .member:
            self.relationMemberAttributes.append(attributes)
        }
    }

    override func main() {
        // Make sure this element has a type
        guard let type = self.type else {
            return
        }

        // Make sure this element has basic attributes
        guard let attributes = self.attributes else {
            return
        }

        // Create Element
        let element = OSMParseOperation.element(type: type, attributes: attributes)

        // Go through all the tag attributes
        for var attributeDict in self.tagAttributes {
            guard let key = attributeDict[XMLAttributes.key.rawValue] else {
                break
            }
            guard let value = attributeDict[XMLAttributes.value.rawValue] else {
                break
            }

            element.addTag(key: key, value: value)
        }

        // Get all the nodes for a way
        for var attributeDict in self.wayNodeAttributes {
            guard let ndString = attributeDict[XMLAttributes.ref.rawValue] else {
                break
            }

            guard let nd = Int64(ndString) else {
                break
            }

            (element as? OSMWay)?.nodeIds.append(nd)
        }

        // Relation Members
        for var attributeDict in self.relationMemberAttributes {
            guard let typeString = attributeDict[XMLAttributes.typ.rawValue] else {
                break
            }

            guard let type = OSMElementType(rawValue: typeString) else {
                break
            }

            guard let refString = attributeDict[XMLAttributes.ref.rawValue] else {
                break
            }

            guard let ref = Int64(refString) else {
                break
            }
            let member = OSMRelationMember(member: OSMID(type: type, ref: ref), role: attributeDict[XMLAttributes.role.rawValue])
            (element as? OSMRelation)?.members.append(member)
        }

        completion(element)
    }

    class func element(type: OSMElementType, attributes: [String: String]) -> OSMElement {
        switch type {
        case .node:
            return OSMNode(xmlAttributes: attributes)
        case .way:
            return OSMWay(xmlAttributes: attributes)
        case .relation:
            return OSMRelation(xmlAttributes: attributes)
        }
    }
}
