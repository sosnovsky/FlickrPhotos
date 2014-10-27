//
//  AppDelegate.swift
//  FlickrPhotos
//
//  Created by Roma Sosnovsky on 9/14/14.
//  Copyright (c) 2014 Roma Sosnovsky. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

  var window: UIWindow?
  
  lazy var flickrFetcher: FlickrFetcher = {
    return FlickrFetcher.shared
    }()
  
  lazy var managedObjectContext: NSManagedObjectContext = {
    let moc = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
    moc.persistentStoreCoordinator = CoreDataStackManager.sharedManager.persistentStoreCoordinator
    
    return moc
    }()
  
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    let splitViewController = window!.rootViewController as UISplitViewController
    
    let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as UINavigationController
    navigationController.topViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem()
    
    splitViewController.delegate = self
    splitViewController.preferredDisplayMode = .AllVisible
    
    fetchRecentGeoreferencedPhotos()

    return true
  }

  func applicationWillResignActive(application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }
  
  // MARK: Data fetching
  
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
      
      // Create dictionary from received JSON
      let jsonDictionary = NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers, error: &anyError) as? [String: AnyObject]
      
      if jsonDictionary == nil {
        println("Error creating JSON dictionary: \(anyError)")
        fatalError("Couldn't create JSON dictionary.")
        return
      }
      
      // Get ids of photos already added to database
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
      
      // Add photos to database and gather information about places
      var placesData = [[String: String]]()
      for photoDictionary in photos {
        let id = photoDictionary["id"]! as String
        if let placeId = photoDictionary["place_id"] as? String {
          if !contains(matchingPhotosIds, id) {
            Photo.createFromDictionary(photoDictionary, context: self.managedObjectContext)
            let photographerName = photoDictionary["ownername"]! as String
            let placeDictionary = ["place_id": placeId, "photographer": photographerName]
            placesData.append(placeDictionary)
          }
        }
      }
      
      if !self.managedObjectContext.save(&anyError) {
        println("Error saving batch: \(anyError)")
        fatalError("Saving batch failed.")
        return
      }
      
      self.getRegionsFromPlaces(placesData)
      
//      NSNotificationCenter.defaultCenter().
      // Bounce back to the main queue to reload the table view
//      NSOperationQueue.mainQueue().addOperationWithBlock {
//        self.reloadTableView()
//      }
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
      
      // Request for additional information about place
      let task = session.dataTaskWithURL(url) { data, response, error in
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        
        if data == nil {
          println("Error connecting: \(error)")
          fatalError("Couldn't create connection to server.")
          return
        }
        
        var anyError: NSError?
        
        // Create dictionary from received JSON
        let placeDictionary = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &anyError) as? [String: AnyObject]
        
        if placeDictionary == nil {
          println("Error creating JSON dictionary: \(anyError)")
          fatalError("Couldn't create JSON dictionary.")
          
          return
        }
        
        // Add information about region to array
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
        
        // Check if this is last request
        if ++requestCount == placesData.count {
          self.addRegionsToDatabase(regions)
        }
        
      }
      
      task.resume()
    }
  }
  
  func addRegionsToDatabase(regionsData: [String: [String:[String]]]) {
    for (region, regionData) in regionsData {
      let savedRegion = Region.withName(region, context: managedObjectContext)
      
      for photographer in regionData["photographers"]! {
        let savedPhotograpger = Photographer.withName(photographer, context: managedObjectContext)
        savedRegion.addPhotographer(savedPhotograpger)
      }
      for placeId in regionData["places"]! {
        let savedPlace = Place.withId(placeId, context: managedObjectContext)
        savedRegion.addPlace(savedPlace)
      }
    }
    
    var anyError: NSError?
    
    if !managedObjectContext.save(&anyError) {
      println("Error saving batch: \(anyError)")
      fatalError("Saving batch failed.")
      return
    }
    
    NSNotificationCenter.defaultCenter().postNotificationName("regionsDataUpdated", object: nil)
  }

  // MARK: - Split view

  func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController:UIViewController!, ontoPrimaryViewController primaryViewController:UIViewController!) -> Bool {
      if let secondaryAsNavController = secondaryViewController as? UINavigationController {
          if let topAsDetailController = secondaryAsNavController.topViewController as? PhotoViewController {
              if topAsDetailController.imageUrl == nil {
                  return true
              }
          }
      }
      return false
  }

}

