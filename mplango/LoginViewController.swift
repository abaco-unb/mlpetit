//
//  LoginViewController.swift
//  mplango
//
//  Created by Bruno Ferreira on 12/05/15.
//  Copyright (c) 2015 unb.br. All rights reserved.
//


import Alamofire
import SwiftyJSON
import AlamofireSwiftyJSON
import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var textFieldUsername: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    
    
    var users = [User]()
    
    var email : String!
    var name: String!
    var fbPicture: String!
    var gender:String!
    
    var loginFB: Bool = false
    var username:String = ""
    var pwd:String      = ""
    var registered: Bool = false
    var indicator:ActivityIndicator = ActivityIndicator()
    
    @IBOutlet var btnFacebook: FBSDKLoginButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("passou na tela de login")
        
        self.btnFacebook.readPermissions = ["public_profile", "email", "user_friends"]
        self.btnFacebook.delegate = self
        
        if let token = FBSDKAccessToken.currentAccessToken() {
            print("token : ", token)
            self.fetchFBProfile(token.tokenString)
            //self.mplLogin(strEmail)
        }
        
        if(self.registered) {
            NSOperationQueue.mainQueue().addOperationWithBlock{
                
                //New Alert Ccontroller
                let alertController = UIAlertController(title: "Registro de conta!", message: "Cadastro realizado com sucesso!", preferredStyle: .Alert)
                let agreeAction = UIAlertAction(title: "Ok", style: .Default) { (action) -> Void in
                    print("The user is okay.")
                }
                alertController.addAction(agreeAction)
                self.presentViewController(alertController, animated: true, completion: nil)

            }
        }
        
        textFieldUsername.backgroundColor = UIColor.clearColor()
        textFieldUsername.layer.borderWidth = 3.0
        textFieldUsername.layer.borderColor = UIColor(hex: 0xFFFFFF).CGColor
        textFieldUsername.attributedPlaceholder =
            NSAttributedString(string: "Email ou nom d'utilisateur", attributes:[NSForegroundColorAttributeName : UIColor.whiteColor()])
        
        textFieldPassword.backgroundColor = UIColor.clearColor()
        textFieldPassword.layer.borderWidth = 3.0
        textFieldPassword.layer.borderColor = UIColor(hex: 0xFFFFFF).CGColor
        textFieldPassword.attributedPlaceholder =
            NSAttributedString(string: "Mot de passe", attributes:[NSForegroundColorAttributeName : UIColor.whiteColor()])
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
        
    }
    
    
    //Text field delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    override func viewDidAppear(animated: Bool) {
        //self.performSegueWithIdentifier("goto_map", sender: self)
        
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
                self.loginFB = true
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
    {
        let loginManager: FBSDKLoginManager = FBSDKLoginManager()
        loginManager.logOut()
        //ivUserProfileImage.image = nil
        //lblName.text = ""
    }
    
    
    
    @IBAction func loginTapped(sender: UIButton) {
        
        self.username = textFieldUsername.text! as String
        self.pwd = textFieldPassword.text! as String
        
        if ( self.username.isEmpty || self.pwd.isEmpty ) {
            
            //New Alert Ccontroller
            let alertController = UIAlertController(title: "Login falhou!", message: "É necessário inserir seu email e senha", preferredStyle: .Alert)
            let agreeAction = UIAlertAction(title: "Ok", style: .Default) { (action) -> Void in
                print("The user is okay.")
            }
            alertController.addAction(agreeAction)
            self.presentViewController(alertController, animated: true, completion: nil)
            
        } else {
            
           self.mplLogin(self.username)
            
        }
    }
    
    func mplLogin(email : String) {
        
        print("loginFB", loginFB)
        
        self.indicator.showActivityIndicator(self.view);
        Alamofire.request(.GET, EndpointUtils.USER, parameters: ["email": email])
            .responseSwiftyJSON({ (request, response, json, error) in
                self.indicator.hideActivityIndicator();
                print("bruno")
                if json["data"].array?.count > 0 {
                    
                    if let result = json["data"].array {
                        let user = result.first!
                        print(user["password"].stringValue)
                        
                        if(self.loginFB || user["password"].stringValue == self.pwd){
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
                            //TODO - sincronizar com o coredata
                            self.performSegueWithIdentifier("goto_map", sender: self)
                        } else {
                            print("entrou pelo face")
                            
                            NSLog("@resultado : %@", "FALHOU LOGIN !!!")
                            NSOperationQueue.mainQueue().addOperationWithBlock {
                                    
                            //New Alert Ccontroller
                            let alertController = UIAlertController(title: "Login falhou!", message: "Usuário ou senha incorretos!", preferredStyle: .Alert)
                            let agreeAction = UIAlertAction(title: "Ok", style: .Default) { (action) -> Void in
                            print("The user is okay.")
                            }
                            alertController.addAction(agreeAction)
                            self.presentViewController(alertController, animated: true, completion: nil)
                            }
                        }
                    }
                    
                } else {
                    if self.loginFB  {
                        self.performSegueWithIdentifier("login_to_account", sender: self)
                    } else {
                        NSOperationQueue.mainQueue().addOperationWithBlock {
                            
                            //New Alert Ccontroller
                            let alertController = UIAlertController(title: "Login falhou!", message: "Usuário ou senha incorretos!", preferredStyle: .Alert)
                            let agreeAction = UIAlertAction(title: "Ok", style: .Default) { (action) -> Void in
                                print("The user is okay.")
                            }
                            alertController.addAction(agreeAction)
                            self.presentViewController(alertController, animated: true, completion: nil)
                            
                        }
                    }
                    
                }
            })
    }
    
    @IBAction func cancelTapped(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        if segue.identifier == "login_to_account" {//
            let accountVireController:AccountViewController = segue.destinationViewController as! AccountViewController
            accountVireController.fbUserData = [self.email, self.name, self.fbPicture, self.gender]
        }
    }
}
