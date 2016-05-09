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
    
    var restPath = "http://server.maplango.com.br/note-rest"
    var userId:Int!
    
    var indicator:ActivityIndicator = ActivityIndicator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        retrieveLoggedUser()
        print("self.userId : ", self.userId)
        self.upServerNote()
        
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
        Alamofire.request(.GET, self.restPath, parameters: params)
            .responseSwiftyJSON({ (request, response, json, error) in
                if let notes = json["data"].array {
                    for note in notes {
                        var id:Int = 0
                        var word:String  = ""
                        var text:String = ""
                        var image:String = "";
                        
                        if let noteId = note["id"].int {
                            id = noteId
                        }
                        
                        if let noteWord = note["word"].string {
                           word = noteWord
                            
                        }
                        
                        if let noteText = note["text"].string {
                            text = noteText
                            
                        }
                        
                        if let noteImage = note["image"].string {
                            image = noteImage
                            
                        }
                        
                        self.itens.append(Carnet(id: id, word: word, text: text, image: image))
                    }
                    self.indicator.hideActivityIndicator();
                    self.tableView.reloadData()
                    
                }
            });
        
    }
    
    // MARK: - Table view data source
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.itens.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CarnetCell", forIndexPath: indexPath) as! CarnetTableViewCell
        cell.wordLabel.text = self.itens[indexPath.row].word
        return cell
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
    

    
    // MARK: - TableView Delete
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            
            print("item is \(self.itens[indexPath.row])")
            
            let params : [String: AnyObject] = [
                "user": self.userId
            ]
            
            //AQUI TEM QUE TROCAR O USER ID PELO ID DO NOTE??
            let urlEdit :String = restPath + "?id=" + String(itens)
            
            Alamofire.request(.DELETE, urlEdit , parameters: params)
                .responseString { response in
                    print("Success: \(response.result.isSuccess)")
                    print("Response String: \(response.result.value)")
                }.responseSwiftyJSON({ (request, response, json, error) in
                    if (error == nil) {
                        self.indicator.hideActivityIndicator();
                        NSOperationQueue.mainQueue().addOperationWithBlock {
                            self.tableView.reloadData()
                        }
                        
                    }
                    
                })
            
        }
    }
    
    
    //MARK: PrepareForSegue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        print(sender)
        if segue.identifier == "show_item" {
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPathForCell(cell)
            let itemController:CarnetViewController = segue.destinationViewController as! CarnetViewController
            let item:Carnet = self.itens[indexPath!.row]
            itemController.item = item
            
        }
    }
    
    
}