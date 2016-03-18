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
    
    var indicator:ActivityIndicator = ActivityIndicator()
    
    @IBOutlet weak var currentPasswd: UITextField!
    @IBOutlet weak var newPasswd: UITextField!
    @IBOutlet weak var confNewPasswd: UITextField!
    @IBOutlet weak var confirmBtn: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        retrieveLoggedUser()
        
        // Enable the Save button only if the screen has a valid change
        checkValidChange()
    }

    //MARK: Actions
    
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(false, completion: nil)
    }
    
    @IBAction func confNewPasswd(sender: AnyObject) {
        dismissViewControllerAnimated(false, completion: nil)
    }
    
    func retrieveLoggedUser() {
        
        // recupera os dados do usuário logado no app
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        self.userId = prefs.integerForKey("id") as Int
        NSLog("usuário logado: %ld", userId)
        
    }
    
//    func upServerUser() {
//        self.indicator.showActivityIndicator(self.view)
//        
//        let params : [String: Int] = [
//            "id": self.userId,
//            "name": self.userId,
//            "gender": self.userId,
//            "nationality": self.userId
//        ]
//        
//        //Checagem remota
//        Alamofire.request(.GET, self.restPath, parameters: params)
//            .responseSwiftyJSON({ (request, response, json, error) in
//                self.indicator.hideActivityIndicator();
//                let user = json["data"]
//                print(user);
//               
//                
//                if let username = user["name"].string {
//                    print("show name : ", username)
//                    self.userName.attributedPlaceholder = NSAttributedString(string: username)
//                }
//                
//                if let nat = user["nationality"].string {
//                    print("show nationality : ", nat)
//                    self.userNation.attributedPlaceholder = NSAttributedString(string: nat)
//                }
//                
//            });
//        
//    }
    
    
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
        let text = currentPasswd.text ?? ""
        let text2 = newPasswd.text ?? ""
        let text3 = confNewPasswd.text ?? ""
        
        confirmBtn.enabled = !text.isEmpty
        confirmBtn.enabled = !text2.isEmpty
        confirmBtn.enabled = !text3.isEmpty
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        checkValidChange()
    }
    
}
