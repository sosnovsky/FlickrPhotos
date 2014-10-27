//
//  FlickrPhotosTableViewController.swift
//  FlickrPhotos
//
//  Created by Roma Sosnovsky on 6/17/14.
//  Copyright (c) 2014 Roma Sosnovsky. All rights reserved.
//

import UIKit
import CoreData

class RegionPhotosTableViewController: PhotosTableViewController {
  
  var region: Region? {
    didSet {
      let placesIds = (region!.places.allObjects as [Place]).map { $0.id as String! }
      fetchRequest.predicate = NSPredicate(format: "placeId in %@", argumentArray: [placesIds])
    }
  }
  
  override init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    let sortDescriptor = NSSortDescriptor(key: "uploadDate", ascending: false)
    fetchRequest.sortDescriptors = [sortDescriptor]
  }

  
}


