//
//  RegionsTableViewController.swift
//  FlickrPhotos
//
//  Created by Roma Sosnovsky on 6/14/14.
//  Copyright (c) 2014 Roma Sosnovsky. All rights reserved.
//

import UIKit
import CoreData

class RegionsTableViewController: CoreDataTableViewController {
  
  override init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    fetchRequest.entity = NSEntityDescription.entityForName("Region", inManagedObjectContext: managedObjectContext)
    
    let sortDescriptor = NSSortDescriptor(key: "photographersCount", ascending: false)
    fetchRequest.sortDescriptors = [sortDescriptor]
    
    cellIdentifier = "RegionCell"
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadTableView", name: "regionsDataUpdated", object: nil)
  }
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
  // MARK: Convenience
  
  func reloadTableView() {
    var error: NSError? = nil
    if !_fetchedResultsController!.performFetch(&error) {
      println("Unresolved error \(error), \(error?.userInfo)")
      abort()
    }
    
    tableView.reloadData()
  }
  
  // MARK: - Segues
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showRegionPhotos" {
      if let indexPath = tableView.indexPathForSelectedRow() {
        let region = fetchedResultsController.objectAtIndexPath(indexPath) as Region
        let controller = segue.destinationViewController as RegionPhotosTableViewController
        controller.region = region
        controller.navigationItem.title = region.name
        controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem()
        controller.navigationItem.leftItemsSupplementBackButton = true
      }
    }
  }
  
  // MARK: Table View Controller
  override func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
    let region = fetchedResultsController.objectAtIndexPath(indexPath) as Region
    cell.textLabel.text = region.name
    cell.detailTextLabel?.text = "\(region.photographersCount) photographers"
  }
  
}
