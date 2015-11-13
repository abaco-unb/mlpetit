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
    
    //var segment:NSNumber = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchedResultController = getFetchedResultController()
        fetchedResultController.delegate = self
        do {
            try fetchedResultController.performFetch()
        } catch _ {
        }
        navigationItem.leftBarButtonItem = editButtonItem()
        
    }
    
    
    // MARK:- Retrieve Tasks
    
    func getFetchedResultController() -> NSFetchedResultsController {
        fetchedResultController = NSFetchedResultsController(fetchRequest: itemFetchRequest(), managedObjectContext: moContext!, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultController
        
    }
    
    func itemFetchRequest() -> NSFetchRequest {
        let fetchRequest = NSFetchRequest(entityName: "Carnet")
        
        /*
        if(segment != 2) {
            print("fazer filtro")
            let predicate = NSPredicate(format: "category == %@", segment)
            fetchRequest.predicate = predicate
        }
        */
        
        let sortDescriptor = NSSortDescriptor(key: "word", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        return fetchRequest
        
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - Table view data source
    
    let sections:Array<AnyObject> = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"]
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        let numberOfSections = fetchedResultController.sections?.count
        return numberOfSections!
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRowsInSection = fetchedResultController.sections?[section].numberOfObjects
        return numberOfRowsInSection!
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        
        /*
        if indexPath.row == 0 {
            cell = tableView.dequeueReusableCellWithIdentifier("SegmentCell", forIndexPath: indexPath) 
        } else {

        */
            cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) 
            let item = fetchedResultController.objectAtIndexPath(indexPath) as! Carnet
            cell.textLabel!.text = item.word
        //}
        
        return cell
    }
    
    
    //Para mostrar o index do alfabeto à direita da tela
    /*
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]! {
        return self.sections
    }
    */
    
    override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return index
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section] as? String
    }
    
    
    
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
            //let itemController:UINavigationController = segue.destinationViewController as! UINavigationController
            //let targetController = itemController.topViewController as! CarnetViewController
            let item:Carnet = fetchedResultController.objectAtIndexPath(indexPath!) as! Carnet
            //targetController.item = item
            itemController.item = item
            
        }

    }
    
    /*
    @IBAction func segumentedTapped(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            segment = 0
        case 1:
            segment = 1
        default:
            segment = 2
            break
        }
        print("sender.selectedSegmentIndex")
        print(sender.selectedSegmentIndex)
        fetchedResultController = getFetchedResultController()
        do {
            try fetchedResultController.performFetch()
        } catch _ {
        }
        tableView.reloadData()
    }
    */
    
  
}