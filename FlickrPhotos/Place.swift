//
//  Place.swift
//  FlickrPhotos
//
//  Created by Roma Sosnovsky on 10/2/14.
//  Copyright (c) 2014 Roma Sosnovsky. All rights reserved.
//

import Foundation
import CoreData

@objc(Place)
class Place: NSManagedObject {

    @NSManaged var id: String
    @NSManaged var region: Region
    @NSManaged var photos: NSSet

}
