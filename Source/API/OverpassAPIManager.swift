//
//  OverpassAPIManager.swift
//  overpassSwift
//
//  Created by Patrick Steiner on 13.03.17.
//  Copyright © 2017 Patrick Steiner. All rights reserved.
//

import Foundation
import CoreLocation

public class OverpassAPIManager {

    public init() {}

    public func queryStreets(boundingBox: [CLLocationCoordinate2D], completion: @escaping (_ successful: Bool, _ reponseData: Data?) -> Void) {
        guard let url = URL(string: "https://overpass-api.de/api/interpreter") else { return }
        guard let bboxString = boundingBoxString(boundingBox: boundingBox) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let queryDataString = streetQueryString(boundingBox: bboxString)
        request.httpBody = queryDataString.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let response = response as? HTTPURLResponse,
                response.statusCode == 200,
                let data = data {
                completion(true, data)
            } else {
                if let error = error {
                    print("ERROR: Failed to query streets: \(error.localizedDescription)")
                }

                completion(false, nil)
            }
        }.resume()
    }

    private func streetQueryString(boundingBox: String) -> String {
        var string = "data="
        string += "("

        // TODO: find out if it is possible to set the bounding box once
        // highways
        string += wayQueryString(type: "motorway", boundingBox: boundingBox)
        string += wayQueryString(type: "trunk", boundingBox: boundingBox)
        string += wayQueryString(type: "primary", boundingBox: boundingBox)
        string += wayQueryString(type: "secondary", boundingBox: boundingBox)
        string += wayQueryString(type: "tertiary", boundingBox: boundingBox)
        string += wayQueryString(type: "unclassified", boundingBox: boundingBox)
        string += wayQueryString(type: "residential", boundingBox: boundingBox)
        string += wayQueryString(type: "service", boundingBox: boundingBox)

        // links
        string += wayQueryString(type: "motorway_link", boundingBox: boundingBox)
        string += wayQueryString(type: "trunk_link", boundingBox: boundingBox)
        string += wayQueryString(type: "primary_link", boundingBox: boundingBox)
        string += wayQueryString(type: "secondary_link", boundingBox: boundingBox)
        string += wayQueryString(type: "tertiary_link", boundingBox: boundingBox)

        string += ");"
        string += "(._;>;);"; // also add nodes
        string += "out;"

        return string
    }

    private func wayQueryString(type: String, boundingBox: String) -> String {
        return "way[highway=\(type)](\(boundingBox));"
    }

    private func boundingBoxString(boundingBox: [CLLocationCoordinate2D]) -> String? {
        if boundingBox.count != 2 {
            return nil
        }

        let lowestLatitude = min(boundingBox[0].latitude, boundingBox[1].latitude)
        let lowestLongitude = min(boundingBox[0].longitude, boundingBox[1].longitude)

        let highestLatitude = max(boundingBox[0].latitude, boundingBox[1].latitude)
        let highestLongitude = max(boundingBox[0].longitude, boundingBox[1].longitude)

        return "\(lowestLatitude), \(lowestLongitude), \(highestLatitude), \(highestLongitude)"
    }
}
