//
//  TMDB_API.swift
//  Filmr
//
//  Created by Dritani on 2016-04-02.
//  Copyright © 2016 AquariusLB. All rights reserved.
//

import Foundation
import UIKit

class TMDBClient {
    
    var viewController:UIViewController!
    
    class func sharedInstance() -> TMDBClient {
        struct Singleton {
            static var sharedInstance = TMDBClient()
        }
        return Singleton.sharedInstance
    }
    
    func getMovieInfo(movie: Movie, completion: (complete:Bool)->Void) {
        let methodParameters = [
            TMDBConstants.TMDBParameterKeys.ApiKey: TMDBConstants.TMDBParameterValues.ApiKey,
            TMDBConstants.TMDBParameterKeys.Query: movie.title
        ]
        
        let request = NSMutableURLRequest(URL: tmdbURLFromParameters(methodParameters, withPathExtension: "/search/movie"))
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.alert("The connection failed.", viewController: self.viewController)
                }
                print("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                print("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            
            /* 5. Parse the data */
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                print("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            
            /* GUARD: Is the "results" key in parsedResult? */
            guard let results = parsedResult[TMDBConstants.TMDBResponseKeys.Results] as? [[String:AnyObject]] else {
                print("Cannot find key '\(TMDBConstants.TMDBResponseKeys.Results)' in \(parsedResult)")
                return
            }
            
            
            guard let synopsis = results[0][TMDBConstants.TMDBResponseKeys.Synopsis] as? String else {
                print("Cannot find the Synopsis")
                return
            }
            
            guard let posterURL = results[0][TMDBConstants.TMDBResponseKeys.Poster] as? String else {
                print("Cannot find the Poster Path")
                return
            }
            
            guard let backdropURL = results[0][TMDBConstants.TMDBResponseKeys.Backdrop] as? String else {
                print("Cannot find the Backdrop Path")
                return
            }
            
            guard let vote = results[0][TMDBConstants.TMDBResponseKeys.Vote] as? Double else {
                print("Cannot find the Vote")
                return
            }
            
            
            movie.synopsis = synopsis
            movie.posterURL = posterURL
            movie.backdropURL = backdropURL
            movie.vote = vote
            
            completion(complete: true)
        }
        
        task.resume()
    }
    
    func getMoviePoster(posterURL:String, completion:(data:NSData)->Void) {
        
        /* 1. Set the parameters */
        // There are none...
        let secureBaseImageURLString =  "https://image.tmdb.org/t/p/"
        let posterSizes = ["w92", "w154", "w185", "w342", "w500", "w780", "original"]
        let profileSizes = ["w45", "w185", "h632", "original"]
        
        /* 2. Build the URL */
        let baseURL = NSURL(string: secureBaseImageURLString)!
        let url = baseURL.URLByAppendingPathComponent("w500").URLByAppendingPathComponent(posterURL)
        
        /* 3. Configure the request */
        let request = NSURLRequest(URL: url)
        
        let session = NSURLSession.sharedSession()
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.alert("The connection failed.", viewController: self.viewController)
                }
                print("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                print("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            
            /* 5. Parse the data */
            // No need, the data is already raw image data.
            
            /* 6. Use the data! */
            completion(data:data)
        }
        
        task.resume()
    }
    
    
    func getMovieBackdrop(backdropURL:String, completion:(data:NSData)->Void) {
        
        /* 1. Set the parameters */
        // There are none...
        let secureBaseImageURLString =  "https://image.tmdb.org/t/p/"
        let posterSizes = ["w92", "w154", "w185", "w342", "w500", "w780", "original"]
        let profileSizes = ["w45", "w185", "h632", "original"]
        
        /* 2. Build the URL */
        let baseURL = NSURL(string: secureBaseImageURLString)!
        let url = baseURL.URLByAppendingPathComponent("w500").URLByAppendingPathComponent(backdropURL)
        
        /* 3. Configure the request */
        let request = NSURLRequest(URL: url)
        
        let session = NSURLSession.sharedSession()
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.alert("The connection failed.", viewController: self.viewController)
                }
                print("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                print("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            
            /* 5. Parse the data */
            // No need, the data is already raw image data.
            
            /* 6. Use the data! */
            completion(data:data)
        }
        
        task.resume()
    }

    func alert(message: String, viewController: UIViewController) {
        
        let alertController = UIAlertController(title: "Error", message: "\(message)", preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            // ...
        }
        alertController.addAction(cancelAction)
        
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            // ...
        }
        alertController.addAction(OKAction)
        
        viewController.presentViewController(alertController, animated: true) {
            // ...
        }
        
    }
    
    private func tmdbURLFromParameters(parameters: [String:AnyObject], withPathExtension: String? = nil) -> NSURL {
        
        let components = NSURLComponents()
        components.scheme = TMDBConstants.URL.ApiScheme
        components.host = TMDBConstants.URL.ApiHost
        components.path = TMDBConstants.URL.ApiPath + (withPathExtension ?? "")
        components.queryItems = [NSURLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.URL!
    }
}


