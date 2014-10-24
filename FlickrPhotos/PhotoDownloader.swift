//
//  PhotoDownloader.swift
//  FlickrPhotos
//
//  Created by Roma Sosnovsky on 10/15/14.
//  Copyright (c) 2014 Roma Sosnovsky. All rights reserved.
//

import UIKit

class PhotoDownloader: NSObject {
  var photo: Photo
  var completionHandler: (Void -> Void)?
  var imageDownloadTask: NSURLSessionDownloadTask?
  
  let thumbnailSide = 48
  
  init (photo: Photo) {
    self.photo = photo
    super.init()
  }
  
  func startDownload() {
    let url = NSURL(string: self.photo.thumbnailURL)!
    imageDownloadTask = NSURLSession.sharedSession().downloadTaskWithURL(url) { location, response, error in
      let data = NSData(contentsOfURL: url)
      if let image = UIImage(data: data!) {
        let thumbnailSize = CGSize(width: self.thumbnailSide, height: self.thumbnailSide)
        
        if image.size.width != thumbnailSize.width || image.size.height != thumbnailSize.height {
          UIGraphicsBeginImageContextWithOptions(thumbnailSize, true, 0.0)
          let imageRect = CGRect(x: 0, y: 0, width: thumbnailSize.width, height: thumbnailSize.height)
          image.drawInRect(imageRect)
          let newImage = UIGraphicsGetImageFromCurrentImageContext()
          self.photo.thumbnail = UIImageJPEGRepresentation(newImage, 0)
          UIGraphicsEndImageContext()
        } else {
          self.photo.thumbnail = UIImageJPEGRepresentation(image, 0)
        }
        
        CoreDataStackManager.sharedManager.saveContext()
      }
      
      if self.completionHandler != nil {
        self.completionHandler!()
      }
    }
    imageDownloadTask?.resume()
  }
  
  func cancelDownload() {
    imageDownloadTask?.cancelByProducingResumeData() { data in }
  }
  
}