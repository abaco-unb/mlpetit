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
        fetchedResultController.performFetch(nil)
        
        // Load the sample data.
        //loadSampleWords()
        
        /*
        var error: NSError?
        let request = NSFetchRequest(entityName:"Carnet")
        carnet = moContext?.executeFetchRequest(request, error: &error) as! [Carnet]
        self.tableView.reloadData()
        
        navigationItem.leftBarButtonItem = editButtonItem()
        */
        
        
    }
    
    
    //MARK: PrepareForSegue
    /*
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "ShowWord" {
    let itemDetailViewController = segue.destinationViewController as! CarnetViewController
    
    // Get the cell that generated this segue.
    if let selectedWordCell = sender as? CarnetTVCell {
    let indexPath = tableView.indexPathForCell(selectedWordCell)!
    //let selectedWord = carnet[indexPath.row]
    
    var newItem = Word(word: "", desc: "", photo: nil)
    //newItem.word = selectedWord.entity.word
    itemDetailViewController.item = newItem
    }
    }
    else if segue.identifier == "AddWord" {
    print("Adding new Word.")
    }
    }
    */

    
    // MARK:- Retrieve Tasks
    
    func getFetchedResultController() -> NSFetchedResultsController {
        fetchedResultController = NSFetchedResultsController(fetchRequest: itemFetchRequest(), managedObjectContext: moContext!, sectionNameKeyPath: nil, cacheName: nil)
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
        let numberOfSections = fetchedResultController.sections?.count
        return numberOfSections!
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRowsInSection = fetchedResultController.sections?[section].numberOfObjects
        return numberOfRowsInSection!
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        let item = fetchedResultController.objectAtIndexPath(indexPath) as! Carnet
        cell.textLabel!.text = item.word
        return cell
    }
    
    
    
    // MARK: - TableView Refresh
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.reloadData()
    }
    
    
    // MARK: - TableView Delete
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let managedObject:NSManagedObject = fetchedResultController.objectAtIndexPath(indexPath) as! NSManagedObject
        moContext?.deleteObject(managedObject)
        moContext?.save(nil)
    }
    
    
    
    
 
   
  
}