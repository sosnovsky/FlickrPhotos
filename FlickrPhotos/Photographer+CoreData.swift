//
//  Photographer+CoreData.swift
//  FlickrPhotos
//
//  Created by Roma Sosnovsky on 10/2/14.
//  Copyright (c) 2014 Roma Sosnovsky. All rights reserved.
//

import Foundation
import CoreData

extension Photographer {
  class func withName(name: String, context: NSManagedObjectContext) -> Photographer {
    let request = NSFetchRequest(entityName: "Photographer")
    request.predicate = NSPredicate(format: "name = %@", name)
    
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