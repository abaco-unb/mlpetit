//
//  CarnetItemTVC.swift
//  mplango
//
//  Created by Thomas Petit on 09/11/2015.
//  Copyright © 2015 unb.br. All rights reserved.
//

import UIKit
import CoreData

class CarnetItemTVC: UITableViewController, NSFetchedResultsControllerDelegate {
    
    let moContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    var fetchedResultController: NSFetchedResultsController = NSFetchedResultsController()

    
    //MARK: Properties
    
    
    var item: Carnet? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        fetchedResultController = getFetchedResultController()
        fetchedResultController.delegate = self
        do {
            try fetchedResultController.performFetch()
        } catch _ {
        }

        /*
        if item != nil {
           
            navigationItem.title = item!.word
        }
        */
        
        /*
        
        //Hides and disables Save Button in reading mode.
        navigationItem.rightBarButtonItem?.enabled = false
        navigationItem.rightBarButtonItem?.title = nil
        
        }
        */
    
        
    }
    
    // MARK:- Retrieve Tasks
    
    func getFetchedResultController() -> NSFetchedResultsController {
        fetchedResultController = NSFetchedResultsController(fetchRequest: itemFetchRequest(), managedObjectContext: moContext!, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultController
        
    }
    
    func itemFetchRequest() -> NSFetchRequest {
        let fetchRequest = NSFetchRequest(entityName: "Carnet")
        
        //add a new sortdescriptor for each element of the entity

        let sortDescriptor1 = NSSortDescriptor(key: "word", ascending: true)
        //let sortDescriptor2 = NSSortDescriptor(key: "desc", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor1]
        
        return fetchRequest
        
    }
    
    
    // MARK: - Table view data source
    
    func configureTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 160.0
    }

    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        let numberOfSections = fetchedResultController.sections?.count
        return numberOfSections!
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //let numberOfRowsInSection = fetchedResultController.sections?[section].numberOfObjects
        //return numberOfRowsInSection!
        
        return 1
    }
    
    let cellIdentifier = "BasicCarnetCell"

    
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! BasicCarnetCell
        
        
        let item = fetchedResultController.objectAtIndexPath(indexPath) as! Carnet
        
        cell.itemWordLabel!.text = item.word
        cell.itemDescLabel!.text = item.desc

        
        return cell
    }
    */
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return basicCarnetCellAtIndexPath(indexPath)
    }
    
    func basicCarnetCellAtIndexPath(indexPath:NSIndexPath) -> BasicCarnetCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! BasicCarnetCell
        setWordForCell(cell, indexPath: indexPath)
        setDescForCell(cell, indexPath: indexPath)
        return cell
    }
    
    func setWordForCell(cell:BasicCarnetCell, indexPath:NSIndexPath) {
        let item = fetchedResultController.objectAtIndexPath(indexPath) as! Carnet
        cell.itemWordLabel.text = item.word
    }
    
    func setDescForCell(cell:BasicCarnetCell, indexPath:NSIndexPath) {
        let item = fetchedResultController.objectAtIndexPath(indexPath) as! Carnet
        cell.itemDescLabel.text = item.desc
    }

    
    
    override func viewDidAppear(animated: Bool) {
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Navigation
    
    
    /*
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    
    if saveWord === sender {
    let word = WordNameLabel.text ?? ""
    let desc = WordDescriptionLabel.text ?? ""
    let photo = WordSelectedImage.image
    
    //Set the word to be passed to CarnetTVC after the unwind segue.
    item = Word(word: word, desc: desc, photo: photo)
    
    }
    
    
    }
    */
    
}

