//
//  PostNew.swift
//  mplango
//
//  Created by Thomas Petit on 01/08/2015.
//  Copyright (c) 2015 unb.br. All rights reserved.
//

import UIKit
import CoreData

class PostNViewController: UIViewController {
    
    let moContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var textTextField: UITextField!
    
    var post: PostAnnotation? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Set navigation bar background colour
        self.navigationController!.navigationBar.barTintColor = UIColor(hex: 0x3399CC)
        
        // Set navigation bar title text colour
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @IBAction func savePost(sender: UIBarButtonItem) {
        
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if addButton === sender {
            print("addButton")
            print(textTextField.text)
        }
    }
    
}
