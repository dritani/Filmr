//
//  Detail2VC.swift
//  Filmr
//
//  Created by Dritani on 2016-05-15.
//  Copyright © 2016 AquariusLB. All rights reserved.
//

import UIKit

class Detail2VC: UIViewController {

    var image:UIImage?
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        imageView.image = image
    }
    
    
    @IBAction func backPressed(sender: AnyObject) {
        self.navigationController!.popViewControllerAnimated(true)
    }
    
}
