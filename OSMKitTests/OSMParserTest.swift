//
//  OSMParserTest.swift
//  OSMKit
//
//  Created by David Chiles on 12/17/15.
//  Copyright © 2015 David Chiles. All rights reserved.
//

import XCTest

class OSMParserTest: XCTestCase {
    var data: Data?
    var parser: OSMParser?

    override func setUp() {
        super.setUp()
        let fileURL = Bundle(for: type(of: self)).url(forResource: "map", withExtension: "osm")
        self.data = try? Data(contentsOf: fileURL!)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testParser() {
        var nodeCount = 0
        var wayCount = 0
        var wayNodeCount = 0
        var relationCount = 0
        var memberCount = 0
        var tagCount = 0
        
        let expecation = self.expectation(description: "parser")
        
        let startBlock:(_ parser:OSMParser) -> Void = { parser in

        }
        
        let endBlock:(_ parser:OSMParser) -> Void = { parser in
            XCTAssertEqual(nodeCount, 12478)
            XCTAssertEqual(wayCount, 1699)
            XCTAssertEqual(relationCount, 120)
            XCTAssertEqual(memberCount, 3266)
            XCTAssertEqual(wayNodeCount, 14253)
            XCTAssertEqual(tagCount, 12843)
            expecation.fulfill()
        }
        
        let nodeBlock:(_ parser: OSMParser, _ element: OSMNode) -> Void = { parser, element in
            nodeCount += 1
            XCTAssertGreaterThan(element.osmIdentifier, 0)
            if let tags = element.tags {
                tagCount += tags.count
            }
        }
        
        let wayBlock:(_ parser: OSMParser, _ way: OSMWay) -> Void = { parser,way in
            wayCount += 1
            wayNodeCount += way.nodeIds.count
            if let tags = way.tags {
                tagCount += tags.count
            }
        }
        
        let relationBlock:(_ parser: OSMParser,_ relation: OSMRelation) -> Void = { parser, relation in
            relationCount += 1
            memberCount += relation.members.count
            if let tags = relation.tags {
                tagCount += tags.count
            }
        }
        
        let errorBlock:(_ parser: OSMParser, _ error: Error?) -> Void = { parser, error in
            
        }
        
        let parseDelegate = ParserDelegate(startBlock: startBlock, nodeBlock: nodeBlock, wayBlock: wayBlock, relationBlock: relationBlock, endBlock: endBlock, errorBlock: errorBlock)
        
        self.parser = OSMParser(data: self.data!)
        self.parser?.delegate = parseDelegate
        self.parser?.parse()
        
        self.waitForExpectations(timeout: 100) { (error) -> Void in
            if let error = error {
                print("ERROR \(error)")
            }
        }
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            self.testParser()
        }
    }
}
