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
import SCLAlertView

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

    func downloadPoster(i:Int) {
            
        TMDBClient.sharedInstance.getMoviePoster((self.u.tinderArray[i].posterURL)! as String, completion: {(data,error) in
            
            if error {
                SCLAlertView().showError("Connection Error", subTitle: "Please check your internet connection and try again.", closeButtonTitle:"OK")
                return
            }
            
            let path = "\(self.pickedEmoji)\((self.u.tinderArray[i].title!))"
            let documentsDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
            let totalPath:String = documentsDirectoryURL.URLByAppendingPathComponent(path as String).path!
            self.u.tinderArray[i].posterPath = totalPath
            
            let image = UIImage(data: data)
            let result = UIImageJPEGRepresentation(image!, 0.0)!
            result.writeToFile(totalPath as String, atomically: true)
            
            CoreDataStackManager.sharedInstance().saveContext()
            //self.u.loadedArray.append(self.u.tinderArray[i])
            
            dispatch_async(dispatch_get_main_queue(), {
                self.kolodaView?.reloadCardsInIndexRange(i...i)
            })
        })
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        CoreDataStackManager.sharedInstance().saveContext()
        activityIndicator.stopAnimating()
        activityIndicator.hidden = true
    }

}

//MARK: KolodaViewDelegate
extension Tinder2VC: KolodaViewDelegate {
    
    func kolodaDidRunOutOfCards(koloda: KolodaView) {
        //kolodaView.resetCurrentCardIndex()
        noMoreLabel.hidden = false
    }
    
    func koloda(koloda: KolodaView, didSelectCardAtIndex index: UInt) {
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
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
            self.u.tinderArray[Int(index)].swiped = 1
        } else if direction == .Right {
            self.u.tinderArray[Int(index)].swiped = 2
        }
        
        self.u.tinderArray[Int(index)].date = NSDate()
        CoreDataStackManager.sharedInstance().saveContext()
        if Int(index)+2 <= self.u.tinderArray.count - 1 {
//            self.u.loadedArray.append(self.u.tinderArray[Int(index)+2])
//            kolodaView.reloadData()
            
            //downloadPoster(Int(index)+2)
        }
    }
}

//MARK: KolodaViewDataSource
extension Tinder2VC: KolodaViewDataSource {
    
    func kolodaNumberOfCards(koloda: KolodaView) -> UInt {
        return UInt(self.u.tinderArray.count)
    }
    
    func koloda(koloda: KolodaView, viewForCardAtIndex index: UInt) -> UIView {
        
        // print(self.u.tinderArray)
        var placeholder = UIImageView(image: UIImage(named: "cards_1"))
        
        if let _ = self.u.tinderArray[Int(index)].posterPath {
            let data = NSData(contentsOfFile: (self.u.tinderArray[Int(index)].posterPath)! as String)
            let image = UIImage(data: data!)
            let imageView = UIImageView(image: image)
            imageView.layer.cornerRadius = 10
            imageView.layer.masksToBounds = true
            return imageView
        
        } else {
            
            downloadPoster(Int(index))
            
        }

        return placeholder
        
    }
    
    func koloda(koloda: KolodaView, viewForCardOverlayAtIndex index: UInt) -> OverlayView? {
        return NSBundle.mainBundle().loadNibNamed("CustomOverlayView",
            owner: self, options: nil)[0] as? OverlayView
    }
}
