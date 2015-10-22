//
//  LoginViewController.swift
//  mplango
//
//  Created by Bruno Ferreira on 12/05/15.
//  Copyright (c) 2015 unb.br. All rights reserved.
//

import UIKit
import CoreData

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var textFieldUsername: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    
    
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        let username:String = textFieldUsername.text!
        let password:String = textFieldPassword.text!
        
        if ( username.isEmpty || password.isEmpty ) {
            
            let alertView:UIAlertView = UIAlertView()
            alertView.title = "Login falhou!"
            alertView.message = "É necessário inserir seu email e senha"
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
            
        } else {
            
            let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let contxt: NSManagedObjectContext = appDel.managedObjectContext!
            let fetchRequest = NSFetchRequest(entityName: "User")
            let predicate = NSPredicate(format: "name == %@ && password == %@", username, password)
            fetchRequest.predicate = predicate
            
            if let fetchResults = (try? contxt.executeFetchRequest(fetchRequest)) as? [User] {
                
                if (fetchResults.count > 0) {
                    
                    let email: String = fetchResults[0].email
                    let pwd: String   = fetchResults[0].password
                    
                    NSLog("login autenticado: %ld", email)
                    NSLog("pwd autenticada: %ld", pwd)
                    
                    let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                    //prefs.setObject(fetchResults[0], forKey: "USER")
                    //prefs.setObject(fetchResults[0] as MUser, forKey: "USER")
                    prefs.setObject(fetchResults[0].name, forKey: "USERNAME")
                    prefs.setObject(fetchResults[0].email, forKey: "USEREMAIL")
                    prefs.setInteger(1, forKey: "ISLOGGEDIN")
                    prefs.synchronize()
                    
                    self.performSegueWithIdentifier("goto_map", sender: self)
                
                } else {
                    let alertView:UIAlertView = UIAlertView()
                    alertView.title = "Login falhou!"
                    alertView.message = "Usuário ou senha inexistente no banco de dados!"
                    alertView.delegate = self
                    alertView.addButtonWithTitle("OK")
                    alertView.show()
                }
                
            }
        }
    }
    
    func fetchUser() {
        let fetchRequest = NSFetchRequest(entityName: "User")
        let sortDescriptor = NSSortDescriptor(key: "email", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let contxt: NSManagedObjectContext = appDel.managedObjectContext!
        if let fetchResults = (try? contxt.executeFetchRequest(fetchRequest)) as? [User] {
            users = fetchResults
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
}
