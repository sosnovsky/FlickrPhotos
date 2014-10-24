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
    
    fetchRequest.entity = NSEntityDescription.entityForName("Region", inManagedObjectContext: self.managedObjectContext)
    
    let sortDescriptor = NSSortDescriptor(key: "photographersCount", ascending: false)
    fetchRequest.sortDescriptors = [sortDescriptor]
    
    cellIdentifier = "RegionCell"
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    fetchRecentGeoreferencedPhotos()
  }
  
  // MARK: Core Data Batching
  
  func fetchRecentGeoreferencedPhotos() {
    let jsonURL = flickrFetcher.URLforRecentGeoreferencedPhotos()
    
    let sessionConfiguration = NSURLSessionConfiguration.ephemeralSessionConfiguration()
    let session = NSURLSession(configuration: sessionConfiguration)
    
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    
    let task = session.dataTaskWithURL(jsonURL) { data, response, error in
      
      UIApplication.sharedApplication().networkActivityIndicatorVisible = false
      
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
      
      let photos = jsonDictionary!["photos"]!["photo"]! as [[String: AnyObject]]
      let ids = photos.map { $0["id"]! as String }
      
      let matchingPhotoRequest = NSFetchRequest(entityName: "Photo")
      matchingPhotoRequest.predicate = NSPredicate(format: "id in %@", argumentArray: [ids])
      
      let matchingPhotos = self.managedObjectContext.executeFetchRequest(matchingPhotoRequest, error: &anyError) as? [Photo]
      if matchingPhotos == nil {
        println("Error fetching: \(anyError)")
        fatalError("Fetch failed.")
        return
      }

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
      UIApplication.sharedApplication().networkActivityIndicatorVisible = true
      let task = session.dataTaskWithURL(url) { data, response, error in
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        
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
    
    if !managedObjectContext.save(&anyError) {
      println("Error saving batch: \(anyError)")
      fatalError("Saving batch failed.")
      return
    }
  }
  
  // MARK: Convenience
  
  private func reloadTableView(sender: AnyObject?) {
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
        let controller = segue.destinationViewController as FlickrPhotosTableViewController
        controller.region = region
        controller.navigationItem.title = region.name
        controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem()
        controller.navigationItem.leftItemsSupplementBackButton = true
      }
    }
  }
  
  // MARK: Table View Controller
  override func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
    let region = self.fetchedResultsController.objectAtIndexPath(indexPath) as Region
    cell.textLabel.text = region.name
    cell.detailTextLabel?.text = "\(region.photographersCount) photographers"
  }
  
}
