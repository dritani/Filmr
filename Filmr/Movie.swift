//
//  Movie.swift
//  Filmr
//
//  Created by Dritani on 2016-04-02.
//  Copyright © 2016 AquariusLB. All rights reserved.
//

import Foundation
import CoreData
class Movie: NSManagedObject {
    
    // when initializing
    @NSManaged var title:NSString!
    @NSManaged var emoji:NSString!
    
    // when downloading
    @NSManaged var posterURL:NSString!
    @NSManaged var posterPath:NSString!
    @NSManaged var backdropURL:NSString!
    @NSManaged var backdropPath:NSString!
    @NSManaged var synopsis:NSString!
    @NSManaged var vote:NSNumber!
    
    // when swiping
    @NSManaged var swiped:NSNumber!
    @NSManaged var date:NSDate!
    
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(title:String, emoji:String, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Movie", inManagedObjectContext: context)
        super.init(entity: entity!, insertIntoManagedObjectContext: context)
        
        self.title = title
        self.emoji = emoji
        self.swiped = 0
    }
}