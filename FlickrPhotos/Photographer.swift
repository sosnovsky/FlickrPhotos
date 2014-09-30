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
  @NSManaged var photos: [Photo]
 
  class func withName(name: String) -> Photographer {
    let request = NSFetchRequest(entityName: "Photographer")
    request.predicate = NSPredicate(format: "name = %@", name)
    
    let context = CoreDataStackManager.sharedManager.managedObjectContext!
    var anyError: NSError?
    var photographer: Photographer
    
    var existingPhotographer = context.executeFetchRequest(request, error: &anyError) as [Photographer]
    
    if existingPhotographer.count > 0 {
      photographer = existingPhotographer[0]
    } else {
      photographer = NSEntityDescription.insertNewObjectForEntityForName("Photographer", inManagedObjectContext: context) as Photographer
      photographer.name = name
    }
    
    return photographer
  }
}