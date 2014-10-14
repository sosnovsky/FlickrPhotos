//
//  Region.swift
//  FlickrPhotos
//
//  Created by Roma Sosnovsky on 10/11/14.
//  Copyright (c) 2014 Roma Sosnovsky. All rights reserved.
//

import Foundation
import CoreData

@objc(Region)
class Region: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var photographersCount: NSNumber
    @NSManaged var photographers: NSSet
    @NSManaged var places: NSSet

}
