//
//  FlickrFetcher.swift
//  FlickrPhotos
//
//  Created by Roma Sosnovsky on 6/14/14.
//  Copyright (c) 2014 Roma Sosnovsky. All rights reserved.
//

import Foundation

struct FlickrFetcher {
  let APIKey = FlickrAPIKey
  
  enum FlickrPhotoFormat: Int {
    case Square   = 1
    case Large    = 2
    case Original = 64
  }
  
  func URLForQuery(var query: String) -> NSURL {
    query += "&format=json&nojsoncallback=1&api_key=\(APIKey)"
    query = query.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
    return NSURL(string: query)!
  }
  
  func URLforTopPlaces() -> NSURL {
    return URLForQuery("https://api.flickr.com/services/rest/?method=flickr.places.getTopPlacesList&place_type_id=7")
  }
  
  func URLforPhotosInPlace(flickrPlaceId: String, maxResults: Int) -> NSURL {
    return URLForQuery("https://api.flickr.com/services/rest/?method=flickr.photos.search&place_id=\(flickrPlaceId)&per_page=\(maxResults)&extras=original_format,tags,description,geo,date_upload,owner_name,place_url")
  }
  
  func URLforRecentGeoreferencedPhotos() -> NSURL {
    return URLForQuery("https://api.flickr.com/services/rest/?method=flickr.photos.search&license=1,2,4,7&has_geo=1&extras=original_format,description,geo,date_upload,owner_name")
  }
  
  func urlStringForPhoto(photo: [String:AnyObject], format: FlickrPhotoFormat) -> String {
    let farm: AnyObject? = photo["farm"]
    let server : AnyObject? = photo["server"]
    let photo_id : AnyObject? = photo["id"]
    var secret : AnyObject? = photo["secret"]
    var fileType: AnyObject? = "jpg"
    if format == FlickrPhotoFormat.Original {
      secret = photo["originalsecret"]
      fileType = photo["originalformat"]
    }
    
    if (farm == nil || server == nil || photo_id == nil || secret == nil) {
      return ""
    }
    
    var formatString = "s"
    switch (format) {
    case .Square:
      formatString = "s"
    case .Large:
      formatString = "b"
    case .Original:
      formatString = "o"
    }
    
    return "http://farm\(farm!).static.flickr.com/\(server!)/\(photo_id!)_\(secret!)_\(formatString).\(fileType!)"
  }
  
  func URLforPhoto(photo: [String:AnyObject], format: FlickrPhotoFormat) -> NSURL {
    return NSURL(string: urlStringForPhoto(photo, format: format))!
  }
  
}

