//
//  CarnetTVC.swift
//  mplango
//
//  Created by Thomas Petit on 08/08/2015.
//  Copyright (c) 2015 unb.br. All rights reserved.
//
import UIKit
import Alamofire
import SwiftyJSON

class CarnetTVC: UITableViewController {
        
    //MARK: Properties
    
    var itens = [Carnet]()
    var filteredItens = [Carnet]()
    
    var userId:Int!
    
    var word:String  = ""
    var text:String = ""
    var image:String = ""
    
    var indicator:ActivityIndicator = ActivityIndicator()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        retrieveLoggedUser()
        print("self.userId : ", self.userId)
        self.upServerNote()
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.placeholder = "Rechercher"
        
    }
    
    
    func retrieveLoggedUser() {
        
        // recupera os dados do usuário logado no app
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        self.userId = prefs.integerForKey("id") as Int
        NSLog("usuário logado: %ld", userId)
        
    }
    
    func upServerNote() {
        
        self.indicator.showActivityIndicator(self.view)

        let params : [String: Int] = [
            "user": self.userId
        ]

//        Checagem remota
        Alamofire.request(.GET, EndpointUtils.CARNET, parameters: params)
            .responseSwiftyJSON({ (request, response, json, error) in
                if let notes = json["data"].array {
                    for note in notes {
                        var id:Int = 0
                        var word:String  = ""
                        var text:String = ""
                        var imageUrl:String = ""
                        var audioUrl:String = ""
                        
                        if let noteId = note["id"].int {
                            id = noteId
                        }
                        
                        if let noteWord = note["word"].string {
                           word = noteWord
                            
                        }
                        
                        if let noteText = note["text"].string {
                            text = noteText
                            
                        }
                        
                        if (note["photo"].string != nil) {
                            imageUrl = EndpointUtils.CARNET + "?id=" + String(id) + "&image=true"                          
                        }
                        
                        if (note["audio"].string != nil) {
                            audioUrl = EndpointUtils.CARNET + "?id=" + String(id) + "&audio=true"
                            print("----***-----");
                            print(audioUrl);
                            print("----***-----")
                        }
                        
                        self.itens.append(Carnet(id: id, word: word, text: text, image: imageUrl, audio: audioUrl))
                    }
                    self.indicator.hideActivityIndicator();
                    self.tableView.reloadData()
                    
                }
            });
        
    }
    
    // MARK: Search bar
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredItens = itens.filter { itens in
            return itens.word.lowercaseString.containsString(searchText.lowercaseString)
        }
        
        tableView.reloadData()
    }


    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active && searchController.searchBar.text != "" {
            return filteredItens.count
        }
        return self.itens.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("CarnetCell", forIndexPath: indexPath) as! CarnetTableViewCell
        
        let item: Carnet
        
        if searchController.active && searchController.searchBar.text != "" {
            item = self.filteredItens[indexPath.row]
        } else {
            item = self.itens[indexPath.row]
        }
        
        cell.wordLabel.text = item.word
        cell.picturePreview.image = ImageUtils.instance.loadImageFromPath(item.image)

        return cell
    }
    
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {
            
            let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            let userId:Int = prefs.integerForKey("id") as Int

            print("item is \(self.itens[indexPath.row].id)")
            print("deletando o item")
            print("userId is:",userId)
            
            let params : [String: AnyObject] = [
                "user": self.userId,
                "id": self.itens,
                "word": self.word,
                "text": self.text,
                "photo": self.image
            ]
            
            let urlEdit :String = EndpointUtils.CARNET + "?id=" + String(self.itens[indexPath.row].id)
            print("urlEdit is:",urlEdit)
            
            self.indicator.showActivityIndicator(self.view)
            
            Alamofire.request(.DELETE, urlEdit , parameters: params)
                .responseString { response in
                    print("Success: \(response.result.isSuccess)")
                    print("Response String: \(response.result.value)")
                }.responseSwiftyJSON({ (request, response, json, error) in
                    if (error == nil) {
                        self.indicator.hideActivityIndicator();
                        NSOperationQueue.mainQueue().addOperationWithBlock {
                            self.tableView.reloadData()
                            self.itens.removeAtIndex(indexPath.row)
                            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                        }
                    } else {
                        NSOperationQueue.mainQueue().addOperationWithBlock {
                            //New Alert Ccontroller
                            let alertController = UIAlertController(title: "Oops", message: "Tivemos um problema ao deletar seu item. Favor tente novamente.", preferredStyle: .Alert)
                            let agreeAction = UIAlertAction(title: "Ok", style: .Default) { (action) -> Void in
                                print("Delete is not okay.")
                                self.indicator.hideActivityIndicator();
                            }
                            alertController.addAction(agreeAction)
                            self.presentViewController(alertController, animated: true, completion: nil)
                        }
                    }
                })
        }
    }
    

//    override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
//        return self.fetchedResultController.sectionForSectionIndexTitle(title, atIndex: index)
//    }
//    
//    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return self.fetchedResultController.sections![section].name
//    
//    }
    
    /*
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return self.fetchedResultController.sectionIndexTitles
    }
    */

    
//    @IBAction func unwindSecondView(segue: UIStoryboardSegue) {
//        print ("unwindSecondView fired in first view")
//        print("self.userId : ", self.userId)
//        self.upServerNote()
//    }
    
    
    //MARK: PrepareForSegue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        print(sender)
        if segue.identifier == "show_item" {
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPathForCell(cell)
            let itemController:CarnetViewController = segue.destinationViewController as! CarnetViewController
            
            let item: Carnet
            if searchController.active && searchController.searchBar.text != "" {
                item = self.filteredItens[indexPath!.row]
            } else {
                item = self.itens[indexPath!.row]
            }
            
            itemController.item = item
            
        }
    }
    
}

extension CarnetTVC: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
