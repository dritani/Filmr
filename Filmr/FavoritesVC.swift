//
//  FavoritesVC.swift
//  Filmr
//
//  Created by Dritani on 2016-04-01.
//  Copyright © 2016 AquariusLB. All rights reserved.
//

import UIKit

class FavoritesVC: UITableViewController {

    let u:User = User.sharedInstance as User
    var swipedArray:[Movie]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let color = UIColor(red: 35.0/255.0, green: 39.0/255.0, blue: 42.0/255.0, alpha: 1.0)
        UITabBar.appearance().barTintColor = color
        self.navigationController?.navigationBar.barTintColor = color
        
        swipedArray = u.moodsToSwiped(&u.Moods)
    }

        
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return swipedArray.count
//        print(u.moodsToSwiped(&u.Moods).count)
       //return 5

    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("favoriteCell") as! FavoriteCell
        
        let inset: UIEdgeInsets = UIEdgeInsetsMake(64, 0, 0, 0)
        tableView.contentInset = inset
        tableView.scrollIndicatorInsets = inset
        
        
        cell.tempLabel.text = swipedArray[indexPath.row].title
        
        let data = NSData(contentsOfFile: (swipedArray[indexPath.row].posterPath)!)
        let image = UIImage(data: data!)
        cell.posterImage.image = image
        
        print(swipedArray[indexPath.row].emoji)
        cell.moodLabel.text = swipedArray[indexPath.row].emoji
        
        //cell.tempLabel.text = "GGG"
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        

        performSegueWithIdentifier("toDetail2", sender: self)
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            swipedArray[indexPath.row] = Movie(title: "a", emoji: "a")
            swipedArray.removeAtIndex(indexPath.row)
            
            
        }
    }
    
}
