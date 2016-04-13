//
//  ViewController.swift
//  Filmr
//
//  Created by Eugene Andreyev on 4/23/15.
//  Copyright (c) 2015 Eugene Andreyev. All rights reserved.
//

import UIKit
import Koloda

private var numberOfCards: UInt = 5

class TinderVC: UIViewController {
    
    @IBOutlet weak var kolodaView: KolodaView!
    var tinderArray:[Movie]!
    var loadedArray:[Movie]!
    var pickedEmoji:String!
    let u:User = User.sharedInstance as User
    var undoButton:UIBarButtonItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var noMoreLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.hidden = true
        
        let color = UIColor(red: 35.0/255.0, green: 39.0/255.0, blue: 42.0/255.0, alpha: 1.0)
        UITabBar.appearance().barTintColor = color
        self.navigationController?.navigationBar.barTintColor = color
        
        let u = User.sharedInstance as User
        // Rounded corners
//        kolodaView.layer.cornerRadius = 20
//        kolodaView.clipsToBounds = true
        
//        loadedArray[0].emoji = "😎"
//        print(u.Moods[pickedEmoji]![0].emoji)
        
        noMoreLabel.hidden = true
 
        kolodaView.dataSource = self
        kolodaView.delegate = self
        
        self.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
    }
    

    func downloadBackdrop(i:Int) {
        
        TMDBClient.sharedInstance().getMovieBackdrop((self.loadedArray?[i].backdropURL)! as String, completion: {(data) in
            
            let path = "\(self.pickedEmoji)B\((self.loadedArray?[i].title!)!)"
            let documentsDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
            let totalPath:String = documentsDirectoryURL.URLByAppendingPathComponent(path as String).path!
            self.tinderArray[i].backdropPath = totalPath
            
            let image = UIImage(data: data)
            let result = UIImageJPEGRepresentation(image!, 0.0)!
            result.writeToFile(totalPath as String, atomically: true)
            CoreDataStackManager.sharedInstance().saveContext()
            dispatch_async(dispatch_get_main_queue(), {
                self.performSegueWithIdentifier("toDetail", sender: self.loadedArray?[i])
            })
            
            
        })
    }
    func downloadPoster(i:Int) {
        // Download movie info
        TMDBClient.sharedInstance().getMovieInfo((tinderArray?[i])!, completion: {(complete) in
//            self.tinderArray[i].synopsis = synopsis
//            self.tinderArray[i].posterURL = posterURL
            
            // Download movie poster image
            TMDBClient.sharedInstance().getMoviePoster((self.tinderArray?[i].posterURL)! as String, completion: {(data) in
                
                let path = "\(self.pickedEmoji)\((self.tinderArray?[i].title!)!)"
                let documentsDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
                let totalPath:String = documentsDirectoryURL.URLByAppendingPathComponent(path as String).path!
                self.tinderArray[i].posterPath = totalPath
                
                let image = UIImage(data: data)
                let result = UIImageJPEGRepresentation(image!, 0.0)!
                result.writeToFile(totalPath as String, atomically: true)
                CoreDataStackManager.sharedInstance().saveContext()

                self.loadedArray.append(self.tinderArray[i])
                dispatch_async(dispatch_get_main_queue(), {
                                        self.kolodaView?.reloadData()
                })
               

            })
            
        })
    }
    
    //MARK: IBActions
    @IBAction func leftButtonTapped() {
        kolodaView?.swipe(SwipeResultDirection.Left)
    }
    
    @IBAction func rightButtonTapped() {
        kolodaView?.swipe(SwipeResultDirection.Right)
    }
 
}


//MARK: KolodaViewDelegate
extension TinderVC: KolodaViewDelegate {
    
    func koloda(koloda: KolodaView, didSwipedCardAtIndex index: UInt, inDirection direction: SwipeResultDirection) {
        
        if direction == .Left {
             loadedArray[Int(index)].swiped = 1
        } else if direction == .Right {
             loadedArray[Int(index)].swiped = 2
        }
        CoreDataStackManager.sharedInstance().saveContext()
        loadedArray[Int(index)].date = NSDate()
    
        if Int(index)+3 <= tinderArray.count - 1 {//tinderArray.count {
            downloadPoster(Int(index)+3)
        }
    }
    
    func koloda(kolodaDidRunOutOfCards koloda: KolodaView) {
        //Example: reloading
        //kolodaView.resetCurrentCardNumber()
        noMoreLabel.hidden = false
    }
    
    func koloda(koloda: KolodaView, didSelectCardAtIndex index: UInt) {
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        downloadBackdrop(Int(index))
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let detailVC = segue.destinationViewController as! DetailVC
        let data = sender as! Movie
        detailVC.movie = data
        CoreDataStackManager.sharedInstance().saveContext()
        activityIndicator.stopAnimating()
        activityIndicator.hidden = true
    }
}


//MARK: KolodaViewDataSource
extension TinderVC: KolodaViewDataSource {
    
    func koloda(kolodaNumberOfCards koloda:KolodaView) -> UInt {
        return UInt(loadedArray.count)
    }
    
    func koloda(koloda: KolodaView, viewForCardAtIndex index: UInt) -> UIView {
        let data = NSData(contentsOfFile: (tinderArray?[Int(index)].posterPath)! as String)
        let image = UIImage(data: data!)
        return UIImageView(image: image)
    }
    
    func koloda(koloda: KolodaView, viewForCardOverlayAtIndex index: UInt) -> OverlayView? {
        return NSBundle.mainBundle().loadNibNamed("OverlayView",
            owner: self, options: nil)[0] as? OverlayView
    }
}

