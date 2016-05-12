//
//  ChangePasswrd.swift
//  mplango
//
//  Created by Thomas Petit on 05/11/2015.
//  Copyright © 2015 unb.br. All rights reserved.
//

import Alamofire
import SwiftyJSON
import UIKit

class ChangePasswrd: UIViewController, UITextFieldDelegate {
    
    var users = [User]()
    var restPath = "http://server.maplango.com.br/user-rest"
    var userId:Int!
    
    var username:String = ""
    var pwd:String      = ""
    var registered: Bool = false
    var indicator:ActivityIndicator = ActivityIndicator()
    
    @IBOutlet weak var newPasswd: UITextField!
    @IBOutlet weak var confNewPasswd: UITextField!
    @IBOutlet weak var confirmBtn: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        retrieveLoggedUser()
        print("self.userId : ", self.userId)
        self.upServerUser()

        // Enable the Save button only if the screen has a valid change
        checkValidChange()
        
        
        var inputTextField: UITextField?
        let passwordPrompt = UIAlertController(title: "Mot de passe actuel", message: "Par sécurité, entrer le mot de passe actuel", preferredStyle: UIAlertControllerStyle.Alert)
        
        passwordPrompt.addAction(UIAlertAction(title: "Annuler", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
            
        }))
        
        passwordPrompt.addAction(UIAlertAction(title: "Continuer", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            
            self.pwd = inputTextField!.text! as String
            
            if ( self.pwd.isEmpty ) {
                
                //New Alert Ccontroller
                let alertController = UIAlertController(title: "Échec", message: "Il est nécessaire d'indiquer un mot de passe", preferredStyle: .Alert)
                let agreeAction = UIAlertAction(title: "Ok", style: .Default) { (action) -> Void in
                    print("The user is okay.")
                    self.dismissViewControllerAnimated(true, completion: nil)

                }
                alertController.addAction(agreeAction)
                self.presentViewController(alertController, animated: true, completion: nil)
                
                
            } else {
                self.indicator.showActivityIndicator(self.view);
                Alamofire.request(.GET, EndpointUtils.USER, parameters: ["password": self.pwd])
                    .responseSwiftyJSON({ (request, response, json, error) in
                        self.indicator.hideActivityIndicator();
                        
                        if json["data"].array?.count > 0 {
                            
                            if let result = json["data"].array {
                                let user = result.first!
                                print(user["password"].stringValue)
                                if(user["password"].stringValue == self.pwd){
                                    let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                                    
//                                    if let id = user["id"].int {
//                                        prefs.setInteger(id, forKey: "id")
//                                        prefs.setInteger(id, forKey: "logged")
//                                    }
//                                    if let name = user["name"].string {
//                                        prefs.setObject(name, forKey: "name")
//                                    }
                                    
                                    prefs.synchronize()
                                    //TODO - sincronizar com o coredata
//                                    self.performSegueWithIdentifier("edit_password", sender: action)
                                   
                                    
                                } else {
                                    NSLog("@resultado : %@", "FALHOU LOGIN !!!")
                                    NSOperationQueue.mainQueue().addOperationWithBlock {
                                        
                                        //New Alert Ccontroller
                                        let alertController = UIAlertController(title: "Opération annulée", message: "Mot de passe incorrect", preferredStyle: .Alert)
                                        let agreeAction = UIAlertAction(title: "Ok", style: .Default) { (action) -> Void in
                                            print("The user is okay.")
                                            self.dismissViewControllerAnimated(true, completion: nil)

                                        }
                                        alertController.addAction(agreeAction)
                                        self.presentViewController(alertController, animated: true, completion: nil)
                                        
                                    }
                                }
                            }
                            
                        } else {
                            NSOperationQueue.mainQueue().addOperationWithBlock {
                                
                                //New Alert Ccontroller
                                let alertController = UIAlertController(title: "Opération annulée", message: "Mot de passe incorrect", preferredStyle: .Alert)
                                let agreeAction = UIAlertAction(title: "Ok", style: .Default) { (action) -> Void in
                                    print("The user is okay.")
                                    self.dismissViewControllerAnimated(true, completion: nil)

                                }
                                alertController.addAction(agreeAction)
                                self.presentViewController(alertController, animated: true, completion: nil)
                                
                            }
                        }
                    })
            }

        
        }))
        
        passwordPrompt.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.placeholder = "Mot de passe"
            textField.secureTextEntry = true
            inputTextField = textField
        })
        
        presentViewController(passwordPrompt, animated: true, completion: nil)
        
        
    }

    //MARK: Actions
    
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(false, completion: nil)
    }
    
    @IBAction func confNewPasswd(sender: AnyObject) {
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let userId:Int = prefs.integerForKey("id") as Int
        print("atualizando o email...")
        print(userId)
        
        let passwrd: String = newPasswd.text! as String
        let confPasswrd: String = confNewPasswd.text! as String
        
        
        if ( passwrd.isEmpty ) {
            
            //New Alert Ccontroller
            let alertController = UIAlertController(title: "Erro ao tentar Registrar os Dados!", message: "Campo email obrigatório", preferredStyle: .Alert)
            let agreeAction = UIAlertAction(title: "Ok", style: .Default) { (action) -> Void in
                print("The user is okay.")
            }
            alertController.addAction(agreeAction)
            self.presentViewController(alertController, animated: true, completion: nil)
            
            
        } else if ( !passwrd.isEmpty  && confPasswrd.isEmpty) {
            
            //New Alert Ccontroller
            let alertController = UIAlertController(title: "Erro ao tentar Registrar os Dados!", message: "É necessário confirmar sua senha", preferredStyle: .Alert)
            let agreeAction = UIAlertAction(title: "Ok", style: .Default) { (action) -> Void in
                print("The user is okay.")
            }
            alertController.addAction(agreeAction)
            self.presentViewController(alertController, animated: true, completion: nil)
            
            
        } else if (passwrd != confPasswrd) {
            
            //New Alert Ccontroller
            let alertController = UIAlertController(title: "Erro ao tentar Registrar os Dados!", message: "O e-mail não confere com a confirmação", preferredStyle: .Alert)
            let agreeAction = UIAlertAction(title: "Ok", style: .Default) { (action) -> Void in
                print("The user is okay.")
            }
            alertController.addAction(agreeAction)
            self.presentViewController(alertController, animated: true, completion: nil)
            
        } else {
            
            
            let params : [String: String] = [
                "password" : self.confNewPasswd.text!,
                ]
            
            let urlEdit :String = restPath + "?id=" + String(userId)
            
            Alamofire.request(.PUT, urlEdit , parameters: params)
                .responseString { response in
                    print("Success: \(response.result.isSuccess)")
                    print("Response String: \(response.result.value)")
                }.responseSwiftyJSON({ (request, response, json, error) in
                    if (error == nil) {
                        NSOperationQueue.mainQueue().addOperationWithBlock {
                            
                            //New Alert Ccontroller
                            let alertController = UIAlertController(title: "Félicitations", message: "Mot de passe changé avec succès", preferredStyle: .Alert)
                            let agreeAction = UIAlertAction(title: "Ok", style: .Default) { (action) -> Void in
                                print("The user is okay.")
                                self.indicator.hideActivityIndicator();
                                self.performSegueWithIdentifier("change_password", sender: self)
                            }
                            alertController.addAction(agreeAction)
                            self.presentViewController(alertController, animated: true, completion: nil)
                            
                        }

                    } else {
                        NSOperationQueue.mainQueue().addOperationWithBlock {
                            //New Alert Ccontroller
                            let alertController = UIAlertController(title: "Oops", message: "Tivemos um problema ao tentar atualizar sua senha. Favor tente novamente.", preferredStyle: .Alert)
                            let agreeAction = UIAlertAction(title: "Ok", style: .Default) { (action) -> Void in
                                print("The password update is not okay.")
                                self.indicator.hideActivityIndicator();
                            }
                            alertController.addAction(agreeAction)
                            self.presentViewController(alertController, animated: true, completion: nil)
                        }
                    }
                    
                })
            
        }

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
            "id": self.userId,
            ]
        
        Alamofire.request(.GET, EndpointUtils.USER, parameters: params)
            .responseSwiftyJSON({ (request, response, json, error) in
                self.indicator.hideActivityIndicator();
                let user = json["data"]
                print(user);
                
            });
    }

    
    
    //MARK: enable confirm button
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidBeginEditing(textField: UITextField) {
        // Disable the Save button while editing.
        confirmBtn.enabled = false
    }
    
    func checkValidChange() {
        // Disable the Save button if the text field is empty.
        let text1 = newPasswd.text ?? ""
        let text2 = confNewPasswd.text ?? ""
        
        confirmBtn.enabled = !text1.isEmpty
        confirmBtn.enabled = !text2.isEmpty
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        checkValidChange()
    }
    
}
