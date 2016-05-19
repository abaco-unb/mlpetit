//
//  FollowersTVC.swift
//  mplango
//
//  Created by Thomas Petit on 14/12/2015.
//  Copyright © 2015 unb.br. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class FollowersTVC: UITableViewController {
    
    //MARK: Properties

    var list = [RUser]()
    
    var restPath = "http://server.maplango.com.br/user-rest"
    var userId:Int!
    
    var imagePath: String = ""
    
    var indicator:ActivityIndicator = ActivityIndicator()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        retrieveLoggedUser()
        print("self.userId : ", self.userId)
        self.upServerListUsers()
       
    }
    
    func retrieveLoggedUser() {
        
        // recupera os dados do usuário logado no app
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        self.userId = prefs.integerForKey("id") as Int
        NSLog("usuário logado: %ld", userId)
        
    }
    
    func upServerListUsers() {
        
        self.indicator.showActivityIndicator(self.view)
        //        Checagem remota
        Alamofire.request(.GET, self.restPath)
            .responseSwiftyJSON({ (request, response, json, error) in
                if let users = json["data"].array {
                    for user in users {
                        var id:Int = 0
                        var email:String = ""
                        var gender:String = ""
                        var name:String  = ""
                        var nationality:String = ""
                        var password:String = ""
                        var image:String = ""
                        var level:Int = 0
                        var bio:String = ""
                        var category: String = "";
                        
                        if let userId = user["id"].int {
                            id = userId
                        }
                        
                        if let userEmail = user["email"].string {
                            email = userEmail
                            
                        }
                        
                        if let userGender = user["gender"].string {
                            gender = userGender
                            
                        }
                        
                        if let userName = user["name"].string {
                            name = userName
                            
                        }
                        
                        if let userNationality = user["nationality"].string {
                            nationality = userNationality
                            
                        }
                        
                        if let userPwd = user["password"].string {
                            password = userPwd
                            
                        }
                        
                        if let userImage = user["image"].string {
                            image = userImage
                            
                        }
                        
                        
                        if let userLevel = user["level"].int {
                            level = userLevel
                            
                        }
                        
                        if let userBio = user["bio"].string {
                            bio = userBio
                            
                        }
                        
                        //AQUI MUDAR PELA CATEGORIA (MEDIADOR OU APRENDENTE)
                        if let userCat = user["name"].string {
                            category = userCat
                        }
                        
                        self.list.append(RUser(id: id, email: email, name: name, gender: gender, password: password, nationality: nationality, image: image, level: level, bio: bio, category: category))
                        
                    }
                    self.indicator.hideActivityIndicator();
                    self.tableView.reloadData()
                    
                }
            });
        
    }
    
    // MARK: Actions
    
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    let sections:Array<AnyObject> = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"]
    
    // MARK:- Retrieve Users
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.list.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        
        if indexPath.row == 0 {
            cell = tableView.dequeueReusableCellWithIdentifier("SegmentCell", forIndexPath: indexPath)
            
        } else {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! ContactCell
            cell.contactName.text = self.list[indexPath.row].name
            cell.contactPicture.image  = UIImage(named: self.list[indexPath.row].image)
            cell.contactPicture.layer.masksToBounds = true
            cell.contactPicture.layer.cornerRadius = 35
            
            return cell
            
        }
        
        return cell
    }
    
    //Para mostrar o index do alfabeto à direita da tela
    //override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
    //    return self.sections
    //}
    
    override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return index
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section] as? String
    }
    
    // MARK: - TableView Refresh
    
    func controllerDidChangeContent(controller: RUser) {
        tableView.reloadData()
    }
    
    
    @IBAction func followUserTapped(sender: UIButton) {
        print("add user to this")
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        print(sender)
        if segue.identifier == "show_profile" {
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPathForCell(cell)
            let contactViewController:ProfileVC = segue.destinationViewController as! ProfileVC
            let contact:RUser = self.list[indexPath!.row]
            contactViewController.contact = contact
            
        }
    }
    
}

