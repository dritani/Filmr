//
//  CollectionViewController.swift
//  CircularCollectionView
//
//  Created by Rounak Jain on 10/05/15.
//  Copyright (c) 2015 Rounak Jain. All rights reserved.
//

import UIKit
import SCLAlertView

let reuseIdentifier = "Cell"

class CollectionViewController: UICollectionViewController  {
  
    let u:User = User.sharedInstance as User
    var sourceCell: UICollectionViewCell?
    var empty:Bool = false
    
    let images: [String] = NSBundle.mainBundle().pathsForResourcesOfType("png", inDirectory: "Images")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Register cell classes
        collectionView!.registerNib(UINib(nibName: "CircularCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        let imageView = UIImageView(image: UIImage(named: "bg2.jpg"))
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        collectionView!.backgroundView = imageView
        self.navigationController?.delegate = self
    }
  
    
    override func viewWillAppear(animated: Bool) {
        collectionView?.reloadData()
    }
    override func collectionView(collectionView: UICollectionView,
                               numberOfItemsInSection section: Int) -> Int {
        
        //return images.count
        var swipedArray:[Movie] = u.moodsToSwiped(&u.Moods)
        
        if swipedArray.count == 0 {
            empty = true
            return 1
        } else {
            empty = false
            return swipedArray.count
        }
    }

  override func collectionView(collectionView: UICollectionView,
                               cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CircularCollectionViewCell
    
    let placeholder = UIImage(named: "cards_1")
    cell.imageView!.image = placeholder
    
    var swipedArray:[Movie] = u.moodsToSwiped(&u.Moods)
    let movie = swipedArray[indexPath.item]
    
    if let _ = movie.posterPath {
        let data = NSData(contentsOfFile: (movie.posterPath)! as String)
        let image = UIImage(data: data!)
        cell.imageView!.image = image
        return cell
    } else {
        downloadPoster(indexPath.item)
    }
    
    return cell

  }
    
    func downloadPoster(i:Int) {
        
        var swipedArray:[Movie] = u.moodsToSwiped(&u.Moods)
        let movie = swipedArray[i]
        
        TMDBClient.sharedInstance.getMoviePoster((movie.posterURL)! as String, completion: {(data,error) in
            
            if error {
                SCLAlertView().showError("Connection Error", subTitle: "Please check your internet connection and try again.", closeButtonTitle:"OK")
                return
            }
            
            let path = "\(movie.emoji)\((movie.title!))"
            let documentsDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
            let totalPath:String = documentsDirectoryURL.URLByAppendingPathComponent(path as String).path!
            self.u.tinderArray[i].posterPath = totalPath
            
            let image = UIImage(data: data)
            let result = UIImageJPEGRepresentation(image!, 0.0)!
            result.writeToFile(totalPath as String, atomically: true)
            
            CoreDataStackManager.sharedInstance().saveContext()
            //self.u.loadedArray.append(self.u.tinderArray[i])
            
            dispatch_async(dispatch_get_main_queue(), {
                self.collectionView?.reloadItemsAtIndexPaths([NSIndexPath(index: i)])
            })
        })
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        self.performSegueWithIdentifier("toDetail2", sender: cell)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destinationViewController as! Detail2VC
        let cell = sender as! CircularCollectionViewCell
        // This next line is very importat for the proper functioning of the animation:
        // the sourceCell property tells the animator which is the cell involved in the transition
        sourceCell = cell
        vc.image = cell.imageView!.image
    }
}

//MARK: UINavigationControllerDelegate
extension CollectionViewController: UINavigationControllerDelegate {
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        // In this method belonging to the protocol UINavigationControllerDelegate you must
        // return an animator conforming to the protocol UIViewControllerAnimatedTransitioning.
        // To perform the Pop in and Out animation PopInAndOutAnimator should be returned
        return PopInAndOutAnimator(operation: operation)
    }
}

//MARK: CollectionPushAndPoppable
extension CollectionViewController: CollectionPushAndPoppable {}
