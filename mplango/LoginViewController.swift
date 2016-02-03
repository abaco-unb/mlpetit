//
//  LoginViewController.swift
//  mplango
//
//  Created by Bruno Ferreira on 12/05/15.
//  Copyright (c) 2015 unb.br. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var textFieldUsername: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    
    
    var users = [User]()
    var restPath = "http://server.maplango.com.br/user-rest"
    
    var username:String = ""
    var pwd:String      = ""
    var registered: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(self.registered) {
            NSOperationQueue.mainQueue().addOperationWithBlock{
                let alertView:UIAlertView = UIAlertView()
                alertView.title = "Registro de conta!"
                alertView.message = "CAdastro realizado com sucesso!"
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
            
            Alamofire.request(.GET, self.restPath, parameters: ["foo": "bar"])
                .responseSwiftyJSON({ (request, response, json, error) in
                    if let users = json.array {
                        
                        var hasLogin:Bool = false
                        for user in  users{
                            if((user["email"].string! == self.username) && user["password"].string! == self.pwd){
                                hasLogin = true
                                
                                print("aqui")
                                let id = user["id"].int!
                                //let name = user["name"].string!
                                print(id)
                                let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                                prefs.setInteger(id, forKey: "id")
                                //prefs.setObject(name, forKey: "name")
                                prefs.setInteger(1, forKey: "logged")
                                prefs.synchronize()
                                
                                //TODO - sincronizar com o coredata
                                print(user)
                                break
                            }
                        }
                        if(!hasLogin) {
                            NSLog("@resultado : %@", "FALHOU !!!")
                            NSOperationQueue.mainQueue().addOperationWithBlock {
                                let alertView:UIAlertView = UIAlertView()
                                alertView.title = "Login falhou!"
                                alertView.message = "Usuário ou senha incorretos!"
                                alertView.delegate = self
                                alertView.addButtonWithTitle("OK")
                                alertView.show()
                            }
                            
                        } else {
                            NSOperationQueue.mainQueue().addOperationWithBlock {
                                print("antes de ir")
                                self.performSegueWithIdentifier("goto_map", sender: self)
                            }
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
