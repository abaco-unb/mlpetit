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
    
    var restPath = "http://server.maplango.com.br/note-rest"
    var userId:Int!
    
    var itens = [String]()
    

    var indicator:ActivityIndicator = ActivityIndicator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        retrieveLoggedUser()
        print("self.userId : ", self.userId)
        self.upServerNote()
        
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
    
    func upServerNote() {
        
        self.indicator.showActivityIndicator(self.view)

//        let urlString = restPath
//        let urlEncodedString = urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        
//        let url = NSURL( string: restPath)
//        
//        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, innerError) in
//            let json = JSON(data: data!)
//            let carnet = json.arrayValue
//            
//            dispatch_async(dispatch_get_main_queue(), {
//                
//                for list in carnet
//                    
//                {
//                    let word = list["word"].stringValue
//                    print( "word: \(word)" )
//                    self.itens.append(word)
//                }
//                
//                dispatch_async(dispatch_get_main_queue(),{
//                    self.tableView.reloadData()
//                })
//            })
//        }
//        task.resume()
//    }

        
//        self.indicator.showActivityIndicator(self.view)
        
    
//        Checagem remota
        Alamofire.request(.GET, self.restPath)
            .responseJSON
            { response in switch response.result {
                
            case .Success(let JSON):
                
                if let carnet = JSON as? NSArray {
                    
//                    for list in carnet { // loop through data items
//                        let obj = item as! NSDictionary
//                        let list = String(obj["word"])
//                        self.itens.append(list)
//                    }
//                
//                }
//                
//                self.tableView.reloadData()
                    
                    for list in carnet {
                    
                        let word = list["word"]!!.stringValue
                        print( "word: \(word)" )
                        self.itens.append(word)
                    }
                    
                }
                
                dispatch_async(dispatch_get_main_queue(),{
                    self.tableView.reloadData()
                })
                
            case .Failure(let error):
                print("Request failed with error: \(error)")
                
            }
        }
        
    }
    
    
    


    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.itens.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("CarnetCell", forIndexPath: indexPath) as! CarnetTableViewCell
        
        cell.wordLabel.text = self.itens[indexPath.row]
    
//        print(self.itens[indexPath.row])
        
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