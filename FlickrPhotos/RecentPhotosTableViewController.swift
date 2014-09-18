//
//  RecentPhotosTableViewController.swift
//  FlickrPhotos
//
//  Created by Roma Sosnovsky on 9/18/14.
//  Copyright (c) 2014 Roma Sosnovsky. All rights reserved.
//

import UIKit

class RecentPhotosTableViewController: PhotosTableViewController {

  init() {
    super.init(savePhotos: false)
  }
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    updateTableContentInset()
  }

  
  override func fetchPhotos() {
    let userDefaults = NSUserDefaults.standardUserDefaults()
    if let recentPhotos = userDefaults.objectForKey("recentPhotos") as? [[String:AnyObject]] {
      updatePhotos(recentPhotos)
    }
  }
  
  override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
    updateTableContentInset()
  }
  
  func updateTableContentInset() {
    if let navController = navigationController? {
      let navBarFrame = navController.navigationBar.frame
      let topInset = navBarFrame.height + navBarFrame.origin.y
      let bottomInset = tabBarController?.tabBar.frame.height
      tableView.contentInset = UIEdgeInsets(top: topInset, left: 0, bottom: bottomInset!, right: 0)
    }
  }
  
}
