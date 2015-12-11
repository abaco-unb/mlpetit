//
//  CommentsVC.swift
//  mplango
//
//  Created by Thomas Petit on 10/12/2015.
//  Copyright © 2015 unb.br. All rights reserved.
//

import UIKit
import CoreData

class CommentsVC: UIViewController, NSFetchedResultsControllerDelegate, UITextViewDelegate {

    // MARK: Properties
    
    let moContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    var fetchedResultController: NSFetchedResultsController = NSFetchedResultsController()
    
    var comment: Post? = nil
    
    var user: User!

    let basicCellIdentifier = "BasicCell"
    
    @IBOutlet weak var creatingContentView: UIView!
    @IBOutlet weak var comTableView: UITableView!

    @IBOutlet weak var writeTxtView: UITextView!
    
    @IBOutlet weak var postComBtn: UIButton!
    
    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var imageBtn: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.writeTxtView.delegate = self
        
        fetchedResultController = getFetchedResultController()
        fetchedResultController.delegate = self
        do {
            try fetchedResultController.performFetch()
        } catch _ {
        }
        
        
        if comment != nil {
            writeTxtView.text = comment?.text
        }
        
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        
        //Para que a view acompanhe o teclado e poder escrever o comentário
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
        
        writeTxtView.delegate = self
        
        postComBtn.hidden = true
        
        comTableView.rowHeight = UITableViewAutomaticDimension
        comTableView.estimatedRowHeight = 160.0


    }

    
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.frame.origin.y -= keyboardSize.height
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.frame.origin.y += keyboardSize.height
        }
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
        
        writeTxtView.text = nil
        postComBtn.hidden = true
        imageBtn.hidden = false
        imageBtn.enabled = true
        recordBtn.hidden = false
        recordBtn.enabled = true
        
    }
    
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
    
        let limitLength = 149
        guard let text = writeTxtView.text else { return true }
        let newLength = text.characters.count - range.length
        
        return newLength <= limitLength
    
    }
    
    func textViewDidChange(textView: UITextView) {
        
        let text = writeTxtView.text
        
        if text.characters.count >= 1 {
        
            postComBtn.hidden = false
            postComBtn.enabled = true
            imageBtn.hidden = true
            recordBtn.hidden = true
            
        }
        
        else if text.characters.count < 1 {
            postComBtn.hidden = true
            imageBtn.hidden = false
            imageBtn.enabled = true
            recordBtn.hidden = false
            recordBtn.enabled = true
        }

    }
    
    
    // MARK Actions:
    
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(false, completion: nil)
    }
    
    @IBAction func postComment(sender: AnyObject) {
        
        postComment()
        
        writeTxtView.resignFirstResponder()
        
        writeTxtView.text = nil
        postComBtn.hidden = true
        imageBtn.hidden = false
        imageBtn.enabled = true
        recordBtn.hidden = false
        recordBtn.enabled = true
        
    }
    
    
    // MARK:- Retrieve Tasks
    
    func getFetchedResultController() -> NSFetchedResultsController {
        fetchedResultController = NSFetchedResultsController(fetchRequest: itemFetchRequest(), managedObjectContext: moContext!, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultController
        
    }
    
    func itemFetchRequest() -> NSFetchRequest {
        let fetchRequest = NSFetchRequest(entityName: "Post")
        
        /*
        if(segment != 2) {
        print("fazer filtro")
        let predicate = NSPredicate(format: "category == %@", segment)
        fetchRequest.predicate = predicate
        }
        */
        
        let sortDescriptor = NSSortDescriptor(key: "text", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        return fetchRequest
        
    }
    
    
    
    // MARK:- Post Comment
    
    func postComment () {
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let email: String = prefs.objectForKey("USEREMAIL") as! String
        let fetchRequest = NSFetchRequest(entityName: "User")
        fetchRequest.predicate = NSPredicate(format: "email == %@", email)
        
        if let fetchResults = (try? moContext?.executeFetchRequest(fetchRequest)) as? [User] {
            
            let user: User = fetchResults[0];
            let entityDescription = NSEntityDescription.entityForName("Post", inManagedObjectContext: moContext!)
            let comment = Post(entity: entityDescription!, insertIntoManagedObjectContext: moContext)
            comment.text = writeTxtView.text!
            comment.user = user
            
            
            do {
                //falta foto
                //falta som
                try moContext?.save()
            } catch _ {
            }
            
            
        }
    }

    
    
    // Table view
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        let numberOfSections = fetchedResultController.sections?.count
        return numberOfSections!
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRowsInSection = fetchedResultController.sections?[section].numberOfObjects
        return numberOfRowsInSection!
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("BasicCell", forIndexPath: indexPath) as! CommentCell
        let comment = fetchedResultController.objectAtIndexPath(indexPath) as! Post
        
        cell.comTxtView.text = comment.text
        
        /* Para indicar achar a hora e o dia do comentário
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(NSCalendarUnit.Year.union(NSCalendarUnit.Minute), fromDate: date)
        let hour = components.hour
        let minutes = components.minute
        */
        
        let date = NSDate()
        let dateFormatter = NSDateFormatter()
        
        let theDateFormat = NSDateFormatterStyle.ShortStyle
        let theTimeFormat = NSDateFormatterStyle.ShortStyle
        
        dateFormatter.dateStyle = theDateFormat
        dateFormatter.timeStyle = theTimeFormat
        
        cell.dateLabel.text = dateFormatter.stringFromDate(date)
        
        
        
        return cell
    }
    
    // MARK: - TableView Delete (ISSO PODE TIRAR DEPOIS, É SÓ PARA OS TESTES DA TELA)
    
     func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let managedObject:NSManagedObject = fetchedResultController.objectAtIndexPath(indexPath) as! NSManagedObject
        moContext?.deleteObject(managedObject)
        do {
            try moContext?.save()
        } catch _ {
        }
    }
    
    
    
    
    // MARK: - TableView Refresh
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        print("data changed")
        comTableView.reloadData()
    }

    
    
}