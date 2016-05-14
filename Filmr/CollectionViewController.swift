//
//  CollectionViewController.swift
//  CircularCollectionView
//
//  Created by Rounak Jain on 10/05/15.
//  Copyright (c) 2015 Rounak Jain. All rights reserved.
//

import UIKit

let reuseIdentifier = "Cell"

class CollectionViewController: UICollectionViewController,ZoomTransitionProtocol, UINavigationControllerDelegate {
  
  let images: [String] = NSBundle.mainBundle().pathsForResourcesOfType("png", inDirectory: "Images") 
  
    var animationController : ZoomTransition?;
    
    var ind:Int!
    
  override func viewDidLoad() {
    super.viewDidLoad()
    // Register cell classes
    collectionView!.registerNib(UINib(nibName: "CircularCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
    let imageView = UIImageView(image: UIImage(named: "bg2.jpg"))
    imageView.contentMode = UIViewContentMode.ScaleAspectFill
    collectionView!.backgroundView = imageView
    
    if let navigationController = self.navigationController {
        animationController = ZoomTransition(navigationController: navigationController)
    }
    self.navigationController?.delegate = animationController
  }
    
    func viewForTransition() -> UIView {
        return UIImageView(image: UIImage(named: images[ind]))
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        ind = indexPath.row
        var controller: Detail2VC
        controller = self.storyboard?.instantiateViewControllerWithIdentifier("Detail2VC") as! Detail2VC
        controller.imageView.image = UIImage(named: images[indexPath.row])
        self.navigationController?.pushViewController(controller, animated: true)
    }
  override func collectionView(collectionView: UICollectionView,
                               numberOfItemsInSection section: Int) -> Int {
    return images.count
  }
  
  override func collectionView(collectionView: UICollectionView,
                               cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CircularCollectionViewCell
    cell.imageName = images[indexPath.row]
    return cell
  }
}


