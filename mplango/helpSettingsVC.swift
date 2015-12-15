//
//  helpSettingsVC.swift
//  mplango
//
//  Created by Thomas Petit on 11/12/2015.
//  Copyright © 2015 unb.br. All rights reserved.
//

import UIKit

class helpSettingsVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    
    @IBAction func WebLink(sender: AnyObject) {
        if let url = NSURL(string: "http://www.maplango.com.br") {
            UIApplication.sharedApplication().openURL(url)
        }
    }

}
