//
//  Photographer.swift
//  FlickrPhotos
//
//  Created by Roma Sosnovsky on 9/26/14.
//  Copyright (c) 2014 Roma Sosnovsky. All rights reserved.
//

import Foundation
import CoreData

@objc(Photographer)
class Photographer: NSManagedObject {
  
  @NSManaged var name: String
  @NSManaged var photos: NSSet
  @NSManaged var regions: NSSet
 
}