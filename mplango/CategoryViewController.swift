//
//  CategoryViewController.swift
//  mplango
//
//  Created by Carlos Wagner Pereira de Morais on 16/08/15.
//  Copyright (c) 2015 unb.br. All rights reserved.
//

import UIKit

class CategoryViewController: UIViewController {

    var post: Annotation? = nil
    var category: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        println("categoria controller segue ")
        println(segue.identifier)
        println(segue)
        
        println(post)
        
        if segue.identifier == "NewPost" {
            
            if post != nil {
                let navigationController = segue.destinationViewController as! UINavigationController
                let postController:PostViewController = navigationController.viewControllers[0] as! PostViewController
                //post?.category = 2
                postController.post = post
            }
        }
    }
}
