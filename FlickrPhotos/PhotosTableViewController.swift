//
//  PhotosTableViewController.swift
//  FlickrPhotos
//
//  Created by Roma Sosnovsky on 9/18/14.
//  Copyright (c) 2014 Roma Sosnovsky. All rights reserved.
//

import UIKit

class PhotosTableViewController: CoreDataTableViewController {
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("PhotoCell", forIndexPath: indexPath) as UITableViewCell
    self.configureCell(cell, atIndexPath: indexPath)
    return cell
  }
  
  override func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
    let photo = self.fetchedResultsController.objectAtIndexPath(indexPath) as Photo
    cell.detailTextLabel?.text = ""
    let imageData = NSData(contentsOfURL: NSURL(string: photo.thumbnailURL)!, options: .DataReadingMappedIfSafe, error: nil)
    let image = UIImage(data: imageData!)
    cell.imageView?.image = image
    if !photo.title.isEmpty {
      cell.textLabel?.text = photo.title
      cell.detailTextLabel?.text = photo.subtitle
    } else if !photo.description.isEmpty {
      cell.textLabel?.text = photo.description
    } else {
      cell.textLabel?.text = "Untitled"
    }
  }
  
  // MARK: - Segues
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showPhoto" {
      if let indexPath = tableView.indexPathForSelectedRow() {
        let photo = self.fetchedResultsController.objectAtIndexPath(indexPath) as Photo
        photo.lastOpenTime = NSDate()
        self.managedObjectContext.save(nil)
        let controller = (segue.destinationViewController as UINavigationController).topViewController as PhotoViewController
        controller.title = photo.title
        controller.imageUrl = NSURL(string: photo.photoURL)
        controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem()
        controller.navigationItem.leftItemsSupplementBackButton = true
      }
    }
  }

}
