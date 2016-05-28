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

//    var profileFilter:NSNumber = 2
    var userId:Int!
    var userFollowing = [Int]()
    
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
                        var category: String = ""
                        var followers: Int = 0
                        var following: Int = 0;
                        
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
                        
                        
                        /*
                         retira o usuário logado da lista e adiciona os seguidores
                         dele para marcar os botões "suivre/suivi"
                         */
                        if self.userId == id {
                            if let arFollowing = user["following"].array {
                                for fUser in arFollowing {
                                    if let fUserId = fUser["id"].int {
                                        self.userFollowing.append(fUserId)
                                        following = fUserId
                                        print("show following : ",fUserId)
                                    }
                                }
                                
                            }
                            
                            if let arFollowers = user["followers"].array {
                                for fUser in arFollowers {
                                    if let fUserId = fUser["id"].int {
                                        followers = fUserId
                                        print("show followers : ",fUserId)

                                    }
                                }
                            }
                            
                            
                            print("following.count logged user")
                            print(self.userFollowing.count)
                            
                            continue
                        }
                        
                        self.list.append(RUser(id: id, email: email, name: name, gender: gender, password: password, nationality: nationality, image: imageUrl, level: level, bio: bio, category: category, followers: followers, following: following))
                        
                    }
                    self.indicator.hideActivityIndicator();
                    self.tableView.reloadData()
                    //pega os contatos do facebook caso ele tenha logado pela rede
                    if let token = FBSDKAccessToken.currentAccessToken() {
                        print("token : ", token)
                        self.friendsList()
                    }
                }
            });
        
    }
    
    func friendsList() {
        self.indicator.showActivityIndicator(self.view)
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me/friends", parameters: nil)
        graphRequest.startWithCompletionHandler( { (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                // Process error
                print("Error: \(error)")
                return
            }
            
            print(result)
            
            let summary = result.valueForKey("summary") as! NSDictionary
            let counts = summary.valueForKey("total_count") as! NSNumber
            
            let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me/taggable_friends", parameters: ["fields": "id,name, email, picture.type(large)", "limit": "\(counts)"])
            graphRequest.startWithCompletionHandler( { (connection, result, error) -> Void in
                
                if ((error) != nil)
                {
                    // Process error
                    print("Error: \(error)")
                    return
                }
                else
                {
                    let friends = result.valueForKey("data") as! NSArray
                    var count = 1
                    if let array = friends as? [NSDictionary] {
                        for friend : NSDictionary in array {
                            let fName = friend.valueForKey("name") as! String
                            let fPicture = friend.valueForKey("picture")?.valueForKey("data")?.valueForKey("url") as? String
                            
                            print("\(count) \(fName)")
                            self.list.append(RUser(id: 0, email: "", name: fName, gender: "", password: "", nationality: "", image: fPicture!, level: User.BEGINNER, bio: "", category: fName, followers: 0, following: 0))
                            count += 1                        }
                        self.indicator.hideActivityIndicator();
                        self.tableView.reloadData()
                    }
                    
                }
                
            })
        })
        
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
            cell.followBtn.tag = contact.id
        
            cell.contactPicture.image = ImageUtils.instance.loadImageFromPath(String(contact.image))
            cell.contactPicture.layer.masksToBounds = true
            cell.contactPicture.layer.cornerRadius = 30

            if (self.userFollowing.indexOf(contact.id) != nil) {
                self.toggleFollowBtnView((cell.followBtn as! UIButton), state: true)
            }
        
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
        
        let params : [String: Int] = [
            "following" : sender.tag,
        ]
        print(EndpointUtils.USER + "?id=" + String(userId))
        Alamofire.request(.PUT, EndpointUtils.USER + "?id=" + String(userId), parameters: params)
            .responseString { response in
                print("Success PUT: \(response.result.isSuccess)")
                print("Response String: \(response.result.value)")
            }.responseSwiftyJSON({ (request, response, json, error) in
                print("Request PUT: \(request)")
                if (error == nil) {
                    self.indicator.hideActivityIndicator();
                    self.toggleFollowBtnView(sender, state: true)
                } else {
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        //New Alert Ccontroller
                        let alertController = UIAlertController(title: "Oops", message: "Tivemos um problema ao tentar seguir esse usuário. Favor tente novamente.", preferredStyle: .Alert)
                        let agreeAction = UIAlertAction(title: "Ok", style: .Default) { (action) -> Void in
                            self.indicator.hideActivityIndicator();
                        }
                        alertController.addAction(agreeAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                }
            })
    }
    
    func toggleFollowBtnView(button: UIButton, state:Bool) {
        
        if state {
            button.backgroundColor = UIColor.clearColor()
            button.layer.borderWidth = 1.0
            button.layer.borderColor = UIColor(hex: 0x2C98D4).CGColor
            button.setTitle("Abonné(e)", forState: UIControlState.Normal)
            button.setTitleColor(UIColor(hex: 0x2C98D4), forState: UIControlState.Normal)
            return
        }
        
        button.backgroundColor = UIColor(hex: 0x2C98D4)
        button.layer.borderWidth = 0
        button.setTitle("Suivre", forState: UIControlState.Normal)
        button.setTitleColor(UIColor(hex: 0xFFFFFF), forState: UIControlState.Normal)
        
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

extension FollowersTVC: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
    }
}

extension FollowersTVC: UISearchBarDelegate {
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}

