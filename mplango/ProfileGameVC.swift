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
        print("user data ")
        print(user.name)
        navigationItem.title = user.name
        
        //navigationItem.setHidesBackButton(true, animated: true)
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
