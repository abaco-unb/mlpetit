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
        print("user data")
        print(user.name)
        print(user.posts.count)
        print(user.image)
        print(user.nationality)
        print(user.gender)
        
        navigationItem.title = user.name
        
        profileNationality.text = user.nationality
        profileNumberPosts.text = user.posts.count.description
        //profileNumberFollowers.text =
        //profileNumberFollowing.text =
        
        //profileGender.image = user.gender
        //profilePicture.image = user.image
        
        // Custom the visual identity of Image View
        
        profilePicture.layer.cornerRadius = 40
        profilePicture.layer.masksToBounds = true
        
        
        //Para ir à tela da gamificação com gesto (e não botão)
        let swipeGestureRecognizer: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "showProfileGameVC")
        swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(swipeGestureRecognizer)
        
    }
    
    func showProfileGameVC() {
        self.performSegueWithIdentifier("showBadges", sender: self)
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
    
    override func viewDidAppear(animated: Bool) {

        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
    }
    
    
}
