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
    
    var user = [User]()

    
    override func viewDidLoad() {
    super.viewDidLoad()
        
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        
        
        var error: NSError?
        let request = NSFetchRequest(entityName:"User")
        user = moContext?.executeFetchRequest(request, error: &error) as! [User]
        

    
    }
    
    override func viewWillAppear(animated: Bool) {
        
    }
    
    
}
