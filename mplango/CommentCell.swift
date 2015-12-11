//
//  CommentCell.swift
//  mplango
//
//  Created by Thomas Petit on 10/12/2015.
//  Copyright © 2015 unb.br. All rights reserved.
//

import UIKit
import CoreData

class CommentCell: UITableViewCell, NSFetchedResultsControllerDelegate {
    
    let moContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    var fetchedResultController: NSFetchedResultsController = NSFetchedResultsController()
    
    var comment: Post? = nil
    
    var user: User!
    
    
    // MARK: Properties

    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var comTxtView: UITextView!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var likeBtn: UIButton!
    
    
    override func layoutSubviews() {
        
        retrieveLoggedUser()
        print("user data")
        print(user.name)

        userName.text = user.name
        
        profilePicture.layer.cornerRadius = 15
        profilePicture.layer.masksToBounds = true
        
    }
    
    
    func retrieveLoggedUser() {
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let email: String = prefs.objectForKey("USEREMAIL") as! String
        let fetchRequest = NSFetchRequest(entityName: "User")
        fetchRequest.predicate = NSPredicate(format: "email == %@", email)
        
        if let fetchResults = (try? moContext?.executeFetchRequest(fetchRequest)) as? [User] {
            user = fetchResults[0];
            
        }
        
    }
    
    
    func textViewDidChange(textView: UITextView) {
        
        let contentSize = self.sizeThatFits(self.comTxtView.bounds.size)
        var frame = self.comTxtView.frame
        frame.size.height = contentSize.height
        self.comTxtView.frame = frame
        
        let aspectRatioTextViewConstraint = NSLayoutConstraint(item: self.comTxtView, attribute: .Height, relatedBy: .Equal, toItem: self.comTxtView, attribute: .Width, multiplier: comTxtView.bounds.height/comTxtView.bounds.width, constant: 1)
        self.comTxtView.addConstraint(aspectRatioTextViewConstraint)
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
