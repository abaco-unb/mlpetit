//
//  ListUsers.swift
//  mplango
//
//  Created by Carlos Wagner Pereira de Morais on 29/05/15.
//  Copyright (c) 2015 unb.br. All rights reserved.
//

import UIKit
import CoreData

class ListUsers: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var people = [NSManagedObject]()
    
    override func viewDidLoad() {
    super.viewDidLoad()
        title = "\"The List\""
        tableView.registerClass(UITableViewCell.self,
        forCellReuseIdentifier: "Cell")
    }
    
    func tableView(tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
    func tableView(tableView: UITableView,
        cellForRowAtIndexPath
        indexPath: NSIndexPath) -> UITableViewCell {
    
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! UITableViewCell
    
        let person = people[indexPath.row]
        cell.textLabel!.text = person.valueForKey("name") as? String
    
        return cell
    }
    
    @IBAction func addName(sender: AnyObject) {
        var alert = UIAlertController(title: "New name",
        message: "Add a new name",
        preferredStyle: .Alert)
    
        let saveAction = UIAlertAction(title: "Save",
        style: .Default) { (action: UIAlertAction!) -> Void in
    
        let textField = alert.textFields![0] as! UITextField
        self.saveName(textField.text)
        self.tableView.reloadData()
    }
    
    let cancelAction = UIAlertAction(title: "Cancel",
        style: .Default) { (action: UIAlertAction!) -> Void in
    }
    
    alert.addTextFieldWithConfigurationHandler {
        (textField: UITextField!) -> Void in
    }
    
    alert.addAction(saveAction)
    alert.addAction(cancelAction)
    
    presentViewController(alert,animated: true,completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func saveName(name: String) {
        //1
        let appDelegate =  UIApplication.sharedApplication().delegate as! AppDelegate
    
        let managedContext = appDelegate.managedObjectContext!
        //2
    
        let entity =  NSEntityDescription.entityForName("User",inManagedObjectContext: managedContext)
        let person = NSManagedObject(entity: entity!,insertIntoManagedObjectContext:managedContext)
    
        //3
        person.setValue(name, forKey: "name")
    
        //4
        var error: NSError?
    
        if !managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }
    
        //5
        people.append(person)
    }
    
    
    // Busca a partir de dados básicos
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    
        //1
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
        let managedContext = appDelegate.managedObjectContext!
    
        //2 
        let fetchRequest = NSFetchRequest(entityName:"User")
    
        //3
        var error: NSError?
    
        let fetchedResults =
        managedContext.executeFetchRequest(fetchRequest,error: &error) as? [NSManagedObject]
    
        if let results = fetchedResults {
            people = results
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
        }
    }
}
