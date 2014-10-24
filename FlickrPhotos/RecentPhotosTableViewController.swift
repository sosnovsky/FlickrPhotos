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
  
  override init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    let recentSortDescriptor = NSSortDescriptor(key: "lastOpenTime", ascending: false)
    let sortDescriptor = NSSortDescriptor(key: "uploadDate", ascending: false)
    fetchRequest.sortDescriptors = [recentSortDescriptor, sortDescriptor]
    
    fetchRequest.predicate = NSPredicate(format: "lastOpenTime != nil")
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    var error: NSError? = nil
    if !_fetchedResultsController!.performFetch(&error) {
      println("Unresolved error \(error), \(error?.userInfo)")
      abort()
    }
  }
  
}
