//
//  Photo.swift
//  FlickrPhotos
//
//  Created by Roma Sosnovsky on 10/11/14.
//  Copyright (c) 2014 Roma Sosnovsky. All rights reserved.
//

import Foundation
import CoreData

@objc(Photo)
class Photo: NSManagedObject {

    @NSManaged var id: String
    @NSManaged var lastOpenTime: NSDate
    @NSManaged var photoURL: String
    @NSManaged var placeId: String
    @NSManaged var subtitle: String
    @NSManaged var thumbnail: NSData
    @NSManaged var thumbnailURL: String
    @NSManaged var title: String
    @NSManaged var uploadDate: NSDate
    @NSManaged var place: Place
    @NSManaged var whoTook: Photographer

}
