/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:

Singleton controller to manage the main Core Data stack for the application. It vends a persistent store coordinator, and for convenience the managed object model and URL for the persistent store and application documents directory.

*/

import UIKit
import CoreData

class CoreDataStackManager {
  
  // MARK: Properties
  
  class var sharedManager: CoreDataStackManager {
    struct Singleton {
      static let coreDataStackManager = CoreDataStackManager()
    }
    
    return Singleton.coreDataStackManager
  }
  
  lazy var applicationDocumentsDirectory: NSURL = {
    // The directory the application uses to store the Core Data store file
    let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
    return urls[urls.count-1] as NSURL
    }()
  
  lazy var managedObjectModel: NSManagedObjectModel = {
    // The managed object model for the application
    let modelURL = NSBundle.mainBundle().URLForResource("FlickrPhotos", withExtension: "momd")!
    return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
  
  lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
    // The persistent store coordinator for the application
    var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
    let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("FlickrPhotos.sqlite")
    var error: NSError? = nil
    var failureReason = "There was an error creating or loading the application's saved data."
    if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
      coordinator = nil
      // Report any error we got.
      let dict = NSMutableDictionary()
      dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
      dict[NSLocalizedFailureReasonErrorKey] = failureReason
      dict[NSUnderlyingErrorKey] = error
      error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
      NSLog("Unresolved error \(error), \(error!.userInfo)")
      abort()
    }
    
    return coordinator
    }()
  
  lazy var managedObjectContext: NSManagedObjectContext? = {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
    let coordinator = self.persistentStoreCoordinator
    if coordinator == nil {
      return nil
    }
    var managedObjectContext = NSManagedObjectContext()
    managedObjectContext.persistentStoreCoordinator = coordinator
    return managedObjectContext
    }()
  
  /// URL for the main Core Data store file.
  lazy var storeURL: NSURL = {
      return self.applicationDocumentsDirectory.URLByAppendingPathComponent("FlickrPhotos")
    }()
  
  // MARK: - Core Data Saving support
  
  func saveContext () {
    if let moc = self.managedObjectContext {
      var error: NSError? = nil
      if moc.hasChanges && !moc.save(&error) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog("Unresolved error \(error), \(error!.userInfo)")
        abort()
      }
    }
  }
}
