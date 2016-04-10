//
//  CarnetTVC.swift
//  mplango
//
//  Created by Thomas Petit on 08/08/2015.
//  Copyright (c) 2015 unb.br. All rights reserved.
//

import UIKit
import MapKit
import Alamofire
import SwiftyJSON

class CarnetTVC: UITableViewController {
       
        
    //MARK: Properties
    
    var item: Carnet? = nil
    var restPath = "http://server.maplango.com.br/note-rest"
    var userId:Int!
    
    var indicator:ActivityIndicator = ActivityIndicator()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        retrieveLoggedUser()
        print("self.userId : ", self.userId)
        self.upServerUser()
        
//        //recupera os dados do usuário logado no TableView
//        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
//        let user:Int = prefs.integerForKey("id") as Int
//        NSLog("usuário logado: %ld", user)
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tableView.reloadData()
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
        
        //Checagem remota
        Alamofire.request(.GET, self.restPath, parameters: params)
            .responseSwiftyJSON({ (request, response, json, error) in
                self.indicator.hideActivityIndicator();
                let user = json["data"]
                print(user);
                
                if let item = user["word"].string {
                    print("show item : ", item)
                    self.tableView.reloadData()

                }
                
            });
        
    }

    
    
    // MARK: - Table view data source
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.item.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            let cell = self.tableView.dequeueReusableCellWithIdentifier("CarnetCell", forIndexPath: indexPath) as UITableViewCell
            cell.textLabel?.text = self.item[indexPath.row].string
        
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
    
    
    // MARK: - TableView Refresh
    
//    func controllerDidChangeContent(controller: NSFetchedResultsController) {
//        print("data changed")
//        tableView.reloadData()
//    }
    
    
    // MARK: - TableView Delete
    
//    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
//        let managedObject:NSManagedObject = fetchedResultController.objectAtIndexPath(indexPath) as! NSManagedObject
//        moContext?.deleteObject(managedObject)
//        do {
//            try moContext?.save()
//        } catch _ {
//        }
//    }
    
    
    //MARK: PrepareForSegue
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
//        
//        if segue.identifier == "show_item" {
//            let cell = sender as! UITableViewCell
//            let indexPath = tableView.indexPathForCell(cell)
//            let itemController:CarnetViewController = segue.destinationViewController as! CarnetViewController
//            let item:JSON = self.item.objectAtIndexPath(indexPath!) as! JSON
//            itemController.item = item.
//        }
//    }
}