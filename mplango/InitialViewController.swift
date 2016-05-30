//
//  InitialViewController.swift
//  mplango
//
//  Created by Carlos Wagner Pereira de Morais on 24/07/15.
//  Copyright (c) 2015 unb.br. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import AlamofireSwiftyJSON

class InitialViewController: UIViewController, FBSDKLoginButtonDelegate {

    @IBOutlet weak var btnConnection: UIButton!
    @IBOutlet weak var btnInscription: UIButton!
    
    @IBOutlet weak var btnFacebook: FBSDKLoginButton!
    
    var email : String!
    var name: String!
    var fbPicture: String!
    var gender:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.btnFacebook.readPermissions = ["public_profile", "email", "user_friends"]
        self.btnFacebook.delegate = self
        
        
        if let token = FBSDKAccessToken.currentAccessToken() {
            btnFacebook.hidden = true
            print("token : ", token)
            self.fetchFBProfile(token.tokenString)
        }
        
        btnConnection.backgroundColor = UIColor.clearColor()
        btnConnection.layer.borderWidth = 3.0
        btnConnection.layer.borderColor = UIColor(hex: 0xFFFFFF).CGColor
        
        
        btnInscription.backgroundColor = UIColor.clearColor()
        btnInscription.layer.borderWidth = 3.0
        btnInscription.layer.borderColor = UIColor(hex: 0xFFFFFF).CGColor
        btnFacebook.hidden = false    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue){}
    
    func mplLogin(email : String) {
        
        ActivityIndicator.instance.showActivityIndicator(self.view);
        Alamofire.request(.GET, EndpointUtils.USER, parameters: ["email": email])
            .responseString { response in
                print("Success: \(response.result.isSuccess)")
                print("Response String: \(response.result.value)")
            }.responseSwiftyJSON({ (request, response, json, error) in
                ActivityIndicator.instance.hideActivityIndicator();
                print(request)
                print(error)
                print(json)
                if json["data"].array?.count > 0 {
                    if let result = json["data"].array {
                        let user = result.first!
                        print("entrou pelo face")
                        
                        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                        
                        if let id = user["id"].int {
                            prefs.setInteger(id, forKey: "id")
                            prefs.setInteger(id, forKey: "logged")
                        }
                        if let name = user["name"].string {
                            prefs.setObject(name, forKey: "name")
                        }
                        prefs.synchronize()
                        
                        self.performSegueWithIdentifier("initial_to_map", sender: self)
                        
                    }
                    
                } else {
                    print("não tem conta face")
                    self.performSegueWithIdentifier("initial_to_account", sender: self)
                }
            })
    }
    
    
    func fetchFBProfile(token : String) {
        print("fetchFBProfile")
        let params = ["fields":"email, id, gender, age_range, name, picture.type(large)"]
        FBSDKGraphRequest.init(graphPath: "me", parameters: params, tokenString: token, version: "v2.0", HTTPMethod: "GET").startWithCompletionHandler { (connection, result, error) -> Void in
            
            if error != nil {
                
                print("fetch facebook Error: \(error)")
                return
            }
            
            if let name = result.objectForKey("name") as? String {
                print(name)
                self.name = name
            }
            
            if let picture = result.objectForKey("picture")?.objectForKey("data")?.objectForKey("url") as? String {
                print(picture)
                self.fbPicture = picture
            }
            
            if let gender = result.objectForKey("gender") as? String {
                print(gender)
                self.gender = gender
            }
            
            if let email = result.objectForKey("email") as? String {
                print(email)
                self.email = email
                self.mplLogin(email);
            }
            
        }
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!)
    {
        print("login face completo")
        self.fetchFBProfile(result.token.tokenString)
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!)
    {}
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        if segue.identifier == "initial_to_account" {//
            let accountVireController:AccountViewController = segue.destinationViewController as! AccountViewController
            accountVireController.fbUserData = [self.email, self.name, self.fbPicture, self.gender]
        }
    }

}
