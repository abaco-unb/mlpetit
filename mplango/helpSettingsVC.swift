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

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func WebLink(sender: AnyObject) {
        if let url = NSURL(string: "http://www.maplango.com.br") {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
