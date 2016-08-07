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

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var textFieldUsername: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    
    
    var users = [User]()
    
    var username:String = ""
    var pwd:String      = ""
    var registered: Bool = false 
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("passou na tela de login")
        
        if(self.registered) {
            NSOperationQueue.mainQueue().addOperationWithBlock{
                
                //New Alert Ccontroller
                let alertController = UIAlertController(title: "Inscription finalisée", message: "Bienvenue dans le réseau MapLango", preferredStyle: .Alert)
                let agreeAction = UIAlertAction(title: "Merci", style: .Default) { (action) -> Void in
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
            NSAttributedString(string: "Email du compte", attributes:[NSForegroundColorAttributeName : UIColor.whiteColor()])
        
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
    
    @IBAction func loginTapped(sender: UIButton) {
        
        self.username = textFieldUsername.text! as String
        self.pwd = textFieldPassword.text! as String
        
        if ( self.username.isEmpty || self.pwd.isEmpty ) {
            
            //New Alert Ccontroller
            let alertController = UIAlertController(title: "La connexion a échoué", message: "Il faut insérer l'email et le mot de passe du compte", preferredStyle: .Alert)
            let agreeAction = UIAlertAction(title: "D'accord", style: .Default) { (action) -> Void in
                print("The user is okay.")
            }
            alertController.addAction(agreeAction)
            self.presentViewController(alertController, animated: true, completion: nil)
            
        } else {
            
           self.mplLogin()
            
        }
    }
    
    func mplLogin() {
        
        ActivityIndicator.instance.showActivityIndicator(self.view);
        Alamofire.request(.GET, EndpointUtils.USER, parameters: ["email": self.username])
            .responseString { response in
                print("Success: \(response.result.isSuccess)")
                print("Response String: \(response.result.value)")
            }.responseSwiftyJSON({ (request, response, json, error) in
                ActivityIndicator.instance.hideActivityIndicator();
                print("bruno")
                if json["data"].array?.count > 0 {
                    
                    if let result = json["data"].array {
                        let user = result.first!
                        
                        if(user["password"].stringValue == self.pwd){
                            
                            let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                            
                            if let id = user["id"].int {
                                prefs.setInteger(id, forKey: "id")
                                prefs.setInteger(id, forKey: "logged")
                            }
                            if let name = user["name"].string {
                                prefs.setObject(name, forKey: "name")
                            }
                            
                            if let badgeRef = user["badge"].int {
                                prefs.setInteger(badgeRef, forKey: "badge")
                            }
                            
                            prefs.synchronize()
                            
                            self.performSegueWithIdentifier("goto_map", sender: self)
                        } else {

                            NSLog("@resultado : %@", "FALHOU LOGIN !!!")
                            NSOperationQueue.mainQueue().addOperationWithBlock {
                                    
                                //New Alert Ccontroller
                                let alertController = UIAlertController(title: "La connexion a échoué", message: "Email et/ou mot de passe invalide(s)", preferredStyle: .Alert)
                                let agreeAction = UIAlertAction(title: "D'accord", style: .Default) { (action) -> Void in
                                    print("The user not is okay.")
                                }
                                alertController.addAction(agreeAction)
                                self.presentViewController(alertController, animated: true, completion: nil)
                            }
                        }
                    }
                    
                } else {
                    
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                            
                        //New Alert Ccontroller
                        let alertController = UIAlertController(title: "La connexion a échoué", message: "Email et/ou mot de passe invalide(s)", preferredStyle: .Alert)
                        let agreeAction = UIAlertAction(title: "D'accord", style: .Default) { (action) -> Void in
                            print("The user is not okay.")
                        }
                        alertController.addAction(agreeAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                            
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
    
}
