//
//  Photo.swift
//  FlickrPhotos
//
//  Created by Roma Sosnovsky on 9/26/14.
//  Copyright (c) 2014 Roma Sosnovsky. All rights reserved.
//

import Foundation
import CoreData

@objc(Photo)
class Photo: NSManagedObject {
  
  // MARK: Types
  
  /// An enumeration to specify the property names of interest in the JSON data. There may be other properties in the dictionary passed to updateFromDictionary(), but they are ignored.
  
  private enum JSONPhotoProperty: String {
    case Id = "id"
    case Title = "title"
    case Subtitle = "description"
    case WhoTook = "ownername"
  }
  
  // MARK: Properties
  
  @NSManaged var id: String
  @NSManaged var lastOpenTime: NSDate
  @NSManaged var photoURL: String
  @NSManaged var subtitle: String
  @NSManaged var thumbnail: NSData
  @NSManaged var thumbnailURL: String
  @NSManaged var title: String
  @NSManaged var whoTook: Photographer
  
  
  // MARK: Convenience Methods
  
  func updateFromDictionary(photoDictionary: [String: AnyObject]) {
    for (key, value) in photoDictionary {
      // Ignore the key / value pair if the value is NSNull.
      if value is NSNull {
        continue
      }
      
      if let property = JSONPhotoProperty(rawValue: key) {
        switch property {
        case .Id:
          id = value as String
          
        case .WhoTook:
          whoTook = Photographer.withName(value as String)
        
        case .Title:
          title = value as String
        
        case .Subtitle:
          subtitle = value["_content"] as String
        }
      }
    }
    
    photoURL = FlickrFetcher.shared.URLforPhoto(photoDictionary, format: .Large).absoluteString!
    thumbnailURL = FlickrFetcher.shared.URLforPhoto(photoDictionary, format: .Square).absoluteString!
  }
}
