//
//  FollowingTVC.swift
//  mplango
//
//  Created by Thomas Petit on 15/12/2015.
//  Copyright © 2015 unb.br. All rights reserved.
//

import UIKit
import CoreData

class FollowingTVC: UITableViewController, NSFetchedResultsControllerDelegate {

    let moContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    var fetchedResultController: NSFetchedResultsController = NSFetchedResultsController()
    
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    //MARK: Actions
    
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(false, completion: nil)
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
    
}