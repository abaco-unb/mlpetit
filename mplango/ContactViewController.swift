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
    var filteredList = [RUser]()

    var profileFilter:NSNumber = 2
    var userId:Int!
    
    var imagePath: String = ""

    var indicator:ActivityIndicator = ActivityIndicator()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        retrieveLoggedUser()
        print("self.userId : ", self.userId)
        self.upServerListUsers()
        
        searchController.searchBar.delegate = self
        searchController.searchBar.tintColor = UIColor.whiteColor()
        
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
        Alamofire.request(.GET, EndpointUtils.USER)
            .responseSwiftyJSON({ (request, response, json, error) in
                if let users = json["data"].array {
                    for user in users {
                        var id: Int = 0
                        var email:String = ""
                        var gender:String = ""
                        var name:String  = ""
                        var nationality:String = ""
                        var password:String = ""
                        var imageUrl:String = ""
                        var level:Int = 0
                        var bio:String = ""
                        var category: String = "";
                        
                        if let userId = user["id"].int {
                            print("show id : ", userId)
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
                            print("show photo : ",userImage)
                            
                            if (user["image"].string != nil){
                                imageUrl = EndpointUtils.USER + "?id=" + String(id) + "&avatar=true"
                            }
                            
                        }
                        
                        if let userLevel = user["level"]["id"].int {
                            print("show level : ",userLevel)
                            level = userLevel
                            
                        }
                        
                        if let userBio = user["bio"].string {
                            bio = userBio
                            
                        }
                        
                        //AQUI MUDAR PELA CATEGORIA (MEDIADOR OU APRENDENTE)
                        if let userCat = user["name"].string {
                            category = userCat
                        }
                        
                        self.list.append(RUser(id: id, email: email, name: name, gender: gender, password: password, nationality: nationality, image: imageUrl, level: level, bio: bio, category: category))
                        
                    }
                    self.indicator.hideActivityIndicator();
                    self.tableView.reloadData()
                    
                }
            });
        
    }
    
    // MARK: Search bar
    
    func filterContentForSearchText(searchText: String, scope: String = "Tous") {
    filteredList = list.filter { contact in
        let categoryMatch = (scope == "Tous") || (contact.category == scope)
        return categoryMatch && contact.name.lowercaseString.containsString(searchText.lowercaseString)
    }
    
    tableView.reloadData()
    }
    
    
    @IBAction func showSearchBar(sender: AnyObject) {
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        searchController.searchBar.placeholder = "Rechercher"
        searchController.searchBar.scopeButtonTitles = ["Tous", "Apprenants", "Médiateurs"]

    }
    

    // MARK:- Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active && searchController.searchBar.text != "" {
            return filteredList.count
        }
        return self.list.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
            let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! ContactCell
        
            let contact: RUser
            if searchController.active && searchController.searchBar.text != "" {
                contact = self.filteredList[indexPath.row]
            } else {
                contact = self.list[indexPath.row]
            }
            

            cell.contactName.text = contact.name
//            cell.contactCategory.text = contact.category

            cell.contactPicture.image = ImageUtils.instance.loadImageFromPath(EndpointUtils.USER + "?id=" + String(contact.id) + "&avatar=true")
            cell.contactPicture.layer.masksToBounds = true
            cell.contactPicture.layer.cornerRadius = 30

            return cell

    }
    
    
    override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return index
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
    
    
    //MARK: PrepareForSegue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        print(sender)
        if segue.identifier == "show_profile" {
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPathForCell(cell)
            let contactViewController:ProfileVC = segue.destinationViewController as! ProfileVC
            
            let contact: RUser
            if searchController.active && searchController.searchBar.text != "" {
                contact = self.filteredList[indexPath!.row]
            } else {
                contact = self.list[indexPath!.row]
            }
            
            contactViewController.contact = contact
            
        }
    }
   
}

extension ContactViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
    }
}

extension ContactViewController: UISearchBarDelegate {
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}

