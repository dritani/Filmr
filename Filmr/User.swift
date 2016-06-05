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
    
    lazy var Moods:[String:[Movie]]! = ["😀":[Movie(title: "Airplane!", emoji: "😀", context: self.sharedContext)]]
    lazy var moodList:[String:[String:String]]! = ["😀":["Airplane!":"b"]]
    
    var tinderArray:[Movie] = []
    var loadedArray:[Movie] = []
    var pickedEmoji:String!
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()

    
    
    init() {
        
//        for movie in Moods["😀"]! {
//            if movie.title == "Airplane!" {
//                movie.posterURL = "/b4sAWNIbfXw4WTdc1wiVRBk2Vko.jpg"
//                movie.synopsis = "Still craving for the love of his life, ex-Air Force pilot Ted Striker follows Elaine onto the flight that she is working on as cabin crew. Elaine doesn't want to be with Ted anymore, but when the crew and passengers fall ill from food poisoning, Ted might be the only one who can save them."
//                movie.vote = 6.94
//            }
//        }
        
        //CoreDataStackManager.sharedInstance().saveContext()
        
        var allMovies:[Movie] = []
        var fetchRequest = NSFetchRequest(entityName: "Movie")

        
        do {
            allMovies = try sharedContext.executeFetchRequest(fetchRequest) as! [Movie]
        } catch _ {
            //
        }
        

        print(allMovies.count)
        
        // If no movies are fetched, create new Movie objects
        if allMovies.count == 0 {
//            for (mood,movies) in MoodList.Moods {
//                var movieArray:[Movie] = []
//                for movie in movies {
//                    let newMovie = Movie(title: movie, emoji: mood, context: self.sharedContext)
//                    movieArray.append(newMovie)
//                }
//                Moods[mood] = movieArray
//            }
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
                Moods?[mood]=movies
                
                var stringMovies:[String] = []
                for movie in movies {
                    stringMovies.append(movie.title as String)
                }
                
                var dictMovies:[String:String] = [:]
                for movie in stringMovies {
                    dictMovies[movie]="b"
                }
                moodList[mood]=dictMovies
            }
//            for movie in allMovies  {
//                let index = Moods?[movie.emoji as String]!.indexOf({$0.title == movie.title})
//                Moods?[movie.emoji as String]![index!] = movie
//            }

            
        }
        
        
        allMovies = []
        fetchRequest = NSFetchRequest(entityName: "Movie")
        fetchRequest.predicate = NSPredicate(format: "title == %@", "Airplane!")
        do {
            allMovies = try sharedContext.executeFetchRequest(fetchRequest) as! [Movie]
        } catch _ {
            //
        }
        
        
        if allMovies.count > 1 {
            for i in 1...allMovies.count-1 {
                sharedContext.deleteObject(allMovies[i] as NSManagedObject)
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

        print(swipedArray)
        // ...and sorts them by date.
        let sortedArray = swipedArray.sort({ $0.date.compare($1.date) == .OrderedAscending })

        return sortedArray
        
    }
    
    //take ins tinderArray and emoji
    //updates Moods array for that mood
    //finds tableArray for movie.swiped == 2 for all moods
    
}