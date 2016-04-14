//
//  FavoritesVC.swift
//  Filmr
//
//  Created by Dritani on 2016-04-01.
//  Copyright © 2016 AquariusLB. All rights reserved.
//

import UIKit
import CoreData
class FavoritesVC: UITableViewController {

    let u:User = User.sharedInstance as User
    
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let color = UIColor(red: 35.0/255.0, green: 39.0/255.0, blue: 42.0/255.0, alpha: 1.0)
        UITabBar.appearance().barTintColor = color
        self.navigationController?.navigationBar.barTintColor = color
        
        TMDBClient.sharedInstance().viewController = self
        
        tableView.reloadData()
    }

        
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return u.moodsToSwiped(&u.Moods).count
//        print(u.moodsToSwiped(&u.Moods).count)
       //return 5

    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("favoriteCell") as! FavoriteCell
        
        let inset: UIEdgeInsets = UIEdgeInsetsMake(64, 0, 0, 0)
        tableView.contentInset = inset
        tableView.scrollIndicatorInsets = inset
        
        var swipedArray:[Movie] = u.moodsToSwiped(&u.Moods)
        
        let movie = swipedArray[indexPath.row]
        
        if NSFileManager.defaultManager().fileExistsAtPath(movie.posterPath as String) {
            let data = NSData(contentsOfFile: (movie.posterPath)! as String)
            let image = UIImage(data: data!)
            cell.posterImage.image = image
            cell.title.text = swipedArray[indexPath.row].title as String
            cell.moodLabel.text = swipedArray[indexPath.row].emoji as String
        } else {
            TMDBClient.sharedInstance().getMoviePoster((movie.posterURL)! as String, completion: {(data) in
                let path = "\(movie.emoji)\((movie.title!))"
                let documentsDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
                let totalPath:String = documentsDirectoryURL.URLByAppendingPathComponent(path as String).path!
                
                dispatch_async(dispatch_get_main_queue(), {
                    swipedArray[indexPath.row].posterPath = totalPath
                })
                let image = UIImage(data: data)
                let result = UIImageJPEGRepresentation(image!, 0.0)!
                result.writeToFile(totalPath as String, atomically: true)
                
                dispatch_async(dispatch_get_main_queue(), {
                    cell.posterImage.image = image
                    cell.title.text = swipedArray[indexPath.row].title as String
                    cell.moodLabel.text = swipedArray[indexPath.row].emoji as String
                })
            })
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        downloadBackdrop(indexPath.row)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let detailVC = segue.destinationViewController as! DetailVC
        let data = sender as! Movie
        detailVC.movie = data
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    func downloadBackdrop(i:Int) {
        
        var swipedArray:[Movie] = u.moodsToSwiped(&u.Moods)
        
        TMDBClient.sharedInstance().getMovieBackdrop((swipedArray[i].backdropURL)! as String, completion: {(data) in
            
            let path = "\(self.u.pickedEmoji)B\((swipedArray[i].title!))"
            let documentsDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
            let totalPath:String = documentsDirectoryURL.URLByAppendingPathComponent(path as String).path!
            swipedArray[i].backdropPath = totalPath
            
            let image = UIImage(data: data)
            let result = UIImageJPEGRepresentation(image!, 0.0)!
            result.writeToFile(totalPath as String, atomically: true)
            
            CoreDataStackManager.sharedInstance().saveContext()
            dispatch_async(dispatch_get_main_queue(), {
                self.performSegueWithIdentifier("toDetail2", sender: swipedArray[i])
            })
            
            
        })
    }
}
