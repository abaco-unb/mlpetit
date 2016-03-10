//
//  CategoryViewController.swift
//  mplango
//
//  Created by Carlos Wagner Pereira de Morais on 16/08/15.
//  Copyright (c) 2015 unb.br. All rights reserved.
//

import UIKit

class CategoryViewController: UIViewController {
    
    var category = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func chooseCategory(sender: AnyObject) {
        print(sender.tag);
        self.performSegueWithIdentifier("category_to_new_post", sender: self)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("categoria controller segue ")
        print(segue.identifier)
        
        let navigationController = segue.destinationViewController as! UINavigationController
        let postController:PostViewController = navigationController.viewControllers[0] as! PostViewController
        postController.category = self.category
    }
}
