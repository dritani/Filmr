//
//  Detail2VC.swift
//  ZoomTransitionSample
//
//  Created by Dritani on 2016-05-14.
//  Copyright © 2016 him. All rights reserved.
//

import UIKit

class Detail2VC: UIViewController, ZoomTransitionProtocol {

    
    @IBOutlet weak var imageView: UIImageView!
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        //        let topGuide = self.topLayoutGuide;
        //        let views = ["_imageView": imageView, "topGuide": topGuide]
        //        let constraint:[AnyObject]! = NSLayoutConstraint.constraintsWithVisualFormat("V:[topGuide][_imageView]", options: NSLayoutFormatOptions.allZeros, metrics: nil, views: views)
        //        self.view.addConstraints(constraint)
    }
    
    func handleTapGesture(gesture: UITapGestureRecognizer){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func viewForTransition() -> UIView {
        return imageView
    }
}
