//
//  MoodVC
//  Filmr
//
//  Created by Dritani on 2016-04-01.
//  Copyright © 2016 AquariusLB. All rights reserved.
//

import UIKit
import CoreData

class MoodVC: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    var emojis: [String]!
    var tinderArray:[Movie] = []
    var loadedArray:[Movie]! = []
    var pickedEmoji:String!
    let u:User = User.sharedInstance as User
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var resetLabel: UILabel!
    @IBOutlet weak var theSwitch: UISwitch!
    @IBOutlet weak var pickerView: UIPickerView!
    
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var iFeelLabel: UILabel!
    @IBOutlet weak var movieLabel: UILabel!
    
    @IBOutlet weak var preferencesLabel: UILabel!
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()

    @IBAction func theSwitchPressed(sender: AnyObject) {
 
        let color:UIColor
        let color2:UIColor
        let color3:UIColor
        
        if theSwitch.on {
            color = UIColor(red: 35.0/255.0, green: 79.0/255.0, blue: 42.0/255.0, alpha: 1.0)
            color2 = UIColor(red: 0/255.0, green: 255.0/255.0, blue: 0.0/255.0, alpha: 1.0)
            color3 = UIColor(red: 103.0/255.0, green: 91.0/255.0, blue: 220.0/255.0, alpha: 1.0)
        } else {
            color = UIColor(red: 35.0/255.0, green: 39.0/255.0, blue: 42.0/255.0, alpha: 1.0)
            color2 = UIColor(red: 0.0/255.0, green: 122.0/255.0, blue: 255.0/255.0, alpha: 1.0)
            color3 = UIColor(red: 255.0/255.0, green: 127.0/255.0, blue: 0.0/255.0, alpha: 1.0)
        }
        view.backgroundColor = color
        self.navigationController?.navigationBar.barTintColor = color
        iFeelLabel.backgroundColor = color
        movieLabel.backgroundColor = color
        pickerView.backgroundColor = color
        preferencesLabel.backgroundColor = color
        goButton.backgroundColor = color2
        resetButton.backgroundColor = color3
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.hidden = true
        theSwitch.on = false
        preferencesLabel.hidden = true
        // ["😀","😱","😍","💩"]
        emojis = Array(MoodList.Moods.keys)
        TMDBClient.sharedInstance().viewController = self
        
        

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
        
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        
        pickedEmoji = emojis[pickerView.selectedRowInComponent(0)]
        
        tinderArray = u.moodsToTinder(&u.Moods,emoji: pickedEmoji)
        
        if tinderArray.count > 0 {
            if tinderArray.count > 1 {
                if tinderArray.count > 2 {
                    downloadPoster(0, next: false)
                    downloadPoster(1, next: false)
                    downloadPoster(2, next: true)
                } else {
                    downloadPoster(0,next: false)
                    downloadPoster(1, next: true)
                }
            } else {
                downloadPoster(0, next: true)
            }
        }
    }

    @IBAction func resetPressed(sender: AnyObject) {
        for (mood,movies) in u.Moods {
            for movie in movies {
                sharedContext.deleteObject(movie)
                let index = u.Moods?[movie.emoji as String]!.indexOf({$0.title == movie.title})
                u.Moods?[mood]![index!] = Movie(title: movie.title as String, emoji: movie.emoji as String, context: sharedContext)
            }
        }
        preferencesLabel.hidden = false
    }
    
    
    func downloadPoster(i:Int,next:Bool) {
        TMDBClient.sharedInstance().getMovieInfo((tinderArray[i]), completion: {(complete) in
            TMDBClient.sharedInstance().getMoviePoster((self.tinderArray[i].posterURL)! as String, completion: {(data) in
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
                        self.performSegueWithIdentifier("toTinder", sender: self.tinderArray)
                    })
                }
                
            })
        })
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let tabVC = segue.destinationViewController as! UITabBarController
        let detailVC = tabVC.viewControllers![0] as! TinderVC
        let data = sender as! [Movie]
        loadedArray = u.tinderToLoaded(&tinderArray)
        //print(loadedArray[0].posterURL)
        //print(u.Moods[pickedEmoji]![0].posterURL)
        detailVC.tinderArray = data
        detailVC.loadedArray = loadedArray
        detailVC.pickedEmoji = pickedEmoji
        u.pickedEmoji = pickedEmoji
        CoreDataStackManager.sharedInstance().saveContext()
        activityIndicator.stopAnimating()
        activityIndicator.hidden = true
    }
}

