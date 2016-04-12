//
//  Movie.swift
//  Filmr
//
//  Created by Dritani on 2016-04-02.
//  Copyright © 2016 AquariusLB. All rights reserved.
//

import Foundation

class Movie {
    
    // when initializing
    var title:String!
    var emoji:String!
    
    // when downloading
    var posterURL:String!
    var posterPath:String!
    var backdropURL:String!
    var backdropPath:String!
    var synopsis:String!
    var vote:Double!
    
    // when swiping
    var swiped:Int!
    var date:NSDate!
    
    
    
    init(title:String, emoji:String) {
        self.title = title
        self.emoji = emoji
        self.swiped = 0
    }
    
    
}