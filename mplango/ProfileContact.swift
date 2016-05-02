//
//  ProfileContact.swift
//  mplango
//
//  Created by Thomas Petit on 22/04/2016.
//  Copyright © 2016 unb.br. All rights reserved.
//

import Alamofire
import SwiftyJSON
import UIKit
import MapKit


class ProfileContact: UIViewController {
    
    var contact: RUser!
    var restPath = "http://server.maplango.com.br/user-rest"
    var userId:Int!
    var posts: PostAnnotation!
    
    var indicator:ActivityIndicator = ActivityIndicator()
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var profileGender: UIImageView!
    @IBOutlet weak var profileLangLevel: UIImageView!
    @IBOutlet weak var profileNationality: UILabel!
    @IBOutlet weak var profileNumberPosts: UILabel!
    @IBOutlet weak var profileNumberFollowers: UILabel!
    @IBOutlet weak var profileNumberFollowing: UILabel!
    @IBOutlet weak var profileBio: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        retrieveLoggedUser()
        print("self.userId : ", self.userId)
        
        self.navigationItem.title = contact.name
        self.profileNationality.text = contact.nationality
        self.profileBio.text = contact.bio
        
        if contact.gender == "Homme" {
            self.profileGender.image = UIImage(named:"icon_masc_profile")
        }
        else if contact.gender == "Femme" {
            self.profileGender.image = UIImage(named:"icon_fem_profile")
        }
        
        let imgUtils:ImageUtils = ImageUtils()
        self.profilePicture.image = imgUtils.loadImageFromPath(contact.image)
        
        
        if contact.level == 1 {
            self.profileLangLevel.image = UIImage(named: "profile_niv2")
        }
        else if contact.level == 2 {
            self.profileLangLevel.image = UIImage(named: "profile_niv3")
        }
        else if contact.level == 3 {
                self.profileLangLevel.image = UIImage(named: "profile_niv4")
        }
        else if contact.level == 4 {
            self.profileLangLevel.image = UIImage(named: "profile_nivM")
        }
        
        else {
            self.profileLangLevel.image = UIImage(named: "profile_niv1")

        }
        
        
//        self.profileNumberPosts.text =
//        self.profileNumberFollowers.text =
//        self.profileNumberFollowing.text =
        
        
        // Custom the visual identity of Image View
        profilePicture.layer.cornerRadius = 40
        profilePicture.layer.masksToBounds = true
        
        
        //Para ir à tela da gamificação com gesto (e não botão)
        let swipeGestureRecognizer: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(ProfileVC.showProfileGameVC))
        swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(swipeGestureRecognizer)
        
    }

    
    func retrieveLoggedUser() {
        
        // recupera os dados do usuário logado no app
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        self.userId = prefs.integerForKey("id") as Int
        NSLog("usuário logado: %ld", userId)
        
    }
    
    @IBAction func unwindSecondView(segue: UIStoryboardSegue) {
        print ("unwindSecondView fired in first view")
        print("self.userId : ", self.userId)        
        
    }
    
}
