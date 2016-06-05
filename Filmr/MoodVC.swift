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
import Firebase

class MoodVC: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UIViewControllerTransitioningDelegate {
    
    var emojis: [String]!
    var tinderArray:[Movie] = []
    var loadedArray:[Movie]! = []
    var pickedEmoji:String!
    
    let u:User = User.sharedInstance as User
    let transition = BubbleTransition()
    

    @IBOutlet weak var dotOne: UIImageView!
    @IBOutlet weak var dotTwo: UIImageView!
    @IBOutlet weak var dotThree: UIImageView!
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var transitionButton: UIButton!
    
    @IBOutlet weak var resetLabel: UILabel!
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
        startAnimation()
        preferencesLabel.hidden = true
        // ["😀","😱","😍","💩"]
        emojis = Array(MoodList.Moods.keys)
        
        let ref = Firebase(url: "https://filmr.firebaseio.com/a/")
        
        ref.observeEventType(.Value, withBlock: { snapshot in
            
            let moodList = snapshot.value as! [String:AnyObject]
            
            for mood in moodList.keys {
                
                if self.u.moodList[mood] == nil {
                    self.u.moodList[mood] = [:]
                    self.u.Moods[mood] = []
                }
                
                let movies = moodList[mood] as! [String:AnyObject]
                
                for movie in movies.keys {
                    if self.u.moodList[mood]?[movie] == nil {
                    
                        let info = movies[movie] as! [String:AnyObject]
                        
                        let newMovie = Movie(title: movie, emoji: mood, context: self.sharedContext)
                        newMovie.posterURL = info["posterURL"] as! NSString
                        newMovie.vote = info["vote"] as! NSNumber
                        newMovie.synopsis = info["synopsis"] as! NSString
                        
                        self.u.moodList[mood]?[movie] = "a"
                        self.u.Moods[mood]!.append(newMovie)
                        
                    }
                }
            }
            

            
            CoreDataStackManager.sharedInstance().saveContext()
        }, withCancelBlock: { error in
                print(error.description)
                // alert: check  your internet connection
            SCLAlertView().showError("Connection Error", subTitle: "Please check your internet connection and try again.", closeButtonTitle:"OK")
        })

//        for (mood,movies) in u.Moods {
//            print(mood)
//            for movie in movies {
//                TMDBClient.sharedInstance.getMovieInfo(movie, completion: {(complete,synopsis,posterURL,backdropURL,vote) in
//                    
//                    print("\"\(movie.title)\":{ \"posterURL\" : \"\(posterURL)\", \"vote\" : \(vote), \"synopsis\" : \"\(synopsis)\"},")
//                    
//                })
//
//            }
//            
//        }
        
        
        
        
        
        
        
        
        //Tinder color:
        // 245 89 89 from website
        // 247 81 75 from iTunes
        
    }
    
    func startAnimation() {
        
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
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return emojis[row]
    }
    



    @IBAction func bubbleTransition(sender: AnyObject) {

        startAnimation()
        pickedEmoji = emojis[pickerView.selectedRowInComponent(0)]
        
        tinderArray = u.moodsToTinder(&u.Moods,emoji: pickedEmoji)
        
        if tinderArray.count > 0 {
            if tinderArray.count > 1 {
                downloadPoster(0,next: false)
                downloadPoster(1, next: true)
            } else {
                downloadPoster(0, next: true)
            }
        }
    }
    
    
    @IBAction func resetPressed(sender: AnyObject) {
        
        for (mood,movies) in u.Moods {
            for movie in movies {
                movie.swiped = 0
            }
        }
        
        // set reset label = "reset" and 3 seconds later get rid of it
        let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            // your function here
            //
        })
    }
    
    
    func downloadPoster(i:Int,next:Bool) {
        TMDBClient.sharedInstance.getMoviePoster(self.tinderArray[i].posterURL as String, completion: {(data,error) in
            
            if error {
                SCLAlertView().showError("Connection Error", subTitle: "Please check your internet connection and try again.", closeButtonTitle:"OK")
                return
            }
            
            let path = "\(self.pickedEmoji)\((self.tinderArray[i].title!))"
            let documentsDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
            let totalPath:String = documentsDirectoryURL.URLByAppendingPathComponent(path as String).path!
            self.tinderArray[i].posterPath = totalPath
            
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
        CoreDataStackManager.sharedInstance().saveContext()
        
        stopAnimation()

    }
}

