//
//  PhotosTableViewController.swift
//  FlickrPhotos
//
//  Created by Roma Sosnovsky on 9/18/14.
//  Copyright (c) 2014 Roma Sosnovsky. All rights reserved.
//

import UIKit

class PhotosTableViewController: UITableViewController {

  var photos = [[String:AnyObject]]()
  var placeId = ""
  var savePhotos = true
  
  override func awakeFromNib() {
    super.awakeFromNib()
    if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
      clearsSelectionOnViewWillAppear = false
      preferredContentSize = CGSize(width: 320.0, height: 600.0)
    }
  }
  
  func fetchPhotos() {}
  
  func updatePhotos(photosData: [[String:AnyObject]]) {
    photos = photosData
    tableView.reloadData()
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return photos.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("PhotoCell", forIndexPath: indexPath) as UITableViewCell
    let photo = photos[indexPath.row]
    let description: String = photo["description"]!["_content"] as String
    let title: AnyObject = photo["title"]!
    
    cell.detailTextLabel?.text = ""
    
    if !(title as String).isEmpty {
      cell.textLabel?.text = title as? String
      cell.detailTextLabel?.text = description
    } else if !description.isEmpty {
      cell.textLabel?.text = description
    } else {
      cell.textLabel?.text = "Untitled"
    }
    
    return cell
  }
  
  // MARK: - Segues
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showPhoto" {
      if let indexPath = tableView.indexPathForSelectedRow() {
        let photo = photos[indexPath.row]
        let title = photo["title"]! as? String
        let photoUrl: NSURL = FlickrFetcher.shared.URLforPhoto(photo, format: .Large)
        let controller = (segue.destinationViewController as UINavigationController).topViewController as PhotoViewController
        controller.imageUrl = photoUrl
        controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem()
        controller.navigationItem.leftItemsSupplementBackButton = true
        controller.title = title

        if savePhotos {
          savePhotoToRecents(photo)
        }
        
      }
    }
  }
  
  func savePhotoToRecents(photo: [String:AnyObject]) {
    let userDefaults = NSUserDefaults.standardUserDefaults()
    var userPhotos = [photo]
    let photoId = photo["id"]! as String
    
    if var recentPhotos = userDefaults.objectForKey("recentPhotos") as? [[String:AnyObject]] {
      let photoExists = contains(recentPhotos, { (item: [String:AnyObject]) -> Bool in
        let itemId = item["id"]! as String
        return itemId == photoId
      })
      if !photoExists {
        recentPhotos.append(photo)
      }
      userPhotos = recentPhotos
    }
    
    userDefaults.setValue(userPhotos, forKey: "recentPhotos")
    userDefaults.synchronize()
  }
  

}
