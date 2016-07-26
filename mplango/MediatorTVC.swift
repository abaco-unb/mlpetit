//
//  MediatorTVC.swift
//  mplango
//
//  Created by Thomas Petit on 03/06/2016.
//  Copyright © 2016 unb.br. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import AlamofireSwiftyJSON

class MediatorTVC: UITableViewController {

    //MARK: Properties
    
    var list = [Test]()
    var filteredList = [Test]()
    
    var userId:Int!
    var contact : RUser!

    var indicator:ActivityIndicator = ActivityIndicator()
    
    let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()

        retrieveLoggedUser()
        print("self.userId : ", self.userId)
        self.upServerActivities()
        
        searchController.searchBar.delegate = self
        searchController.searchBar.tintColor = UIColor.whiteColor()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func retrieveLoggedUser() {
        
        // recupera os dados do usuário logado no app
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        self.userId = prefs.integerForKey("id") as Int
        NSLog("usuário logado: %ld", userId)
        
    }
    
    func upServerActivities() {
        self.indicator.showActivityIndicator(self.view)
        //        Checagem remota
        Alamofire.request(.GET, EndpointUtils.USER)
            .responseSwiftyJSON({ (request, response, json, error) in
                if let activities = json["data"].array {
                    for activity in activities {
                        var id: Int = 0
                        var desc:String = ""
                        var level:Int = 0
                        var ownerName: String = ""
                        var ownerId: Int = 0
                        var status: String = "";
                        
                        if let actId = activity["id"].int {
                            print("show id : ", actId)
                            id = actId
                            
                        }
                        
                        if let actDesc = activity["desc"].string {
                            print("show desc : ", actDesc)
                            desc = actDesc
                            
                        }
                        
                        if let actLevel = activity["level"]["id"].int {
                            print("show level : ",actLevel)
                            level = actLevel
                            
                        }
                        
                        if let actOwnerName = activity["ownername"].string {
                            ownerName = actOwnerName
                            
                        }
                        
                        if let actOwnerId = activity["ownerid"].int {
                            ownerId = actOwnerId
                            
                        }
                        
                        if let actStatus = activity["nationality"].string {
                            status = actStatus
                            
                        }
                        
                        self.list.append(Test(id: id, desc: desc, level: level, ownerName: ownerName, ownerId: ownerId, status: status))
                        
                    }
                    
                    self.indicator.hideActivityIndicator();
                    self.tableView.reloadData()
                
                }
            });
    }
    
    // MARK: Search bar
    
    func filterContentForSearchText(searchText: String, scope: String = "Toutes") {
        filteredList = list.filter { activity in
            let categoryMatch = (scope == "Toutes") || (activity.status == scope)
            return categoryMatch && activity.ownerName.lowercaseString.containsString(searchText.lowercaseString)
        }
        
        tableView.reloadData()
    }
    
    
    @IBAction func showSearchBar(sender: AnyObject) {
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        searchController.searchBar.placeholder = "Rechercher"
        searchController.searchBar.scopeButtonTitles = ["Toutes", "Plus urgentes", "Mes contacts"]
        
    }


    // MARK: - Table view data source

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
        
        let activity: Test
        if searchController.active && searchController.searchBar.text != "" {
            activity = self.filteredList[indexPath.row]
        } else {
            activity = self.list[indexPath.row]
        }
        
        // aqui o contactCategory indica na verdade o nível do teste tentado pelo estudante
        // se chama assim porque vem da ContactCell, usada nesta tabela para evitar criar outra
        if activity.level == Test.LEVEL_2 {
            cell.contactCategory.text = "Test Niveau 2"
        }
        else if activity.level == Test.LEVEL_3 {
            cell.contactCategory.text = "Test Niveau 3"
        }
        else if activity.level == Test.LEVEL_4 {
            cell.contactCategory.text = "Test Niveau 4"
        }
        else if activity.level == Test.LEVEL_M {
            cell.contactCategory.text = "Test Niveau M"
        }
        
        // aqui o followBtn indica na verdade qual a atividade específica do referido teste
        // se chama assim porque vem da ContactCell, usada nesta tabela para evitar criar outra
        let evalBtn: UIButton = UIButton()
        evalBtn.setTitle("Activité " + activity.desc, forState: .Normal)
        cell.followBtn = evalBtn
        
        cell.contactName.text = contact.name
        cell.contactPicture.image = ImageUtils.instance.loadImageFromPath(String(contact.image))
        cell.contactPicture.layer.masksToBounds = true
        cell.contactPicture.layer.cornerRadius = 30

        return cell
    }

    // MARK: - TableView Refresh
    
    func controllerDidChangeContent(controller: RUser) {
        tableView.reloadData()
    }
    
    
    
    
    
    
    
}

// As extensions para a barra de busca

extension MediatorTVC: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
    }
}

extension MediatorTVC: UISearchBarDelegate {
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}


