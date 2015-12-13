//
//  CommentsVC.swift
//  mplango
//
//  Created by Thomas Petit on 10/12/2015.
//  Copyright © 2015 unb.br. All rights reserved.
//

import UIKit
import CoreData

class CommentsVC: UIViewController, NSFetchedResultsControllerDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate, UIPopoverPresentationControllerDelegate {

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
    
    @IBOutlet weak var comPicture: UIImageView!
    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var imageBtn: UIButton!

    @IBOutlet weak var removeImage: UIButton!
    
    @IBOutlet weak var writeHereImage: UIImageView!
    
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
        
        removeImage.hidden = true

        
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
        writeHereImage.hidden = false
        removeImage.hidden = true

    }
    
    // MARK : UITextView functions
    
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
    
    func textViewDidBeginEditing(textView: UITextView) {
        writeHereImage.hidden = true
    }
    
    
       // MARK Actions:
    
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(false, completion: nil)
    }
    
    @IBAction func postingComment(sender: AnyObject) {
        
        postComment()
        
        writeTxtView.resignFirstResponder()
        
        writeTxtView.text = nil
        postComBtn.hidden = true
        imageBtn.hidden = false
        imageBtn.enabled = true
        recordBtn.hidden = false
        recordBtn.enabled = true
        writeHereImage.hidden = false
        
        // Gamification: contar 5 pontos aqui para a ação de postar 1 comentário
        
    }
    
    
    // MARK : Image Picker Process
    
    var picker:UIImagePickerController? = UIImagePickerController()
    var popover:UIPopoverPresentationController? = nil
    
    
    @IBAction func removeImage(sender: AnyObject) {
        
        comPicture.image = nil
        removeImage.hidden = true
        
        postComBtn.hidden = true
        imageBtn.hidden = false
        imageBtn.enabled = true
        recordBtn.hidden = false
        recordBtn.enabled = true
        
    }
    
    @IBAction func selectImageFromPhotoLibrary(sender: UIButton) {
        //Hide the keyboard
        
        writeTxtView.resignFirstResponder()
        
        let alert:UIAlertController=UIAlertController(title: "Choisir une image", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let cameraAction = UIAlertAction(title: "Caméra", style: UIAlertActionStyle.Default)
            {
                UIAlertAction in
                self.openCamera()
        }
        let gallaryAction = UIAlertAction(title: "Gallerie", style: UIAlertActionStyle.Default)
            {
                UIAlertAction in
                self.openGallary()
        }
        let cancelAction = UIAlertAction(title: "Annuler", style: UIAlertActionStyle.Cancel)
            {
                UIAlertAction in
        }
        
        // Add the actions
        picker?.delegate = self
        alert.addAction(cameraAction)
        alert.addAction(gallaryAction)
        alert.addAction(cancelAction)
        // Present the controller
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone
        {
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else
        {
            popover = UIPopoverPresentationController(presentedViewController: alert, presentingViewController: alert)
            popover?.sourceView = self.view
            popover?.sourceRect = imageBtn.frame
            popover?.permittedArrowDirections = .Any
            
        }
        
    }
    
    func openCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera))
        {
            picker!.sourceType = UIImagePickerControllerSourceType.Camera
            self .presentViewController(picker!, animated: true, completion: nil)
        }
        else
            {
            openGallary()
            }
        }
    
        func openGallary()
        {
        picker!.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone
        {
            self.presentViewController(picker!, animated: true, completion: nil)
        }
        else
        {
            popover = UIPopoverPresentationController(presentedViewController: picker!, presentingViewController: picker!)
            
            popover?.sourceView = self.view
            popover?.sourceRect = imageBtn.frame
            popover?.permittedArrowDirections = .Any
            
        }
    }
   
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject])
    {
        picker.dismissViewControllerAnimated(true, completion: nil)
        comPicture.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        removeImage.hidden = false
        postComBtn.hidden = false
        postComBtn.enabled = true
        imageBtn.hidden = true
        recordBtn.hidden = true
        writeHereImage.hidden = true
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController)
    {
        print("picker cancel.")
        dismissViewControllerAnimated(true, completion: nil)
    }
    

    
    // MARK:- Retrieve Tasks
    
    func getFetchedResultController() -> NSFetchedResultsController {
        fetchedResultController = NSFetchedResultsController(fetchRequest: itemFetchRequest(), managedObjectContext: moContext!, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultController
        
    }
    
    func itemFetchRequest() -> NSFetchRequest {
        let fetchRequest = NSFetchRequest(entityName: "Post")
        let sortDescriptor = NSSortDescriptor(key: "text", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        return fetchRequest
        
    }
    
    
    // MARK:- Posting Comment
    
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
            //falta foto
            //falta som
            
            do {
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
    
    // MARK: - TableView Delete (ISSO VAI SER TIRADO DEPOIS, É SÓ PARA OS TESTES DA TELA)
    
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