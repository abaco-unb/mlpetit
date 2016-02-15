//
//  LoginViewController.swift
//  mplango
//
//  Created by Bruno Ferreira on 12/05/15.
//  Copyright (c) 2015 unb.br. All rights reserved.
//


import Alamofire
import SwiftyJSON
import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var textFieldUsername: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    
    
    var users = [User]()
    var restPath = "http://server.maplango.com.br/user-rest"
    
    var username:String = ""
    var pwd:String      = ""
    var registered: Bool = false
    var indicator:ActivityIndicator = ActivityIndicator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(self.registered) {
            NSOperationQueue.mainQueue().addOperationWithBlock{
                let alertView:UIAlertView = UIAlertView()
                alertView.title = "Registro de conta!"
                alertView.message = "Cadastro realizado com sucesso!"
                alertView.delegate = self
                alertView.addButtonWithTitle("OK")
                alertView.show()
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
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
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
            
            let alertView:UIAlertView = UIAlertView()
            alertView.title = "Login falhou!"
            alertView.message = "É necessário inserir seu email e senha"
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
            
        } else {
            self.indicator.showActivityIndicator(self.view);
            Alamofire.request(.GET, self.restPath, parameters: ["email": self.username])
                .responseSwiftyJSON({ (request, response, json, error) in
                    self.indicator.hideActivityIndicator();
                    
                    if json["data"].array?.count > 0 {
                        
                        if let result = json["data"].array {
                            let user = result.first!
                            print(user["password"].stringValue)
                            if(user["password"].stringValue == self.pwd){
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
                                NSLog("@resultado : %@", "FALHOU LOGIN !!!")
                                NSOperationQueue.mainQueue().addOperationWithBlock {
                                    let alertView:UIAlertView = UIAlertView()
                                    alertView.title = "Login falhou!"
                                    alertView.message = "Usuário ou senha incorretos!"
                                    alertView.delegate = self
                                    alertView.addButtonWithTitle("OK")
                                    alertView.show()
                                }
                            }
                        }
                        
                    } else {
                        NSOperationQueue.mainQueue().addOperationWithBlock {
                            let alertView:UIAlertView = UIAlertView()
                            alertView.title = "Login falhou!"
                            alertView.message = "Usuário ou senha incorretos!"
                            alertView.delegate = self
                            alertView.addButtonWithTitle("OK")
                            alertView.show()
                        }
                    }
                })
        }
    }
    
    
    @IBAction func cancelTapped(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    //    func fetchUser() {
    //        let fetchRequest = NSFetchRequest(entityName: "User")
    //        let sortDescriptor = NSSortDescriptor(key: "email", ascending: true)
    //        fetchRequest.sortDescriptors = [sortDescriptor]
    //        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    //        let contxt: NSManagedObjectContext = appDel.managedObjectContext!
    //        if let fetchResults = (try? contxt.executeFetchRequest(fetchRequest)) as? [User] {
    //            users = fetchResults
    //        }
    //    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
}
