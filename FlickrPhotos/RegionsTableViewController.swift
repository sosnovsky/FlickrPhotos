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
  
  // MARK: Properties
  
  private var regions = [Region]()

  // MARK: View Life Cycle

  override func viewDidLoad() {
    super.viewDidLoad()
//    fetchRecentGeoreferencedPhotos()
  }
  
  // MARK: Core Data Batching
  
  func fetchRecentGeoreferencedPhotos() {
    let jsonURL = flickrFetcher.URLforRecentGeoreferencedPhotos()
    
    let sessionConfiguration = NSURLSessionConfiguration.ephemeralSessionConfiguration()
    let session = NSURLSession(configuration: sessionConfiguration)
    
    let task = session.dataTaskWithURL(jsonURL) { data, response, error in
      
      if error != nil {
        println("Error connecting: \(error.description)")
        fatalError("Couldn't create connection to server.")
        return
      }
      
      var anyError: NSError?
      let jsonDictionary = NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers, error: &anyError) as? [String: AnyObject]
      
      if jsonDictionary == nil {
        println("Error creating JSON dictionary: \(anyError)")
        fatalError("Couldn't create JSON dictionary.")
        
        return
      }
      
      var photos = jsonDictionary!["photos"]!["photo"]! as [[String: AnyObject]]

      let matchingPhotoRequest = NSFetchRequest(entityName: "Photo")
      
      // Get the ids for each of the photo and store them in an array.
      let ids = photos.map { $0["id"]! as String }
      matchingPhotoRequest.predicate = NSPredicate(format: "id in %@", argumentArray: [ids])
      
      let matchingPhotos = self.managedObjectContext.executeFetchRequest(matchingPhotoRequest, error: &anyError) as? [Photo]
      if matchingPhotos == nil {
        println("Error fetching: \(anyError)")
        fatalError("Fetch failed.")
        return
      }
      
      // Create a dictionary to map from a code to the corresponding matched quake.
      let matchingPhotosIds = matchingPhotos!.map { $0.id as String }
      var placesData = [[String: String]]()
      
      for photoDictionary in photos {
        let id = photoDictionary["id"]! as String
        
        if !contains(matchingPhotosIds, id) {
          let photo = NSEntityDescription.insertNewObjectForEntityForName("Photo", inManagedObjectContext: self.managedObjectContext) as Photo
          photo.updateFromDictionary(photoDictionary, context: self.managedObjectContext)
          let placeId = photoDictionary["place_id"]! as String
          let photographerName = photoDictionary["ownername"]! as String
          let placeDictionary = ["place_id": placeId, "photographer": photographerName]
          placesData.append(placeDictionary)
        }
      }
      
      if !self.managedObjectContext.save(&anyError) {
        println("Error saving batch: \(anyError)")
        fatalError("Saving batch failed.")
        return
      }
      
      self.getRegionsFromPlaces(placesData)
      
      // Bounce back to the main queue to reload the table view
      NSOperationQueue.mainQueue().addOperationWithBlock {
        self.reloadTableView(nil)
      }
    }
    
    task.resume()
  }
  
  func getRegionsFromPlaces(placesData: [[String: String]]) {
    var regions = [String: [String:[String]]]()
    var requestCount = 0
    for place in placesData {
      let placeId = place["place_id"]! as String
      let url = flickrFetcher.URLforInformationAboutPlace(placeId)
      let session = NSURLSession(configuration: NSURLSessionConfiguration.ephemeralSessionConfiguration())
      let task = session.dataTaskWithURL(url) { data, response, error in
        if data == nil {
          println("Error connecting: \(error)")
          fatalError("Couldn't create connection to server.")
          return
        }
        
        var anyError: NSError?
        
        let placeDictionary = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &anyError) as? [String: AnyObject]
        
        if placeDictionary == nil {
          println("Error creating JSON dictionary: \(anyError)")
          fatalError("Couldn't create JSON dictionary.")
          
          return
        }
        
        if let regionData = placeDictionary!["place"]!["region"] as? [String: String] {
          let regionName = regionData["_content"]!
          let photographerName = place["photographer"]! as String
          if var existingRegion = regions[regionName] {
            existingRegion["photographers"]!.append(photographerName)
            existingRegion["places"]!.append(placeId)
            regions[regionName] = existingRegion
          } else {
            regions[regionName] = ["photographers": [photographerName], "places": [placeId]]
          }
        }
        
        if ++requestCount == placesData.count {
          self.addRegionsToDatabase(regions)
        }
      }
      
      task.resume()
    }
  }
  
  func addRegionsToDatabase(regionsData: [String: [String:[String]]]) {
    for (region, regionData) in regionsData {
      let savedRegion = Region.withName(region, context: self.managedObjectContext)
      
      for photographer in regionData["photographers"]! {
        let savedPhotograpger = Photographer.withName(photographer, context: self.managedObjectContext)
        savedRegion.addPhotographer(savedPhotograpger)
      }
      for placeId in regionData["places"]! {
        let savedPlace = Place.withId(placeId, context: self.managedObjectContext)
        savedRegion.addPlace(savedPlace)
      }
    }
    
    var anyError: NSError?
    
    if !self.managedObjectContext.save(&anyError) {
      println("Error saving batch: \(anyError)")
      fatalError("Saving batch failed.")
      return
    }
  }
  
  // MARK: Convenience
  
  /// Fetch quakes ordered in time and reload the table view.
  private func reloadTableView(sender: AnyObject?) {
    let request = NSFetchRequest(entityName: "Region")
    request.sortDescriptors = [NSSortDescriptor(key: "photographersCount", ascending: false)]
    
    var anyError: NSError?
    
    let fetchedRegions = self.managedObjectContext.executeFetchRequest(request, error: &anyError)
    
    if fetchedRegions == nil {
      println("Error fetching: \(anyError)")
      fatalError("Fetch failed.")
      return
    }
    
    regions = fetchedRegions as [Region]
    
    tableView.reloadData()
  }
  
  // MARK: - Segues
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showRegionPhotos" {
      if let indexPath = self.tableView.indexPathForSelectedRow() {
        let region = self.fetchedResultsController.objectAtIndexPath(indexPath) as Region
        let controller = segue.destinationViewController as FlickrPhotosTableViewController
        controller.region = region
        controller.navigationItem.title = region.name
        controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
        controller.navigationItem.leftItemsSupplementBackButton = true
      }
    }
  }
  
  // MARK: Table View Controller
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Region Cell", forIndexPath: indexPath) as UITableViewCell
    self.configureCell(cell, atIndexPath: indexPath)
    return cell
  }
  
  override func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
    let region = self.fetchedResultsController.objectAtIndexPath(indexPath) as Region
    cell.textLabel?.text = region.name
    cell.detailTextLabel?.text = "\(region.photographersCount) photographers"
  }
  
  // MARK: Fetched Results Controller
  override var fetchedResultsController: NSFetchedResultsController {
    if _fetchedResultsController != nil {
      return _fetchedResultsController!
    }

    let fetchRequest = NSFetchRequest()
    // Edit the entity name as appropriate.
    let entity = NSEntityDescription.entityForName("Region", inManagedObjectContext: self.managedObjectContext)
    fetchRequest.entity = entity

    // Set the batch size to a suitable number.
    fetchRequest.fetchBatchSize = 50

    // Edit the sort key as appropriate.
    let sortDescriptor = NSSortDescriptor(key: "photographersCount", ascending: false)
    let sortDescriptors = [sortDescriptor]

    fetchRequest.sortDescriptors = [sortDescriptor]

    let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
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
