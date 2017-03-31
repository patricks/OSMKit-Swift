//
//  ParserDelegate.swift
//  OSMKit
//
//  Created by David Chiles on 12/18/15.
//  Copyright © 2015 David Chiles. All rights reserved.
//

import Foundation

class ParserDelegate: OSMParserDelegate {
    var startBlock: (_ parser: OSMParser) -> Void
    var endBlock: (_ parser: OSMParser) -> Void
    var nodeBlock: (_ parser: OSMParser, _ node: OSMNode) -> Void
    var wayBlock: (_ parser: OSMParser, _ way: OSMWay) -> Void
    var relationBlock: (_ parser: OSMParser, _ relation: OSMRelation) -> Void
    var errorBlock:(_ parser: OSMParser, _ error: Error?) -> Void
    
    init(startBlock: @escaping (_ parser: OSMParser) -> Void,
         nodeBlock: @escaping (_ parser: OSMParser, _ node: OSMNode) -> Void,
         wayBlock: @escaping (_ parser: OSMParser, _ way: OSMWay) -> Void,
         relationBlock: @escaping (_ parser: OSMParser, _ relation: OSMRelation) -> Void,
         endBlock: @escaping (_ parser: OSMParser) -> Void,
         errorBlock: @escaping (_ parser: OSMParser, _ error: Error?) -> Void) {
        self.startBlock = startBlock
        self.nodeBlock = nodeBlock
        self.wayBlock = wayBlock
        self.relationBlock = relationBlock
        self.errorBlock = errorBlock
        self.endBlock = endBlock
    }
    
    //MARK: OSMParserDelegate

    func didStartParsing(parser: OSMParser) {
        self.startBlock(parser)
    }
    
    func didFindElement(parser: OSMParser, element: OSMElement) {
        switch element {
        case let element as OSMNode:
            self.nodeBlock(parser, element)
        case let element as OSMWay:
            self.wayBlock(parser, element)
        case let element as OSMRelation:
            self.relationBlock(parser, element)
        default:
            break
        }
    }
    
    func didFinishParsing(parser: OSMParser) {
        self.endBlock(parser)
    }
    
    func didError(parser: OSMParser, error: Error?) {
        self.errorBlock(parser, error)
    }
}
