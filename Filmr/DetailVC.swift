//
//  DetailVC.swift
//  Filmr
//
//  Created by Dritani on 2016-04-07.
//  Copyright © 2016 AquariusLB. All rights reserved.
//

import UIKit
import AVKit

class DetailVC: UIViewController {

    
    var movie:Movie!
    var moviePlayer:AVPlayerViewController!
    
    @IBOutlet weak var backdropImage: UIImageView!
    
    @IBOutlet weak var vote: UILabel!
    
    @IBOutlet weak var synopsis: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vote.text = String(movie.vote)
        synopsis.text = movie.synopsis
        
        let data = NSData(contentsOfFile: (movie.backdropPath)!)
        let image = UIImage(data: data!)
        
        backdropImage.image = image
        
        
        

    }
    
    @IBAction func watchTrailer(sender: AnyObject) {
        
    }
    
}
