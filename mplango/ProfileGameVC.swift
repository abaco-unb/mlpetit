//
//  ProfileGameVC.swift
//  mplango
//
//  Created by Thomas Petit on 26/08/2015.
//  Copyright (c) 2015 unb.br. All rights reserved.
//

import UIKit
import CoreData

class ProfileGameVC: UIViewController, NSFetchedResultsControllerDelegate {
    
    
    let moContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    var fetchedResultController: NSFetchedResultsController = NSFetchedResultsController()
    
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        retrieveLoggedUser()
        println("user data ")
        println(user.name)
        navigationItem.title = user.name
        
        //navigationItem.setHidesBackButton(true, animated: true)
        
        
    }
    
    
    
    func retrieveLoggedUser() {
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let email: String = prefs.objectForKey("USEREMAIL") as! String
        let fetchRequest = NSFetchRequest(entityName: "User")
        fetchRequest.predicate = NSPredicate(format: "email == %@", email)
        
        if let fetchResults = moContext?.executeFetchRequest(fetchRequest, error: nil) as? [User] {
            user = fetchResults[0];
            
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
    }
    
    
}
