//
//  FlickrPhotosTableViewController.swift
//  FlickrPhotos
//
//  Created by Roma Sosnovsky on 6/17/14.
//  Copyright (c) 2014 Roma Sosnovsky. All rights reserved.
//

import UIKit
import CoreData

class FlickrPhotosTableViewController: PhotosTableViewController {
  
  var region: Region?
  
  // MARK: Fetched Results Controller
  override var fetchedResultsController: NSFetchedResultsController {
    if _fetchedResultsController != nil {
      return _fetchedResultsController!
    }
    
    let fetchRequest = NSFetchRequest()
    let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: self.managedObjectContext)
    fetchRequest.entity = entity
    
    let sortDescriptor = NSSortDescriptor(key: "uploadDate", ascending: false)
    fetchRequest.sortDescriptors = [sortDescriptor]
    
    let places = region?.places.allObjects
    let placesIds = (places as [Place]).map { $0.id as String! }
    fetchRequest.predicate = NSPredicate(format: "placeId in %@", argumentArray: [placesIds])
    
    let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
    aFetchedResultsController.delegate = self
    _fetchedResultsController = aFetchedResultsController
    
    var error: NSError? = nil
    if !_fetchedResultsController!.performFetch(&error) {
      println("Unresolved error \(error), \(error?.userInfo)")
      abort()
    }
    
    return _fetchedResultsController!
  }
  
}


