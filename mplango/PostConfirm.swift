//
//  PostConfirm.swift
//  mplango
//
//  Created by Thomas Petit on 01/08/2015.
//  Copyright (c) 2015 unb.br. All rights reserved.
//

import UIKit

class PostConfirm: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Set navigation bar background colour
        self.navigationController!.navigationBar.barTintColor = UIColor(hex: 0xFF6666)
        
        // Set navigation bar title text colour
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
