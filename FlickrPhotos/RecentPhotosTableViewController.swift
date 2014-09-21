//
//  RecentPhotosTableViewController.swift
//  FlickrPhotos
//
//  Created by Roma Sosnovsky on 9/18/14.
//  Copyright (c) 2014 Roma Sosnovsky. All rights reserved.
//

import UIKit

class RecentPhotosTableViewController: PhotosTableViewController {
  
  override init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    savePhotos = false
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    fetchPhotos()
  }
  
  override func fetchPhotos() {
    let userDefaults = NSUserDefaults.standardUserDefaults()
    if let recentPhotos = userDefaults.objectForKey("recentPhotos") as? [[String:AnyObject]] {
      updatePhotos(recentPhotos)
    }
  }
  
}
