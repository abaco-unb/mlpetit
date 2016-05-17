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
    
    var contact: RUser!
    var userId:Int!
    
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
        
        if contact != self.userId {
            
            self.navigationItem.leftBarButtonItem = nil
            self.navigationItem.backBarButtonItem!.enabled = true
            self.navigationItem.backBarButtonItem!.title = "liste"
    
            self.navigationItem.title = contact.name
            self.profileNationality.text = contact.nationality
            self.profileBio.text = contact.bio
            
            let image = ImageUtils.instance.loadImageFromPath(contact.image)
            if (!contact.image.isEmpty && image != nil){
                print("image inneer")
                print(image)
                profilePicture.image = image
            }
            else {
                profilePicture.image = UIImage(named: "empty_profile")
            }
            
            if contact.gender == "Homme" {
                self.profileGender.image = UIImage(named:"icon_masc_profile")
            }
            else if contact.gender == "Femme" {
                self.profileGender.image = UIImage(named:"icon_fem_profile")
            }

            if contact.level == User.BEGINNER {
                self.profileLangLevel.image = UIImage(named: "profile_niv1")
            }
            else if contact.level == User.HIGH_BEGINNER {
                self.profileLangLevel.image = UIImage(named: "profile_niv2")
            }
            else if contact.level == User.INTERMEDIATE {
                self.profileLangLevel.image = UIImage(named: "profile_niv3")
            }
            else if contact.level == User.ADVANCED {
                self.profileLangLevel.image = UIImage(named: "profile_niv4")
            }
            else if contact.level == User.MEDIATOR {
                self.profileLangLevel.image = UIImage(named: "profile_nivM")
            }
                       
            //        self.profileNumberPosts.text =
            //        self.profileNumberFollowers.text =
            //        self.profileNumberFollowing.text =
            
        } else {
            
            retrieveLoggedUser()
            print("self.userId : ", self.userId)
            self.upServerUser()
            
        }
        
        profilePicture.layer.cornerRadius = 40
        profilePicture.layer.masksToBounds = true
        
    }

    
    
    func showProfileGameVC() {
        self.performSegueWithIdentifier("showBadges", sender: self)
    }
    
    func retrieveLoggedUser() {
        
        // recupera os dados do usuário logado no app
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
        Alamofire.request(.GET, EndpointUtils.USER, parameters: params)
            .responseSwiftyJSON({ (request, response, json, error) in
                self.indicator.hideActivityIndicator();
                let user = json["data"]
                print(user);
                
                    if let photo = user["image"].string {
                    print("show photo : ", photo)
                        self.profilePicture.image = ImageUtils.instance.loadImageFromPath(EndpointUtils.USER + "?id=" + String( self.userId ) + "&avatar=true")
                    }
                
                    if let username = user["name"].string {
                    print("show name : ", username)
                    self.navigationItem.title = (username)
                    }
                
                    if let nat = user["nationality"].string {
                    print("show nationality : ", nat)
                    self.profileNationality.text = (nat)
                    }
                

                    if let gen = user["gender"].string {
                    print("show gender : ", gen)
                        if gen == "Homme" {
                            self.profileGender.image = UIImage(named: "icon_masc_profile")
                        }
                        else if gen == "Femme" {
                            self.profileGender.image = UIImage(named: "icon_fem_profile")
                        }
                    }
                
                    if let lev = user["level"]["id"].int {
                    print("show level : ", lev)
                        if lev == User.BEGINNER {
                            self.profileLangLevel.image = UIImage(named: "profile_niv1")
                        }
                        else if lev == User.HIGH_BEGINNER {
                            self.profileLangLevel.image = UIImage(named: "profile_niv2")
                        }
                        else if lev == User.INTERMEDIATE {
                            self.profileLangLevel.image = UIImage(named: "profile_niv3")
                        }
                        else if lev == User.ADVANCED {
                            self.profileLangLevel.image = UIImage(named: "profile_niv4")
                        }
                        else if lev == User.MEDIATOR {
                            self.profileLangLevel.image = UIImage(named: "profile_nivM")
                        }
                    }
                
                    if let bio = user["bio"].string {
                    print("show bio : ", bio)
                    self.profileBio.text = (bio)
                    }

                
                

//        profileNumberPosts.text = user.posts.count.description
                
                

                
        });
        
    }
    
    @IBAction func unwindSecondView(segue: UIStoryboardSegue) {
        print ("unwindSecondView fired in first view")
        print("self.userId : ", self.userId)
        self.upServerUser()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        print(sender)
//        if segue.identifier == "show_badges" {
//            let gamificationController:ProfileGameVC = segue.destinationViewController as! ProfileGameVC
//            let gameProfile:RUser = self.user
//            gamificationController.gameProfile = gameProfile
//            
//        }
    }

    
}
