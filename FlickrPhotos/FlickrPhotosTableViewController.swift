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
  
  var region: Region? {
    didSet {
      let sortDescriptor = NSSortDescriptor(key: "uploadDate", ascending: false)
      fetchRequest.sortDescriptors = [sortDescriptor]
      
      let places = region?.places.allObjects
      let placesIds = (places as [Place]).map { $0.id as String! }
      fetchRequest.predicate = NSPredicate(format: "placeId in %@", argumentArray: [placesIds])
    }
  }

  
}


