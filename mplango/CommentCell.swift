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
    
    // para todas as cells

    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var likeBtn: UIButton!
    
    // para a BasicCell (só texto)
    
    @IBOutlet weak var comTxtView: UITextView!
    
    // para a AudioCell (só som)
    
    //@IBOutlet weak var audioView: UIView!
    //@IBOutlet weak var playBtn: UIButton!
    //@IBOutlet weak var stopBtn: UIButton!
    //@IBOutlet weak var timerLabel: UILabel!
    
    
    override func layoutSubviews() {
        
        retrieveLoggedUser()
        print("user data")
        print(user.name)

        userName.text = user.name
        
        profilePicture.layer.cornerRadius = 15
        profilePicture.layer.masksToBounds = true
        
        //Como vai aparecer a AudioView
        
        /*
        audioView.layer.borderWidth = 1
        audioView.layer.borderColor = UIColor(hex: 0x2C98D4).CGColor
        audioView.layer.cornerRadius = 10
        audioView.layer.masksToBounds = true
        */
        
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
    
    
    // MARK: Actions
    
    @IBAction func like(sender: AnyObject) {
        
        // quando o botão like é clicado, ele é bloqueado e no lugar dele aparece uma image view com a mesma imagem, em vermelho
        
        likeBtn.enabled = false
        
        likeBtn.setImage(UIImage(named: "like_btn"), forState: UIControlState.Normal)
        
        
        
        //aqui deve atualizar o label dos números de likes (likeNberLabel)
        
        //aqui deve tirar 1 ponto de participação do usuário que usa o botão
        
        //aqui o usuário do post deve ganhar 5 pontos de colaboração
        
        //aqui desativar o botão like quando o usuário é o autor do post
        
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
