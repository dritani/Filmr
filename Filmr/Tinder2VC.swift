//
//  BackgroundAnimationViewController.swift
//  Koloda
//
//  Created by Eugene Andreyev on 7/11/15.
//  Copyright (c) 2015 CocoaPods. All rights reserved.
//

import UIKit
import Koloda
import pop

private let numberOfCards: UInt = 5
private let frameAnimationSpringBounciness: CGFloat = 9
private let frameAnimationSpringSpeed: CGFloat = 16
private let kolodaCountOfVisibleCards = 2
private let kolodaAlphaValueSemiTransparent: CGFloat = 0.1

class Tinder2VC: UIViewController {

    @IBOutlet weak var kolodaView: CustomKolodaView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var noMoreLabel: UILabel!
    
    var pickedEmoji:String!
    let u:User = User.sharedInstance as User
    var undoButton:UIBarButtonItem!
    
    // BubbleTransition
    @IBAction func closeAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        UIApplication.sharedApplication().statusBarStyle = .LightContent
    }
    
    override func viewWillDisappear(animated: Bool) {
        UIApplication.sharedApplication().statusBarStyle = .Default
    }
    
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        kolodaView.alphaValueSemiTransparent = kolodaAlphaValueSemiTransparent
        kolodaView.countOfVisibleCards = kolodaCountOfVisibleCards
        kolodaView.delegate = self
        kolodaView.dataSource = self
        kolodaView.animator = BackgroundKolodaAnimator(koloda: kolodaView)
        
        self.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
        
        let u = User.sharedInstance as User
        TMDBClient.sharedInstance().viewController = self
        
        activityIndicator.hidden = true
        noMoreLabel.hidden = true
        closeButton.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_4))
    }
    
    
    //MARK: IBActions
    @IBAction func leftButtonTapped() {
        kolodaView?.swipe(SwipeResultDirection.Left)
    }
    
    @IBAction func rightButtonTapped() {
        kolodaView?.swipe(SwipeResultDirection.Right)
    }
    
    @IBAction func undoButtonTapped() {
        kolodaView?.revertAction()
    }
    
    func downloadBackdrop(i:Int) {
        TMDBClient.sharedInstance().getMovieBackdrop((self.u.loadedArray[i].backdropURL)! as String, completion: {(data) in
            let path = "\(self.pickedEmoji)B\((self.u.loadedArray[i].title!))"
            let documentsDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
            let totalPath:String = documentsDirectoryURL.URLByAppendingPathComponent(path as String).path!
            self.u.tinderArray[i].backdropPath = totalPath
            
            let image = UIImage(data: data)
            let result = UIImageJPEGRepresentation(image!, 0.0)!
            result.writeToFile(totalPath as String, atomically: true)
            CoreDataStackManager.sharedInstance().saveContext()
            dispatch_async(dispatch_get_main_queue(), {
                self.performSegueWithIdentifier("toDetail", sender: self.u.loadedArray[i])
            })
        })
    }
    
    func downloadPoster(i:Int) {
        TMDBClient.sharedInstance().getMovieInfo((self.u.tinderArray[i]), completion: {(complete,synopsis,posterURL,backdropURL,vote) in
            
            if complete == false {
                self.alert("The connection failed.", viewController: self)
            }
            
            self.u.tinderArray[i].synopsis = synopsis
            self.u.tinderArray[i].posterURL = posterURL
            self.u.tinderArray[i].backdropURL = backdropURL
            self.u.tinderArray[i].vote = vote
            
            TMDBClient.sharedInstance().getMoviePoster((self.u.tinderArray[i].posterURL)! as String, completion: {(data) in
                
                let path = "\(self.pickedEmoji)\((self.u.tinderArray[i].title!))"
                let documentsDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
                let totalPath:String = documentsDirectoryURL.URLByAppendingPathComponent(path as String).path!
                self.u.tinderArray[i].posterPath = totalPath
                
                let image = UIImage(data: data)
                let result = UIImageJPEGRepresentation(image!, 0.0)!
                result.writeToFile(totalPath as String, atomically: true)
                CoreDataStackManager.sharedInstance().saveContext()
                
                self.u.loadedArray.append(self.u.tinderArray[i])
                dispatch_async(dispatch_get_main_queue(), {
                    self.kolodaView?.reloadData()
                })
            })
        })
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let detailVC = segue.destinationViewController as! DetailVC
        let data = sender as! Movie
        detailVC.movie = data
        CoreDataStackManager.sharedInstance().saveContext()
        activityIndicator.stopAnimating()
        activityIndicator.hidden = true
    }
    
    func alert(message: String, viewController: UIViewController) {
        
        let alertController = UIAlertController(title: "Error", message: "\(message)", preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            // ...
        }
        alertController.addAction(cancelAction)
        
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            // ...
        }
        alertController.addAction(OKAction)
        
        viewController.presentViewController(alertController, animated: true) {
            // ...
        }
        
    }

}

