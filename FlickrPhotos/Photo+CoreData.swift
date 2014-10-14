//
//  Photo+CoreData.swift
//  FlickrPhotos
//
//  Created by Roma Sosnovsky on 10/2/14.
//  Copyright (c) 2014 Roma Sosnovsky. All rights reserved.
//

import Foundation
import CoreData

extension Photo {
  func updateFromDictionary(photoDictionary: [String: AnyObject], context: NSManagedObjectContext) {
    id = photoDictionary["id"]! as String
    title = photoDictionary["title"]! as String
    subtitle = photoDictionary["description"]!["_content"] as String
    photoURL = FlickrFetcher.shared.URLforPhoto(photoDictionary, format: .Large).absoluteString!
    thumbnailURL = FlickrFetcher.shared.URLforPhoto(photoDictionary, format: .Square).absoluteString!
    
    let photographerName = photoDictionary["ownername"]! as String
    whoTook = Photographer.withName(photographerName, context: context)

    placeId = photoDictionary["place_id"]! as String
    place = Place.withId(placeId, context: context)
    
    let date = photoDictionary["dateupload"]! as NSString
    let timeInterval = NSTimeInterval(date.doubleValue)
    uploadDate = NSDate(timeIntervalSince1970: timeInterval)
  }
}