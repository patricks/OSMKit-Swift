//
//  JSONDecoder.swift
//  Pods
//
//  Created by David Chiles on 1/15/16.
//
//

import Foundation

internal enum JSONKeys: String {
    case geometry = "geometry"
    case coordinates = "coordinates"
    case properties = "properties"
    case id = "id"
    case url = "url"
    case status = "status"
    case dateCreated = "date_created"
    case dateClosed = "closed_at"
    case comments = "comments"
    case text = "text"
    case date = "date"
    case action = "action"
    case uid = "uid"
    case user = "user"
    case features = "features"
}

internal enum NoteStatusValue: String {
    case open
    case closed
}

public class JSONDecoder {
    class func comment(dictionary:[String:AnyObject]) throws -> OSMComment {
        guard let dateString = dictionary[JSONKeys.date.rawValue] as? String else {
            throw JSONParsingError.cannotDecodeKey(key: .date)
        }
        
        guard let actionString = dictionary[JSONKeys.action.rawValue] as? String else {
            throw JSONParsingError.cannotDecodeKey(key: .action)
        }
        
        guard let action = OSMCommentAction(rawValue: actionString) else {
            throw JSONParsingError.cannotDecodeKey(key: .action)
        }
        
        let text = dictionary[JSONKeys.text.rawValue] as? String
        
        let uid = dictionary[JSONKeys.uid.rawValue] as? NSNumber
        
        let username = dictionary[JSONKeys.user.rawValue] as? String
        
        var comment = OSMComment(dateString: dateString, action: action)
        comment.text = text
        comment.userId = uid?.int64Value
        comment.username = username
        
        return comment
    }

    class func note(dict: [String: AnyObject]) throws -> OSMNote {
        guard let geometry = dict[JSONKeys.geometry.rawValue] as? [String: AnyObject] else {
            throw JSONParsingError.cannotDecodeKey(key: JSONKeys.geometry)
        }
        
        guard let coordinates = geometry[JSONKeys.coordinates.rawValue] as? [Double] else {
            throw JSONParsingError.cannotDecodeKey(key: JSONKeys.coordinates)
        }
        
        if coordinates.count != 2 {
            throw JSONParsingError.invalidJSONStructure
        }
        
        let lon = coordinates[0]
        let lat = coordinates[1]
        
        
        guard let properties = dict[JSONKeys.properties.rawValue] as? [String: AnyObject] else {
            throw JSONParsingError.cannotDecodeKey(key: JSONKeys.properties)
        }
        
        guard let id = (properties[JSONKeys.id.rawValue] as? NSNumber)?.int64Value else {
            throw JSONParsingError.cannotDecodeKey(key: JSONKeys.id)
        }
        
        guard let urlString = properties[JSONKeys.url.rawValue] as? String else {
            throw JSONParsingError.cannotDecodeKey(key: JSONKeys.url)
        }
        let url = NSURL(string: urlString)
        
        let status = (properties[JSONKeys.status.rawValue] as? String) == NoteStatusValue.open.rawValue
        
        guard let dateCreated = properties[JSONKeys.dateCreated.rawValue] as? String else {
            throw JSONParsingError.cannotDecodeKey(key: JSONKeys.dateCreated)
        }
        
        let dateClosed = properties[JSONKeys.dateClosed.rawValue] as? String
        
        guard let commentsArray = properties[JSONKeys.comments.rawValue] as? [[String: AnyObject]] else {
            throw JSONParsingError.cannotDecodeKey(key: JSONKeys.comments)
        }
        
        var comments = [OSMComment]()
        for commentDictionary in commentsArray {
            let comment = try self.comment(dictionary: commentDictionary)
            comments.append(comment)
        }
        
        let note = OSMNote(osmIdentifier: id,
                           latitude: lat,
                           longitude: lon,
                           open: status,
                           dateCreated: dateCreated,
                           dateClosed: dateClosed,
                           url: url )
        
        note.comments = comments
        
        return note
    }

    public class func notes(data: Data) throws -> [OSMNote] {
        guard let jsonDict = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject] else {
            throw JSONParsingError.invalidJSONStructure
        }
        
        guard let features = jsonDict[JSONKeys.features.rawValue] as? [[String: AnyObject]] else {
            throw JSONParsingError.cannotDecodeKey(key: .features)
        }
        
        var notesArray = [OSMNote]()
        for noteDict in features {
            let note = try self.note(dict: noteDict)
            notesArray.append(note)
        }
        
        return notesArray
    }
    
    public class func note(data: Data) throws -> OSMNote {
        guard let noteDict = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject] else {
            throw JSONParsingError.invalidJSONStructure
        }
        
        return try self.note(dict: noteDict)
    }
}
