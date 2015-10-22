//
//  ProfileSegue.swift
//  mplango
//
//  Created by Thomas Petit on 26/08/2015.
//  Copyright (c) 2015 unb.br. All rights reserved.
//

import UIKit

class ProfileSegue: UIStoryboardSegue {
    
    
    override func perform() {
        
        // Assign the source and destination views to local variables.
        let ProfileVC = self.sourceViewController.view as UIView!
        let ProfileGameVC = self.destinationViewController.view as UIView!
        
        // Get the screen width and height.
        let screenWidth = UIScreen.mainScreen().bounds.size.width
        let screenHeight = UIScreen.mainScreen().bounds.size.height
        
        
        // Specify the initial position of the destination view.
        ProfileGameVC.frame = CGRectMake(0.0, screenHeight, screenWidth, screenHeight)
        
        
        // Access the app's key window and insert the destination view above the current (source) one.
        let window = UIApplication.sharedApplication().keyWindow
        window?.insertSubview(ProfileGameVC, aboveSubview: ProfileVC)
        
        // Animate the transition.
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            ProfileVC.frame = CGRectOffset(ProfileVC.frame, 0.0, -screenHeight)
            ProfileGameVC.frame = CGRectOffset(ProfileGameVC.frame, 0.0, -screenHeight)
            
            }) { (Finished) -> Void in
                self.sourceViewController.presentViewController(self.destinationViewController ,
                    animated: false,
                    completion: nil)
                
        }
        
        
    }
    
    
    
   
}
