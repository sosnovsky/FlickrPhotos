//
//  PhotosTableViewController.swift
//  FlickrPhotos
//
//  Created by Roma Sosnovsky on 9/18/14.
//  Copyright (c) 2014 Roma Sosnovsky. All rights reserved.
//

import UIKit
import CoreData

class PhotosTableViewController: CoreDataTableViewController {
  
  var imageDownloadsInProgress: [Int:PhotoDownloader]
  
  override init(coder aDecoder: NSCoder) {
    imageDownloadsInProgress = [Int:PhotoDownloader]()
    
    super.init(coder: aDecoder)
    
    fetchRequest.entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: managedObjectContext)
    cellIdentifier = "PhotoCell"
  }
  
  deinit {
    terminateAllDownloads()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    terminateAllDownloads()
  }
  
  func terminateAllDownloads() {
    for photoDownload in imageDownloadsInProgress.values {
      photoDownload.cancelDownload()
    }
    imageDownloadsInProgress = [Int:PhotoDownloader]()
  }
  
  func startThumbnailDownload(photo: Photo, forIndexPath indexPath: NSIndexPath) {
    if imageDownloadsInProgress[indexPath.row] == nil {
      let photoDownloader = PhotoDownloader(photo: photo)
      photoDownloader.completionHandler = {
        let cell = self.tableView.cellForRowAtIndexPath(indexPath)
        cell?.imageView.image = UIImage(data: photo.thumbnail)
        self.imageDownloadsInProgress[indexPath.row] = nil
      }
      imageDownloadsInProgress[indexPath.row] = photoDownloader
      photoDownloader.startDownload()
    }
  }
  
  func loadImagesForOnscreenRows() {
    if fetchedResultsController.fetchedObjects?.count > 0 {
      let visiblePaths = tableView.indexPathsForVisibleRows()
      for indexPath in visiblePaths! as [NSIndexPath] {
        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as Photo
        if photo.thumbnail.length == 0 {
          startThumbnailDownload(photo, forIndexPath: indexPath)
        }
      }
    }
  }
  
  override func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
    let photo = fetchedResultsController.objectAtIndexPath(indexPath) as Photo
    cell.detailTextLabel?.text = ""

    if !photo.title.isEmpty {
      cell.textLabel.text = photo.title
      cell.detailTextLabel?.text = photo.subtitle
    } else if !photo.description.isEmpty {
      cell.textLabel.text = photo.description
    } else {
      cell.textLabel.text = "Untitled"
    }
    
    if photo.thumbnail.length == 0 {
      if !tableView.dragging && !tableView.decelerating {
        startThumbnailDownload(photo, forIndexPath: indexPath)
      }
      cell.imageView.image = UIImage(named: "Placeholder")
    } else {
      cell.imageView.image = UIImage(data: photo.thumbnail)
    }
  }
  
  // MARK: - Segues
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showPhoto" {
      if let indexPath = tableView.indexPathForSelectedRow() {
        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as Photo
        photo.lastOpenTime = NSDate()
        managedObjectContext.save(nil)
        let controller = (segue.destinationViewController as UINavigationController).topViewController as PhotoViewController
        controller.title = photo.title
        controller.imageUrl = NSURL(string: photo.photoURL)
        controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem()
        controller.navigationItem.leftItemsSupplementBackButton = true
      }
    }
  }
  
  override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    if !decelerate {
      loadImagesForOnscreenRows()
    }
  }
  
  override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
    loadImagesForOnscreenRows()
  }

}
