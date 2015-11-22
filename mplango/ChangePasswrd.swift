//
//  ChangePasswrd.swift
//  mplango
//
//  Created by Thomas Petit on 05/11/2015.
//  Copyright © 2015 unb.br. All rights reserved.
//

import UIKit
import CoreData

class ChangePasswrd: UIViewController, NSFetchedResultsControllerDelegate {
    
    let moContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    var fetchedResultController: NSFetchedResultsController = NSFetchedResultsController()
    
    var user: User!
    
    @IBOutlet weak var currentPasswd: UITextField!
    @IBOutlet weak var newPasswd: UITextField!
    @IBOutlet weak var confNewPasswd: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        retrieveLoggedUser()
        
        
        
    }



    //MARK: Actions
    
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(false, completion: nil)
    }
    
    
    func retrieveLoggedUser() {
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let email: String = prefs.objectForKey("USEREMAIL") as! String
        let fetchRequest = NSFetchRequest(entityName: "User")
        fetchRequest.predicate = NSPredicate(format: "email == %@", email)
        
        if let fetchResults = (try? moContext?.executeFetchRequest(fetchRequest)) as? [User] {
            user = fetchResults[0];
            
        }
        
    }
    

    
    
    
    
    
    
}
