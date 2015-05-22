//
//  ForgotPassViewController.swift
//  mplango
//
//  Created by Bruno Ferreira on 12/05/15.
//  Copyright (c) 2015 unb.br. All rights reserved.
//

import UIKit
import CoreData

class ForgotPassViewController: UIViewController {

    @IBOutlet weak var textFieldForgot: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func verify(sender: AnyObject) {
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let contxt: NSManagedObjectContext = appDel.managedObjectContext!
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
