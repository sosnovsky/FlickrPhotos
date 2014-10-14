//
//  RecentPhotosTableViewController.swift
//  FlickrPhotos
//
//  Created by Roma Sosnovsky on 9/18/14.
//  Copyright (c) 2014 Roma Sosnovsky. All rights reserved.
//

import UIKit
import CoreData

class RecentPhotosTableViewController: PhotosTableViewController {
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    var error: NSError? = nil
    if !_fetchedResultsController!.performFetch(&error) {
      println("Unresolved error \(error), \(error?.userInfo)")
      abort()
    }
  }
  
  // MARK: Fetched Results Controller
  override var fetchedResultsController: NSFetchedResultsController {
    if _fetchedResultsController != nil {
      return _fetchedResultsController!
    }
    
    let fetchRequest = NSFetchRequest()
    
    let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: self.managedObjectContext)
    fetchRequest.entity = entity
    
    let recentSortDescriptor = NSSortDescriptor(key: "lastOpenTime", ascending: false)
    let sortDescriptor = NSSortDescriptor(key: "uploadDate", ascending: false)
    fetchRequest.sortDescriptors = [recentSortDescriptor, sortDescriptor]
    
    fetchRequest.predicate = NSPredicate(format: "lastOpenTime != nil")

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
