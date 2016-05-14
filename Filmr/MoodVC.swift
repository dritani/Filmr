//
//  MoodVC
//  Filmr
//
//  Created by Dritani on 2016-04-01.
//  Copyright © 2016 AquariusLB. All rights reserved.
//

import UIKit
import CoreData
import SCLAlertView
import BubbleTransition

class MoodVC: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UIViewControllerTransitioningDelegate {
    
    var emojis: [String]!
    var tinderArray:[Movie] = []
    var loadedArray:[Movie]! = []
    var pickedEmoji:String!
    
    let u:User = User.sharedInstance as User
    let transition = BubbleTransition()
    
    @IBOutlet weak var transitionButton: UIButton!
    
    @IBOutlet weak var dotOne: UIImageView!
    @IBOutlet weak var dotTwo: UIImageView!
    @IBOutlet weak var dotThree: UIImageView!
    
    @IBOutlet weak var resetLabel: UILabel!
    @IBOutlet weak var pickerView: UIPickerView!
    
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var iFeelLabel: UILabel!
    @IBOutlet weak var movieLabel: UILabel!
    
    @IBOutlet weak var preferencesLabel: UILabel!
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()


    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .Present
        transition.startingPoint = transitionButton.center
        transition.bubbleColor = transitionButton.backgroundColor!
        return transition
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .Dismiss
        transition.startingPoint = transitionButton.center
        transition.bubbleColor = transitionButton.backgroundColor!
        return transition
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //activityIndicator.hidden = true
        startAnimation()
        preferencesLabel.hidden = true
        // ["😀","😱","😍","💩"]
        emojis = Array(MoodList.Moods.keys)
        TMDBClient.sharedInstance().viewController = self
        
        SCLAlertView().showError("Connection Error", subTitle: "Please check your internet connection and try again.", closeButtonTitle:"OK")
        
        
        //Tinder color:
        // 245 89 89 from website
        // 247 81 75 from iTunes
        
    }
    
    func startAnimation() {
        
        // Make dots very small (practically invsisble) since
        // we want the animation to start from small to big.
        dotOne.transform = CGAffineTransformMakeScale(0.01, 0.01)
        dotTwo.transform = CGAffineTransformMakeScale(0.01, 0.01)
        dotThree.transform = CGAffineTransformMakeScale(0.01, 0.01)
        
        UIView.animateWithDuration(0.6, delay: 0.0, options: [.Repeat, .Autoreverse], animations: {
            self.dotOne.transform = CGAffineTransformIdentity
            }, completion: nil)
        
        UIView.animateWithDuration(0.6, delay: 0.2, options: [.Repeat, .Autoreverse], animations: {
            self.dotTwo.transform = CGAffineTransformIdentity
            }, completion: nil)
        
        UIView.animateWithDuration(0.6, delay: 0.4, options: [.Repeat, .Autoreverse], animations: {
            self.dotThree.transform = CGAffineTransformIdentity
            }, completion: nil)
    }
    
    func stopAnimation() {
        dotOne.layer.removeAllAnimations()
        dotTwo.layer.removeAllAnimations()
        dotThree.layer.removeAllAnimations()
    }

    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return emojis.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return emojis[row]
    }
    

    @IBAction func moodSelected(sender: AnyObject) {
        
        //activityIndicator.hidden = false
        //activityIndicator.startAnimating()
        startAnimation()
        pickedEmoji = emojis[pickerView.selectedRowInComponent(0)]
        
        tinderArray = u.moodsToTinder(&u.Moods,emoji: pickedEmoji)
        
        TMDBClient.sharedInstance().testConnection(tinderArray[0], completion: {(complete) in
            if complete == -1{
                dispatch_async(dispatch_get_main_queue()) {
                    self.alert("The connection failed.", viewController: self)
                    self.stopAnimation()
                }
            }
        })
        
        if tinderArray.count > 0 {
            if tinderArray.count > 1 {
                downloadPoster(0,next: false)
                //downloadPoster(1, next: true)
            } else {
                downloadPoster(0, next: true)
            }
        }
    }

    @IBAction func bubbleTransition(sender: AnyObject) {
        //activityIndicator.hidden = false
        //activityIndicator.startAnimating()
        startAnimation()
        pickedEmoji = emojis[pickerView.selectedRowInComponent(0)]
        
        tinderArray = u.moodsToTinder(&u.Moods,emoji: pickedEmoji)
        
        TMDBClient.sharedInstance().testConnection(tinderArray[0], completion: {(complete) in
            if complete == -1{
                dispatch_async(dispatch_get_main_queue()) {
                    self.alert("The connection failed.", viewController: self)
                    self.stopAnimation()
                }
            }
        })
        
        if tinderArray.count > 0 {
            if tinderArray.count > 1 {
                downloadPoster(0,next: false)
                downloadPoster(1, next: true)
            } else {
                downloadPoster(0, next: true)
            }
        }
    }
    
    
    func alert(message: String, viewController: UIViewController) {
        
        let alertController = UIAlertController(title: "Error", message: "\(message)", preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
        }
        alertController.addAction(cancelAction)
        
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
        }
        alertController.addAction(OKAction)
        
        viewController.presentViewController(alertController, animated: true) {
        }
        
    }
    
    @IBAction func resetPressed(sender: AnyObject) {
//        for (mood,movies) in u.Moods {
//            for movie in movies {
//                sharedContext.deleteObject(movie)
//                let index = u.Moods?[movie.emoji as String]!.indexOf({$0.title == movie.title})
//                u.Moods?[mood]![index!] = Movie(title: movie.title as String, emoji: movie.emoji as String, context: sharedContext)
//            }
//        }
//        preferencesLabel.hidden = false
    }
    
    
    func downloadPoster(i:Int,next:Bool) {
        TMDBClient.sharedInstance().getMovieInfo((tinderArray[i]), completion: {(complete,synopsis,posterURL,backdropURL,vote) in
            
            self.tinderArray[i].synopsis = synopsis
            self.tinderArray[i].posterURL = posterURL
            self.tinderArray[i].backdropURL = backdropURL
            self.tinderArray[i].vote = vote

            print("calling function")
            TMDBClient.sharedInstance().getMoviePoster(posterURL, completion: {(data) in
                let path = "\(self.pickedEmoji)\((self.tinderArray[i].title!))"
                let documentsDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
                let totalPath:String = documentsDirectoryURL.URLByAppendingPathComponent(path as String).path!
                self.tinderArray[i].posterPath = totalPath
                print(self.tinderArray[i].posterPath)
                let image = UIImage(data: data)
                let result = UIImageJPEGRepresentation(image!, 1.0)!
                result.writeToFile(totalPath as String, atomically: true)
                CoreDataStackManager.sharedInstance().saveContext()
                if next {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.performSegueWithIdentifier("toTinder", sender: self)
                    })
                }
            })
        })
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let controller = segue.destinationViewController
        controller.transitioningDelegate = self
        controller.modalPresentationStyle = .Custom
        
        let tabVC = segue.destinationViewController as! UITabBarController
        let detailVC = tabVC.viewControllers![0] as! Tinder2VC
        
        detailVC.pickedEmoji = pickedEmoji
        u.pickedEmoji = pickedEmoji
        u.tinderArray = self.tinderArray
        u.loadedArray = u.tinderToLoaded(&u.tinderArray)
        
        CoreDataStackManager.sharedInstance().saveContext()
        
        stopAnimation()
        //activityIndicator.stopAnimating()
        //activityIndicator.hidden = true
    }
}

