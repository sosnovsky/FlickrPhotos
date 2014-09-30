//
//  FlickrPlacesTableViewController.swift
//  FlickrPhotos
//
//  Created by Roma Sosnovsky on 6/14/14.
//  Copyright (c) 2014 Roma Sosnovsky. All rights reserved.
//

import UIKit
import CoreData

class FlickrRegionsTableViewController: CoreDataTableViewController {
  
  // MARK: Types
  
  private struct Constants {
    static let batchSize = 128
  }
  
  // MARK: Properties
  
  private var regions = [Region]()

  // MARK: View Life Cycle

  override func viewDidLoad() {
    super.viewDidLoad()
    fetchRecentGeoreferencedPhotos()
  }
  
  // MARK: Core Data Batching
  
  func fetchRecentGeoreferencedPhotos() {
    let jsonURL = FlickrFetcher.shared.URLforRecentGeoreferencedPhotos()
    
    let sessionConfiguration = NSURLSessionConfiguration.ephemeralSessionConfiguration()
    let session = NSURLSession(configuration: sessionConfiguration)
    
    let task = session.dataTaskWithURL(jsonURL) { data, response, error in
      if data == nil {
        println("Error connecting: \(error)")
        fatalError("Couldn't create connection to server.")
        return
      }
      
      var anyError: NSError?
      
      // Create a context on a private queue to fetch existing photos to compare with incoming data and create new photos as required.
      let taskContext = privateQueueContext(&anyError)
      if taskContext == nil {
        println("Error creating fetching context: \(anyError)")
        fatalError("Couldn't create fetching context.")
        return
      }
      
      let jsonDictionary = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &anyError) as? [String: AnyObject]
      
      if jsonDictionary == nil {
        println("Error creating JSON dictionary: \(anyError)")
        fatalError("Couldn't create JSON dictionary.")
        
        return
      }
      
      var photos = jsonDictionary!["photos"]!["photo"]! as [[String: AnyObject]]
      let totalPhotoCount = photos.count
      
      var numBatches = totalPhotoCount / Constants.batchSize
      numBatches += totalPhotoCount % Constants.batchSize > 0 ? 1 : 0
      
      for batchNumber in 0..<numBatches {
        let rangeStart = batchNumber * Constants.batchSize
        let rangeEnd = min(rangeStart + Constants.batchSize, totalPhotoCount)
        
        let photosBatch = Array(photos[rangeStart..<rangeEnd])
        
        // Create a request to fetch existing photos with the same codes as those in the JSON data.
        let matchingPhotoRequest = NSFetchRequest(entityName: "Photo")
        
        // Get the ids for each of the photo and store them in an array.
        let ids = photosBatch.map { $0["id"]! as String }
        matchingPhotoRequest.predicate = NSPredicate(format: "id in %@", argumentArray: [ids])
        
        let matchingPhotos = taskContext.executeFetchRequest(matchingPhotoRequest, error: &anyError) as? [Photo]
        if matchingPhotos == nil {
          println("Error fetching: \(anyError)")
          fatalError("Fetch failed.")
          return
        }
        
        // Create a dictionary to map from a code to the corresponding matched quake.
        let matchingPhotosIds = matchingPhotos!.map { $0.id as String }
        
        for photoDictionary in photosBatch {
          let id = photoDictionary["id"]! as String
          
          if !contains(matchingPhotosIds, id) {
            let photo = NSEntityDescription.insertNewObjectForEntityForName("Photo", inManagedObjectContext: taskContext) as Photo
            photo.updateFromDictionary(photoDictionary)
          }
        }
        
        if !taskContext.save(&anyError) {
          println("Error saving batch: \(anyError)")
          fatalError("Saving batch failed.")
          return
        }
        
        taskContext.reset()
      }
      
      // Bounce back to the main queue to reload the table view and reenable the fetch button.
//      NSOperationQueue.mainQueue().addOperationWithBlock {
//        self.reloadTableView(nil)
//      }
    }
    
