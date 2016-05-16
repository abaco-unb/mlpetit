//
//  TabBarController.swift
//  mplango
//
//  Created by Thomas Petit on 23/08/2015.
//  Copyright (c) 2015 unb.br. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController, UINavigationControllerDelegate {
    
        override func viewDidLoad() {
        super.viewDidLoad()

        
        UITabBar.appearance().barTintColor = UIColor(hex: 0x2C98D4)
        
        UITabBar.appearance().tintColor = UIColor.whiteColor()

        
        // Uses the original colors for your images, so they aren't not rendered as grey automatically.
        for item in (self.tabBar.items )! {
            if let image = item.image {
                item.image = image.imageWithRenderingMode(.AlwaysOriginal)
            }
            if let selectedImage = item.selectedImage {
                item.selectedImage = selectedImage.imageWithRenderingMode(.AlwaysOriginal)
                
            }

        }
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
