//
//  FlickrPlacesTableViewController.swift
//  FlickrPhotos
//
//  Created by Roma Sosnovsky on 6/14/14.
//  Copyright (c) 2014 Roma Sosnovsky. All rights reserved.
//

import UIKit

class FlickrPlacesTableViewController: UITableViewController {
  
  var places = [String:NSMutableArray]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    fetchPlaces()
  }
  
  func fetchPlaces() {
    refreshControl?.beginRefreshing()
    let placesUrl = FlickrFetcher.shared.URLforTopPlaces()
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
      let data = NSData(contentsOfURL: placesUrl)
      
      let propertyListResults = NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers, error: nil) as [String:AnyObject]
      if let placesDict = propertyListResults["places"] as? NSDictionary {
        if let placesArray = placesDict["place"] as? NSArray {
          self.updatePlaces(placesArray)
        }
      }
      
      self.refreshControl?.endRefreshing()
    })
  }
  
  func updatePlaces(placesData: NSArray) {
    places = [:]
    var count = 0
    
    for place in placesData {
      let placeData = place["_content"] as String
      let geoData = placeData.componentsSeparatedByString(", ")
      let country = geoData[geoData.count - 1]
      if let placeCountry = places[country] {
        places[country]!.addObject(place)
      } else {
        places[country] = NSMutableArray(array: [place])
      }
    }
    
    tableView.reloadData()
  }
  
  // #pragma mark - Table view data source
  
  override func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
    return places.count
  }
  
  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return Array(places.keys)[section]
  }

  override func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
    let country = Array(places.keys)[section]
    if let citiesCount = places[country]?.count {
      return citiesCount
    }
    return 0
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("flickrPlaceCell", forIndexPath: indexPath) as UITableViewCell
    let section = indexPath.section
    let row = indexPath.row
    let country = Array(places.keys)[section]
    if let place = places[country]![row] as? [String:String] {
      var placeData = place["_content"]?.componentsSeparatedByString(", ")
      cell.textLabel?.text = place["woe_name"]
      cell.detailTextLabel?.text = placeData![1]
    }
    
    return cell
  }
  
  // #pragma mark - Navigation
  
  override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
    if let indexPath = tableView.indexPathForSelectedRow() {
      if segue!.identifier == "showPlacePhotos" {
        let country = Array(places.keys)[indexPath.section]
        if let placeData = places[country]![indexPath.row] as? [String:String] {
          var photosController = segue!.destinationViewController as FlickrPhotosTableViewController
          photosController.placeId = placeData["place_id"]!
          photosController.title = placeData["woe_name"]
        }
      }
    }
  }
  
}
