//
//  Place.swift
//  FlickrPhotos
//
//  Created by Roma Sosnovsky on 10/2/14.
//  Copyright (c) 2014 Roma Sosnovsky. All rights reserved.
//

import Foundation
import CoreData

class Place: NSManagedObject {
  
  @NSManaged var id: String
  @NSManaged var region: Region
  @NSManaged var photos: NSSet
  
}

extension Place {
  class func withId(id: String, context: NSManagedObjectContext) -> Place {
    let request = NSFetchRequest(entityName: "Place")
    request.predicate = NSPredicate(format: "id = %@", id)
    
    var anyError: NSError?
    var place: Place
    
    var existingPlace = context.executeFetchRequest(request, error: &anyError) as [Place]
    
    if existingPlace.count > 0 {
      place = existingPlace[0]
    } else {
      place = NSEntityDescription.insertNewObjectForEntityForName("Place", inManagedObjectContext: context) as Place
      place.id = id
    }
    
    return place
  }
}