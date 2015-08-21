//
//  ProfileVC.swift
//  mplango
//
//  Created by Thomas Petit on 13/08/2015.
//  Copyright (c) 2015 unb.br. All rights reserved.
//

import UIKit
import CoreData

class ProfileVC: UIViewController, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var profileGender: UIImageView!
    @IBOutlet weak var profileLangLevel: UIImageView!
    @IBOutlet weak var profileNationality: UILabel!
    @IBOutlet weak var profileNumberPosts: UILabel!
    @IBOutlet weak var profileNumberFollowers: UILabel!
    @IBOutlet weak var profileNumberFollowing: UILabel!
    @IBOutlet weak var profileBio: UILabel!
    
    let moContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    var fetchedResultController: NSFetchedResultsController = NSFetchedResultsController()
    
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        retrieveLoggedUser()
        println("user data ")
        println(user.name)
        println(user.posts.count)
        navigationItem.title = user.name
        profileNumberPosts.text = user.posts.count.description
        
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
