//
//  OSMParser.swift
//  OSMKit
//
//  Created by David Chiles on 12/11/15.
//
//

import Foundation

public protocol OSMParserDelegate {
    func didStartParsing(parser: OSMParser)
    func didFinishParsing(parser: OSMParser)
    func didFindElement(parser: OSMParser, element: OSMElement)
    func didError(parser: OSMParser, error: Error?)
}

public enum XMLName: String {
    case node = "node"
    case way = "way"
    case relation = "relation"
    case tag = "tag"
    case wayNode = "nd"
    case member = "member"
}

public enum XMLAttributes: String {
    case id = "id"
    case uid = "uid"
    case user = "user"
    case version = "version"
    case changeset = "changeset"
    case timestamp = "timestamp"
    case visible = "visible"
    case latitude = "lat"
    case longitude = "lon"
    case key = "k"
    case value = "v"
    case ref = "ref"
    case role = "role"
    case typ = "type"
}

public class OSMParser: NSObject, XMLParserDelegate {
    public var delegate: OSMParserDelegate?

    public var delegateQueue = DispatchQueue(label: "OSMParserDelegateQueue")
    private var currentOperation: OSMParseOperation?
    private var endOperation = Operation()
    private let operationQueue = OperationQueue()
    private var xmlParser: XMLParser

    private let workQueue = DispatchQueue(label: "OSMParserWorkQueue")

    init(data: Data) {
        xmlParser = XMLParser(data: data)
    }

    init(stream: InputStream) {
        xmlParser = XMLParser(stream: stream)
    }

    public func parse() {
        xmlParser.delegate = self
        operationQueue.maxConcurrentOperationCount = OperationQueue.defaultMaxConcurrentOperationCount

        DispatchQueue.global(qos: .background).async { [weak self]() -> Void in
            self?.xmlParser.parse()
        }
    }

    func foundElement(element: OSMElement) {
        delegateQueue.async { [weak self]() -> Void in
            self?.delegate?.didFindElement(parser: self!, element: element)
        }
    }

    // MARK: XMLParserDelegate Methods

    public func parserDidStartDocument(_ parser: XMLParser) {
        workQueue.async {
            self.endOperation.completionBlock = { () -> Void in
                self.delegateQueue.async {
                    self.delegate?.didFinishParsing(parser: self)
                }
            }

            self.delegateQueue.async {
                self.delegate?.didStartParsing(parser: self)
            }
        }
    }

    public func parser(_: XMLParser,
                       didStartElement elementName: String,
                       namespaceURI _: String?,
                       qualifiedName _: String?,
                       attributes attributeDict: [String: String] = [:]) {
        workQueue.async { [weak self]() -> Void in
            if let name = XMLName(rawValue: elementName) {
                switch name {
                case .node: fallthrough
                case .way: fallthrough
                case .relation:
                    let operation = OSMParseOperation(completion: { [weak self](element) -> Void in
                        self?.foundElement(element: element)
                    })
                    self?.endOperation.addDependency(operation)
                    self?.currentOperation = operation
                default:
                    break
                }
                self?.currentOperation?.add(elementName: name, attributes: attributeDict)
            }
        }
    }

    public func parser(_: XMLParser, didEndElement elementName: String, namespaceURI _: String?, qualifiedName _: String?) {
        workQueue.async {
            switch elementName {
            case XMLName.node.rawValue: fallthrough
            case XMLName.way.rawValue: fallthrough
            case XMLName.relation.rawValue:
                if let operation = self.currentOperation {
                    self.operationQueue.addOperation(operation)
                }

                self.currentOperation = nil
            default:
                break
            }
        }
    }

    public func parserDidEndDocument(_: XMLParser) {
        workQueue.async {
            self.operationQueue.addOperation(self.endOperation)
        }
    }
}
