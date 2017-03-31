//
//  APIManager.swift
//  
//
//  Created by David Chiles on 12/21/15.
//
//

import Foundation

public enum APIURLString: String {
    case production = "https://api.openstreetmap.org/api/0.6/"
    case development = "http://api06.dev.openstreetmap.org/api/0.6/"
    
    func endpoint(endpoint: APIEndpoint) -> String {
        return self.rawValue + endpoint.rawValue
        // TODO: check if this works
        //return self.rawValue.stringByAppendingString(endpoint.rawValue)
    }
}

enum APIEndpoint: String {
    case map = "map"
    case notes = "notes.json"
}

internal enum Paramters: String {
    case boundingBox = "bbox"
}

extension BoundingBox {
    func osmURLString() -> String {
        return "\(self.left),\(self.bottom),\(self.right),\(self.top)"
    }
}

public class OSMAPIManager {
    public var OSMURL: APIURLString = .production
    
    init(apiConsumerKey: String,
         apiPrivateKey: String,
         token: String,
         tokenSecret: String) {
    }
    
    // MARK: Downloading data

    public func downloadBoundingBox(boundingBox: BoundingBox, completion: @escaping (_ data: Data?, _ error: Error?) -> Void) {
        let bboxString = boundingBox.osmURLString()
        let urlString = self.OSMURL.endpoint(endpoint: .map)

        var urlComponents = URLComponents(string: urlString)
        urlComponents?.queryItems = [
            URLQueryItem(name: Paramters.boundingBox.rawValue, value: bboxString)
        ]

        if let url = urlComponents?.url {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"

            URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                    completion(data, error)
                } else {
                    completion(nil, nil)
                }
            }.resume()
        }
    }
    
    // Mark: Downloading Notes

    public func downloadNotesBoundingBox(boundingBox: BoundingBox, completion: @escaping (_ data: Data?, _ error: Error?) -> Void) {
        let bboxString = boundingBox.osmURLString()
        let urlString = self.OSMURL.endpoint(endpoint: .notes)

        var urlComponents = URLComponents(string: urlString)
        urlComponents?.queryItems = [
            URLQueryItem(name: Paramters.boundingBox.rawValue, value: bboxString)
        ]

        if let url = urlComponents?.url {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"

            URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                    completion(data, error)
                } else {
                    completion(nil, nil)
                }
            }.resume()
        }
    }
    
    // MARK: Uploading Data
    
    public func openChangeset(tags: [String: String], completion: () -> Void) {
        // TODO: implement function
    }
}
