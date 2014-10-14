//
//  Region+CoreData.swift
//  FlickrPhotos
//
//  Created by Roma Sosnovsky on 10/2/14.
//  Copyright (c) 2014 Roma Sosnovsky. All rights reserved.
//

import Foundation
import CoreData

extension Region {
  class func withName(name: String, context: NSManagedObjectContext) -> Region {
    let request = NSFetchRequest(entityName: "Region")
    request.predicate = NSPredicate(format: "name = %@", name)
    
    var anyError: NSError?
    var region: Region
    
    var existingRegion = context.executeFetchRequest(request, error: &anyError) as [Region]
    
    if existingRegion.count > 0 {
      region = existingRegion[0]
    } else {
      region = NSEntityDescription.insertNewObjectForEntityForName("Region", inManagedObjectContext: context) as Region
      region.name = name
    }
    
    return region
  }
  
  func addPhotographer(photographer: Photographer) {
    var photographers = mutableSetValueForKey("photographers")
    photographers.addObject(photographer)
    photographersCount = NSNumber(integer: photographers.count)
  }
  
  func addPlace(place: Place) {
    var places = mutableSetValueForKey("places")
    places.addObject(place)
  }
}