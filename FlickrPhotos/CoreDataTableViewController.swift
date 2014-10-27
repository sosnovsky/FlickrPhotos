//
//  CoreDataTableViewController.swift
//  FlickrPhotos
//
//  Created by Roma Sosnovsky on 9/18/14.
//  Copyright (c) 2014 Roma Sosnovsky. All rights reserved.
//

import UIKit
import CoreData

class CoreDataTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
  
  var cellIdentifier: String?
  
  lazy var managedObjectContext: NSManagedObjectContext = {
    let moc = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
    
    moc.persistentStoreCoordinator = CoreDataStackManager.sharedManager.persistentStoreCoordinator
    
    return moc
    }()
  
  lazy var flickrFetcher: FlickrFetcher = {
    return FlickrFetcher.shared
    }()

  // MARK: - UITableViewDataSource
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return fetchedResultsController.sections?.count ?? 0
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let sectionInfo = fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
    return sectionInfo.numberOfObjects
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier!, forIndexPath: indexPath) as UITableViewCell
    configureCell(cell, atIndexPath: indexPath)
    return cell
  }
  
  func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) { }
  
  // MARK: - Fetched results controller
  var _fetchedResultsController: NSFetchedResultsController? = nil
  let fetchRequest = NSFetchRequest()
  
  var fetchedResultsController: NSFetchedResultsController {
    if _fetchedResultsController != nil {
      return _fetchedResultsController!
    }
    
    fetchRequest.fetchBatchSize = 50
    
    let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
    aFetchedResultsController.delegate = self
    _fetchedResultsController = aFetchedResultsController
    
    var error: NSError? = nil
    if !_fetchedResultsController!.performFetch(&error) {
      println("Unresolved error \(error), \(error?.userInfo)")
      abort()
    }
    
    return _fetchedResultsController!
  }
  
  func controllerWillChangeContent(controller: NSFetchedResultsController) {
    tableView.beginUpdates()
  }

  func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
    switch type {
    case .Insert:
      tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
    case .Delete:
      tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
    case .Update:
      configureCell(tableView.cellForRowAtIndexPath(indexPath!)!, atIndexPath: indexPath!)
    case .Move:
      tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
      tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
    default:
      return
    }
  }
  
  func controllerDidChangeContent(controller: NSFetchedResultsController) {
    tableView.endUpdates()
  }
  
//  func controllerDidChangeContent(controller: NSFetchedResultsController) {
//    // In the simplest, most efficient, case, reload the table view.
//    self.tableView.reloadData()
//  }

}
