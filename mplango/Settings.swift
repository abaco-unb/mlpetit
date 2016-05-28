//
//  Settings.swift
//  mplango
//
//  Created by Thomas Petit on 05/11/2015.
//  Copyright © 2015 unb.br. All rights reserved.
//

import UIKit


class Settings: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    @IBAction func backToProfile(sender: AnyObject) {
        
        dismissViewControllerAnimated(true, completion: nil)
        
   }
    @IBAction func logoutTapped(sender: UIButton) {
        
        let loginManager: FBSDKLoginManager = FBSDKLoginManager()
        loginManager.logOut()
    }
    
    
//    @IBAction func editPassword(segue : UIStoryboardSegue){
//        
//    if segue.identifier == "edit_password" {
//        
//        let alertController = UIAlertController(title: "Mot de passe actuel", message: "", preferredStyle: UIAlertControllerStyle.Alert)
//        
//        let saveAction = UIAlertAction(title: "Continuer", style: UIAlertActionStyle.Default, handler: {
//            alert -> Void in
//            
//            let textField = alertController.textFields![0] as UITextField
//            
//        })
//        
//        let cancelAction = UIAlertAction(title: "Annuler", style: UIAlertActionStyle.Default, handler: {
//            (action : UIAlertAction!) -> Void in
//            
//        })
//        
//        alertController.addTextFieldWithConfigurationHandler { (textField : UITextField!) -> Void in
//            textField.placeholder = "Indiquer le mot de passe"
//        }
//        
//        alertController.addAction(saveAction)
//        alertController.addAction(cancelAction)
//        
//        self.presentViewController(alertController, animated: true, completion: nil)
//        
//        }
//    
//    }
    
}
