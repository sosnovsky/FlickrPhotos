//
//  PhotoViewController.swift
//  FlickrPhotos
//
//  Created by Roma Sosnovsky on 6/20/14.
//  Copyright (c) 2014 Roma Sosnovsky. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController, UIScrollViewDelegate {

  @IBOutlet weak var spinnerView: UIActivityIndicatorView!
  let scrollView = UIScrollView()
  let imageView = UIImageView()
  
  var imageUrl: NSURL? {
    didSet {
      loadPhoto()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.addSubview(scrollView)
    scrollView.minimumZoomScale = 0.7
    scrollView.maximumZoomScale = 2.0
    scrollView.delegate = self
    scrollView.addSubview(imageView)
    imageView.hidden = true
    
    scrollView.setTranslatesAutoresizingMaskIntoConstraints(false)
    imageView.setTranslatesAutoresizingMaskIntoConstraints(false)
    
    var viewsDictionary: NSMutableDictionary = NSMutableDictionary()
    viewsDictionary.setValue(scrollView, forKey: "scrollView")
    viewsDictionary.setValue(imageView, forKey: "imageView")
    
    view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[scrollView]|", options: nil, metrics: nil, views: viewsDictionary))
    view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[scrollView]|", options: nil, metrics: nil, views: viewsDictionary))
    scrollView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[imageView]|", options: nil, metrics: nil, views: viewsDictionary))
    scrollView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[imageView]|", options: nil, metrics: nil, views: viewsDictionary))
    
    loadPhoto()
  }

  func viewForZoomingInScrollView(scrollView: UIScrollView!) -> UIView! {
    return imageView
  }
  
  func loadPhoto() {
    imageView.hidden = true
    if let url = imageUrl {
      spinnerView?.startAnimating()
      dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
        let imageData = NSData(contentsOfURL: self.imageUrl!, options: .DataReadingMappedIfSafe, error: nil)
        let image = UIImage(data: imageData!)
        dispatch_async(dispatch_get_main_queue(), {
          self.imageView.image = image
          self.imageView.hidden = false
          self.spinnerView?.stopAnimating()
        })
      })
    }
  }
  
}