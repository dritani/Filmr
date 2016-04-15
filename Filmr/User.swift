//
//  User.swift
//  Filmr
//
//  Created by Dritani on 2016-04-02.
//  Copyright © 2016 AquariusLB. All rights reserved.
//

import Foundation
import CoreData

class User {
    
    static let sharedInstance = User()
    
    lazy var Moods:[String:[Movie]]! = ["A":[Movie(title: "a", emoji: "A", context: self.sharedContext)]]
    var loadedArray:[Movie] = []
    var pickedEmoji:String!
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    init() {
        var allMovies:[Movie] = []
        let fetchRequest = NSFetchRequest(entityName: "Movie")
        
        do {
            allMovies = try sharedContext.executeFetchRequest(fetchRequest) as! [Movie]
        } catch _ {

        }
        
        print(allMovies.count)
        // If no movies are fetched, create new Movie objects
        if allMovies.count == 0 {
            for (mood,movies) in MoodList.Moods {
                var movieArray:[Movie] = []
                for movie in movies {
                    let newMovie = Movie(title: movie, emoji: mood, context: self.sharedContext)
                    movieArray.append(newMovie)
                }
                Moods[mood] = movieArray
            }
        // Else, sort the movies into a dictionary
        } else {
            var moods:[String] = []
            for movie in allMovies {
                if moods.contains(movie.emoji as String)==false {
                    moods.append(movie.emoji as String)
                }
            }
            
            for mood in moods {
                var movies:[Movie] = []
                for movie in allMovies {
                    if movie.emoji as String == mood {
                        movies.append(movie)
                    }
                }
                Moods[mood]=movies
            }
//            for movie in allMovies  {
//                let index = Moods?[movie.emoji as String]!.indexOf({$0.title == movie.title})
//                Moods?[movie.emoji as String]![index!] = movie
//            }
            Moods["A"] = []
            for movie in allMovies {
                if movie.emoji as String == "A" {
                    sharedContext.deleteObject(movie)
                }
            }
        }
    }
    
    func moodsToTinder(inout Moods:[String:[Movie]]!, emoji:String) -> [Movie]{
        
        // Gets only those movies that haven't been swiped yet
        var movieArray:[Movie] = []
        var tinderArray: [Movie] = []
        
        movieArray = Moods[emoji]!
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
        let sortedArray = swipedArray.sort({ $0.date.compare($1.date) == .OrderedAscending })

        
        return sortedArray
        
        
    }
    
    //take ins tinderArray and emoji
    //updates Moods array for that mood
    //finds tableArray for movie.swiped == 2 for all moods
    
}