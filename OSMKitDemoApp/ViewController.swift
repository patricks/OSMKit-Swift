//
//  ViewController.swift
//  OSMKitDemoApp
//
//  Created by Patrick Steiner on 05.03.17.
//  Copyright © 2017 OSMKit. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var parser: OSMParser!
    
    fileprivate var osmWays = [OSMWay]()
    fileprivate var osmNodes = [OSMNode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let osmFilePath = Bundle.main.url(forResource: "demo-map", withExtension: "osm") else {
            fatalError("OSM data not found.")
        }
        
        do {
            print("Using file: \(osmFilePath.absoluteString)")
            
            let osmData = try Data(contentsOf: osmFilePath)
            
            parser = OSMParser(data: osmData)
            parser.delegate = self
            
            print("Starting parser...")
            
            parser.parse()
        } catch let error {
            print("Error reading file: \(error)")
        }
    }
    
    fileprivate func getWayNodes() {
        if let way = osmWays.first {
            for nodeId in way.nodeIds {
                if let node = osmNodes.first(where: { $0.osmIdentifier == nodeId }) {
                    print("Found: \(node.username)")
                }
            }
        }
    }
}

// MARK: - OSMParserDelegate

extension ViewController: OSMParserDelegate {
    func didStartParsing(parser: OSMParser) {
        print(#function)
    }
    
    func didFinishParsing(parser: OSMParser) {
        print(#function)
        
        print("Ways count: \(osmWays.count)")
        print("Nodes count: \(osmNodes.count)")
        
        getWayNodes()
    }
    
    func didFindElement(parser: OSMParser, element: OSMElement) {
        switch element {
        case let element as OSMWay:
            osmWays.append(element)
        case let element as OSMNode:
            osmNodes.append(element)
        default:
            break
        }
    }
    
    func didError(parser: OSMParser, error: Error?) {
        print(#function)
    }
}