//MARK: KolodaViewDelegate
extension Tinder2VC: KolodaViewDelegate {
    
    func kolodaDidRunOutOfCards(koloda: KolodaView) {
        kolodaView.resetCurrentCardIndex()
        noMoreLabel.hidden = false
    }
    
    func koloda(koloda: KolodaView, didSelectCardAtIndex index: UInt) {
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        downloadBackdrop(Int(index))
    }
    
    func kolodaShouldApplyAppearAnimation(koloda: KolodaView) -> Bool {
        return true
    }
    
    func kolodaShouldMoveBackgroundCard(koloda: KolodaView) -> Bool {
        return false
    }
    
    func kolodaShouldTransparentizeNextCard(koloda: KolodaView) -> Bool {
        return true
    }
    
    func koloda(kolodaBackgroundCardAnimation koloda: KolodaView) -> POPPropertyAnimation? {
        let animation = POPSpringAnimation(propertyNamed: kPOPViewFrame)
        animation.springBounciness = frameAnimationSpringBounciness
        animation.springSpeed = frameAnimationSpringSpeed
        return animation
    }
    
    func koloda(koloda: KolodaView, didSwipeCardAtIndex index: UInt, inDirection direction: SwipeResultDirection) {
        if direction == .Left {
            self.u.loadedArray[Int(index)].swiped = 1
        } else if direction == .Right {
            self.u.loadedArray[Int(index)].swiped = 2
        }
        
        CoreDataStackManager.sharedInstance().saveContext()
        self.u.loadedArray[Int(index)].date = NSDate()
        
        if Int(index)+2 <= self.u.tinderArray.count - 1 {
            downloadPoster(Int(index)+2)
        }
    }
}

//MARK: KolodaViewDataSource
extension Tinder2VC: KolodaViewDataSource {
    
    func kolodaNumberOfCards(koloda: KolodaView) -> UInt {
        return UInt(self.u.loadedArray.count)
    }
    
    func koloda(koloda: KolodaView, viewForCardAtIndex index: UInt) -> UIView {
        var image2:UIImage!
        
        if NSFileManager.defaultManager().fileExistsAtPath(self.u.loadedArray[Int(index)].posterPath as! String) {
            let data = NSData(contentsOfFile: (self.u.loadedArray[Int(index)].posterPath)! as String)
            let image = UIImage(data: data!)
            return UIImageView(image: image)
        } else {
            TMDBClient.sharedInstance().getMoviePoster((self.u.loadedArray[Int(index)].posterURL)! as String, completion: {(data) in
                
                let path = "\(self.u.loadedArray[Int(index)].emoji)\((self.u.loadedArray[Int(index)].title!))"
                let documentsDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
                let totalPath:String = documentsDirectoryURL.URLByAppendingPathComponent(path as String).path!
                
                self.u.loadedArray[Int(index)].posterPath = totalPath
                
                let image = UIImage(data: data)
                let result = UIImageJPEGRepresentation(image!, 0.0)!
                result.writeToFile(totalPath as String, atomically: true)
                dispatch_async(dispatch_get_main_queue(), {
                    image2 = image
                })
            })
        }
        return UIImageView(image: image2)
    }
    
    func koloda(koloda: KolodaView, viewForCardOverlayAtIndex index: UInt) -> OverlayView? {
        return NSBundle.mainBundle().loadNibNamed("CustomOverlayView",
            owner: self, options: nil)[0] as? OverlayView
    }
}
