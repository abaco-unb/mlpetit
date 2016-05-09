//
//  ListUsersTVC.swift
//  mplango
//
//  Created by Carlos Wagner Pereira de Morais on 28/06/15.
//  Copyright (c) 2015 unb.br. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ContactViewController: UITableViewController {
    
    //MARK: Properties
    
    var list = [RUser]()
    
    var profileFilter:NSNumber = 2
    
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
                        var bio:String = "";
                        
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
                        
                        self.list.append(RUser(id: id, email: email, name: name, gender: gender, password: password, nationality: nationality, image: image, level: level, bio: bio))
                        
                    }
                    self.indicator.hideActivityIndicator();
                    self.tableView.reloadData()
                    
                }
            });
        
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

            cell.contactPicture.image = ImageUtils.instance.loadImageFromPath(EndpointUtils.USER + "?id=" + self.list[indexPath.row].id + "&avatar=true")
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
    
    /*
    
    @IBAction func segmentChanged(sender: UISegmentedControl) {
        println("TESTE");
        
        if self.segmentControl == 0 {
            println("Apprenants");
        } else if self.segmentControl == 1{
            println("Médiateurs");
        } else {
            println("All")
        }
        
        /*
        println(sender.selectedSegmentIndex)
        switch segmentControl.selectedSegmentIndex {
        case 0:
            println("aprendente");
        case 1:
            println("mediador");
        default:
            break
        }*/
    }*/
    
    
    
    @IBAction func indexSegment(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            print("Apprenants");
            self.tableView.reloadData()
        } else if sender.selectedSegmentIndex == 1{
            print("Médiateurs");
        } else {
            print("All")
        }
    }
    
//    @IBAction func segmentedTapped(sender: UISegmentedControl) {
//        switch sender.selectedSegmentIndex {
//        case 0:
//            profileFilter = 0
//        case 1:
//            profileFilter = 1
//        default:
//            profileFilter = 2
//            break
//        }
//        print("sender.selectedSegmentIndex")
//        print(sender.selectedSegmentIndex)
//        fetchedResultController = getFetchedResultController()
//        do {
//            try fetchedResultController.performFetch()
//        } catch _ {
//        }
//        tableView.reloadData()
//    }
    
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

