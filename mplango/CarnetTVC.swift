//
//  CarnetTVC.swift
//  mplango
//
//  Created by Thomas Petit on 08/08/2015.
//  Copyright (c) 2015 unb.br. All rights reserved.
//

import UIKit
import CoreData

class CarnetTVC: UITableViewController, NSFetchedResultsControllerDelegate {
       
    
    //MARK: Properties
    
    let moContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    var fetchedResultController: NSFetchedResultsController = NSFetchedResultsController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchedResultController = getFetchedResultController()
        fetchedResultController.delegate = self
        do {
            try fetchedResultController.performFetch()
        } catch _ {
        }
        
        //navigationItem.leftBarButtonItem = editButtonItem()
        
    }
    
    
    // MARK:- Retrieve Tasks
    
    func getFetchedResultController() -> NSFetchedResultsController {
        fetchedResultController = NSFetchedResultsController(fetchRequest: itemFetchRequest(), managedObjectContext: self.moContext!, sectionNameKeyPath: "word", cacheName: nil)
        
        fetchedResultController.delegate = self

        return fetchedResultController
        
    }
    
    func itemFetchRequest() -> NSFetchRequest {
        
        let fetchRequest = NSFetchRequest(entityName: "Carnet")
        
        let sortDescriptor = NSSortDescriptor(key: "word", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        
        return fetchRequest
        
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - Table view data source
    
   
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        let numberOfSections = self.fetchedResultController.sections?.count
        return numberOfSections!
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRowsInSection = self.fetchedResultController.sections?[section].numberOfObjects
        return numberOfRowsInSection!
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        
            cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) 
            let item = fetchedResultController.objectAtIndexPath(indexPath) as! Carnet
            cell.textLabel!.text = item.word
        
        return cell
    }
    
    override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return self.fetchedResultController.sectionForSectionIndexTitle(title, atIndex: index)
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.fetchedResultController.sections![section].name
    
    }
    
    
    /*
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return self.fetchedResultController.sectionIndexTitles
    }
    */
    
    
    
    // MARK: - TableView Refresh
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        print("data changed")
        tableView.reloadData()
    }
    
    
    // MARK: - TableView Delete
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let managedObject:NSManagedObject = fetchedResultController.objectAtIndexPath(indexPath) as! NSManagedObject
        moContext?.deleteObject(managedObject)
        do {
            try moContext?.save()
        } catch _ {
        }
    }
    
    
    //MARK: PrepareForSegue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        if segue.identifier == "seeItem" {
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPathForCell(cell)
            let itemController:CarnetViewController = segue.destinationViewController as! CarnetViewController
            let item:Carnet = fetchedResultController.objectAtIndexPath(indexPath!) as! Carnet
            itemController.item = item
            
        }

    }
    
    
}