    task.resume()
  }
  
  // MARK: Convenience
  
  /// Fetch quakes ordered in time and reload the table view.
  private func reloadTableView(sender: AnyObject?) {
    let request = NSFetchRequest(entityName: "Photo")
    request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
    
    var anyError: NSError?
    
    let fetchedRegions = CoreDataStackManager.sharedManager.managedObjectContext?.executeFetchRequest(request, error: &anyError)
    
    if fetchedRegions == nil {
      println("Error fetching: \(anyError)")
      fatalError("Fetch failed.")
      return
    }
    
    regions = fetchedRegions as [Region]
    
    tableView.reloadData()
  }
  
  // MARK: Table View Controller
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
    self.configureCell(cell, atIndexPath: indexPath)
    return cell
  }
  
  override func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
    let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as NSManagedObject
    cell.textLabel?.text = object.valueForKey("timeStamp")!.description
  }

//
//  override func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
//    let country = Array(places.keys)[section]
//    if let citiesCount = places[country]?.count {
//      return citiesCount
//    }
//    return 0
//  }
  
//  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//    let cell = tableView.dequeueReusableCellWithIdentifier("flickrPlaceCell", forIndexPath: indexPath) as UITableViewCell
//    let section = indexPath.section
//    let row = indexPath.row
//    let country = Array(places.keys)[section]
//    if let place = places[country]![row] as? [String:String] {
//      var placeData = place["_content"]?.componentsSeparatedByString(", ")
//      cell.textLabel?.text = place["woe_name"]
//      cell.detailTextLabel?.text = placeData![1]
//    }
//    
//    return cell
//  }
  
  // #pragma mark - Navigation
  
//  override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
//    if let indexPath = tableView.indexPathForSelectedRow() {
//      if segue!.identifier == "showPlacePhotos" {
//        let country = Array(places.keys)[indexPath.section]
//        if let placeData = places[country]![indexPath.row] as? [String:String] {
//          var photosController = segue!.destinationViewController as FlickrPhotosTableViewController
//          photosController.placeId = placeData["place_id"]!
//          photosController.title = placeData["woe_name"]
//        }
//      }
//    }
//  }
  
  // MARK: Fetched Results Controller
  override var fetchedResultsController: NSFetchedResultsController {
    if _fetchedResultsController != nil {
      return _fetchedResultsController!
    }

    let fetchRequest = NSFetchRequest()
    // Edit the entity name as appropriate.
    let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: self.managedObjectContext!)
    fetchRequest.entity = entity

    // Set the batch size to a suitable number.
    fetchRequest.fetchBatchSize = 20

    // Edit the sort key as appropriate.
    let sortDescriptor = NSSortDescriptor(key: "id", ascending: false)
    let sortDescriptors = [sortDescriptor]

    fetchRequest.sortDescriptors = [sortDescriptor]

    let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
    aFetchedResultsController.delegate = self
    _fetchedResultsController = aFetchedResultsController

    var error: NSError? = nil
    if !_fetchedResultsController!.performFetch(&error) {
      println("Unresolved error \(error), \(error?.userInfo)")
      abort()
    }

    return _fetchedResultsController!
  }
  
}

// Creates a new Core Data stack and returns a managed object context associated with a private queue.
private func privateQueueContext(outError: NSErrorPointer) -> NSManagedObjectContext! {
  // It uses the same store and model, but a new persistent store coordinator and context.
  let localCoordinator = NSPersistentStoreCoordinator(managedObjectModel: CoreDataStackManager.sharedManager.managedObjectModel)
  var error: NSError?
  
  let persistentStore = localCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: CoreDataStackManager.sharedManager.storeURL, options: nil, error:&error)
  if persistentStore == nil {
    if outError != nil {
      outError.memory = error
    }
    return nil
  }
  
  let context = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
  context.persistentStoreCoordinator = localCoordinator
  context.undoManager = nil
  
  return context
}