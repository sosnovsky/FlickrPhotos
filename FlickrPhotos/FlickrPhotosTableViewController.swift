//
//  FlickrPhotosTableViewController.swift
//  FlickrPhotos
//
//  Created by Roma Sosnovsky on 6/17/14.
//  Copyright (c) 2014 Roma Sosnovsky. All rights reserved.
//

import UIKit

class FlickrPhotosTableViewController: PhotosTableViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    fetchPhotos()
  }
  
  override func fetchPhotos() {
    refreshControl?.beginRefreshing()
    let photosUrl = FlickrFetcher.shared.URLforPhotosInPlace(placeId, maxResults: 50)
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
      let data = NSData(contentsOfURL: photosUrl)
      let propertyListResults = NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers, error: nil) as [String:AnyObject]
      dispatch_async(dispatch_get_main_queue(), {
        if let photosList: AnyObject = propertyListResults["photos"]?["photo"] {
          self.updatePhotos(photosList as [[String:AnyObject]])
        }
        self.refreshControl?.endRefreshing()
      })
    })
  }
  
}


