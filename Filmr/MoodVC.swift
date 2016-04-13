//
//  MoodVC
//  Filmr
//
//  Created by Dritani on 2016-04-01.
//  Copyright © 2016 AquariusLB. All rights reserved.
//

import UIKit

class MoodVC: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    var emojis: [String]!
    var tinderArray:[Movie] = []
    var loadedArray:[Movie]! = []
    var pickedEmoji:String!
    let u:User = User.sharedInstance as User
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.hidden = true
        let color = UIColor(red: 35.0/255.0, green: 39.0/255.0, blue: 42.0/255.0, alpha: 1.0)
        self.navigationController?.navigationBar.barTintColor = color
        
        // ["😀","😱","😍","💩"]
        emojis = Array(MoodList.Moods.keys)
        
        

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
                    downloadPoster(0,next: false)
                    downloadPoster(1,next: false)
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
        var toDelete:[Movie] = u.Moods[emojis[pickerView.selectedRowInComponent(0)]]!
        for i in 0...toDelete.count - 1 {
            toDelete.removeAtIndex(i)
        }
    }
    
    
    func downloadPoster(i:Int,next:Bool) {
        TMDBClient.sharedInstance().getMovieInfo((tinderArray[i]), completion: {(complete) in
            //self.tinderArray[i].synopsis = synopsis
            //self.tinderArray[i].posterURL = posterURL
            TMDBClient.sharedInstance().getMoviePoster((self.tinderArray[i].posterURL)!, completion: {(data) in
                
                let path = "\(self.pickedEmoji)\((self.tinderArray[i].title!))"
                
                let documentsDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
                let totalPath:String = documentsDirectoryURL.URLByAppendingPathComponent(path as String).path!
                self.tinderArray[i].posterPath = totalPath
                
                let image = UIImage(data: data)
                let result = UIImageJPEGRepresentation(image!, 1.0)!
                result.writeToFile(totalPath as String, atomically: true)
                
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
        activityIndicator.stopAnimating()
        activityIndicator.hidden = true
    }
}

