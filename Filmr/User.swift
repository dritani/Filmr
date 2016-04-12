//
//  User.swift
//  Filmr
//
//  Created by Dritani on 2016-04-02.
//  Copyright © 2016 AquariusLB. All rights reserved.
//

import Foundation

class User {
    
    static let sharedInstance = User()
    
    var Moods:[String:[Movie]]! = ["👀":[Movie(title: "init",emoji: "👀")]]


    func moodsToTinder(inout Moods:[String:[Movie]]!, emoji:String) -> [Movie]{
        var movieArray:[Movie] = []
        
        // Check if Mood exists. If it doesn't, create it.
        if let _ = Moods?[emoji] {
            movieArray = Moods[emoji]!
        } else {
            for movie in MoodList.Moods[emoji]! {
                let detailedMovie = Movie(title:movie,emoji:emoji)
                movieArray.append(detailedMovie)
                Moods[emoji] = movieArray
            }
        }
        
        // Gets only those movies that haven't been swiped yet.
        var tinderArray: [Movie] = []
        for movie in movieArray {
            if movie.swiped == 0 {
                tinderArray.append(movie)
            }
        }
        return tinderArray
    }
    
    

    
    
    func tinderToLoaded(inout tinderArray:[Movie])->[Movie] {
        var loadedArray:[Movie] = []
        for i in 0...2 {
            loadedArray.append(tinderArray[i])
        }
        return loadedArray
    }
    
    
    func moodsToSwiped(inout Moods:[String:[Movie]]!)->[Movie] {
        var swipedArray:[Movie] = []
        
        
        // Gets all the movies that have been liked across all moods...
        for (mood,movies) in Moods {
            for movie in movies {
                if movie.swiped == 2 {
                    swipedArray.append(movie)
                }
            }
        }
        
        // ...and sorts them by date.
        
        
        //swipedArray.sort
        let sortedArray = swipedArray.sort({ $0.date.compare($1.date) == .OrderedAscending })

        
        return sortedArray
        
        
    }
    
    //take ins tinderArray and emoji
    //updates Moods array for that mood
    //finds tableArray for movie.swiped == 2 for all moods
    
}