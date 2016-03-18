//
//  ProfileVC.swift
//  mplango
//
//  Created by Thomas Petit on 13/08/2015.
//  Copyright (c) 2015 unb.br. All rights reserved.
//

import Alamofire
import SwiftyJSON
import UIKit
import MapKit


class ProfileVC: UIViewController {
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var profileGender: UIImageView!
    @IBOutlet weak var profileLangLevel: UIImageView!
    @IBOutlet weak var profileNationality: UILabel!
    @IBOutlet weak var profileNumberPosts: UILabel!
    @IBOutlet weak var profileNumberFollowers: UILabel!
    @IBOutlet weak var profileNumberFollowing: UILabel!
    @IBOutlet weak var profileBio: UILabel!
    
    
    var users = [User]()
    var restPath = "http://server.maplango.com.br/user-rest"
    var userId:Int!
    
    var indicator:ActivityIndicator = ActivityIndicator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        retrieveLoggedUser()
        print("self.userId : ", self.userId)
        self.upServerUser()
//        print("user data")
//        print(user.name)
//        print(user.posts.count)
//        print(user.image)
//        print(user.nationality)
//        print(user.gender)
//        
//        navigationItem.title = user.name
//        
//        profileNationality.text = user.nationality
//        profileNumberPosts.text = user.posts.count.description
//        profileNumberFollowers.text =
//        profileNumberFollowing.text =
//        profileGender.image = user.gender
//        profilePicture.image = user.image
        
        
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
        
        //        //recupera os dados do usuário logado no app
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        self.userId = prefs.integerForKey("id") as Int
        NSLog("usuário logado: %ld", userId)
        
    }
    
    func upServerUser() {
        self.indicator.showActivityIndicator(self.view)

        let params : [String: Int] = [
            "id": self.userId
        ]

        //Checagem remota
        Alamofire.request(.GET, self.restPath, parameters: params)
            .responseSwiftyJSON({ (request, response, json, error) in
                self.indicator.hideActivityIndicator();
                let user = json["data"]
                print(user);
                if let photo = user["image"].string {
                    print("photo de perfil : ", photo)
                    let imgUtils:ImageUtils = ImageUtils()
                    self.profilePicture.image = imgUtils.loadImageFromPath(photo)!
                }
        });
        
    }
}
